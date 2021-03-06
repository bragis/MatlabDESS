function [adcFitBieri,t2Fit2D,adcFit2D] = DESS2dFit_imgB1(TR,TE,Tg,GhArea,GlArea,alpha_deg,Nstates,e1_H,e2_H,e1_L,e2_L,b1Map)

% Compute the gradient amplitudes in G/m
Gh = GhArea/(Tg*1e6)*100;
Gl = GlArea/(Tg*1e6)*100;

% This is the parameter range that we want for our dictionary.
T1start = 1.15;
T1end = 1.25;
NT1 = 2;
T1values = [T1start:(T1end-T1start)/(NT1-1):T1end];
T2start = 0.01;
T2end = 0.08;
NT2 = 70;
T2values = [T2start:(T2end-T2start)/(NT2-1):T2end];
Dstart = 0.1e-9;
Dend = 6e-9;
ND = 60;
Dvalues = [Dstart:(Dend-Dstart)/(ND-1):Dend];



alphaFracValues = [0.7:0.01:1.3];
NalphaFrac = length(alphaFracValues);




filestr = ['dataBases/signalDatabase', num2str(GhArea), '_B1.mat'];

matchingDatabaseFound = 0;

if (exist(filestr) == 2)
    % We've found a dictionary that might match - let's load it and check
    % its parameters.
    load(filestr);
    if ((dataBase2D.TR == TR) && (dataBase2D.TE == TE) && (dataBase2D.Tg == Tg) ...
        && (dataBase2D.GhArea == GhArea) && (dataBase2D.GlArea == GlArea) && (dataBase2D.alpha_deg == alpha_deg) ...
        && isequal(dataBase2D.alphaFracValues,alphaFracValues) && (dataBase2D.Nstates == Nstates) ...
        && isequal(dataBase2D.T1values,T1values) && isequal(dataBase2D.T2values,T2values) && isequal(dataBase2D.Dvalues,Dvalues))
            matchingDatabaseFound = 1;
    else
        clear dataBase2D;
    end
end
if (matchingDatabaseFound == 0)
    % We can't find a dictionary matching our scan parameters - create new
    % one.
    dataBase2D.TR = TR;
    dataBase2D.TE = TE;
    dataBase2D.Tg = Tg;
    dataBase2D.GhArea = GhArea;
    dataBase2D.GlArea = GlArea;
    dataBase2D.alpha_deg = alpha_deg;
    dataBase2D.alphaFracValues = alphaFracValues;
    dataBase2D.Nstates = Nstates;
    dataBase2D.T1values = T1values;
    dataBase2D.T2values = T2values;
    dataBase2D.Dvalues = Dvalues;
    disp('Creating grid...');
    dataBase2D.bGrid_alpha_ADC_B1 = cell(NalphaFrac,1);
    dataBase2D.r1Grid2D_alpha_B1 = cell(NalphaFrac,1);
    dataBase2D.r2Grid2D_alpha_B1 = cell(NalphaFrac,1);
    
    for (na = 1:NalphaFrac)
        disp(['(', num2str(na/NalphaFrac*100), '% ...)']);
        alphaFracValues(na)
        gridDataSpH = zeros(NT1,NT2,ND);
        gridDataSmH = zeros(NT1,NT2,ND);
        gridDataSpL = zeros(NT1,NT2,ND);
        gridDataSmL = zeros(NT1,NT2,ND);
        bGrid_alpha_ADC = zeros(ND);
        r1Grid2D_alpha = zeros(NT2,ND);
        r2Grid2D_alpha = zeros(NT2,ND);
        for (nt1 = 1:NT1)
            %nt1
            for (nt2 = 1:NT2)
                %nt2
                for (nd = 1:ND)
                    [SpH,SmH] = computeEchoesEPG(T1values(nt1),T2values(nt2),TR,TE,alpha_deg*alphaFracValues(na),Gh,Tg,Dvalues(nd),Nstates);
                    [SpL,SmL] = computeEchoesEPG(T1values(nt1),T2values(nt2),TR,TE,alpha_deg*alphaFracValues(na),Gl,Tg,Dvalues(nd),Nstates);

                    gridDataSpH(nt1,nt2,nd) = SpH;
                    gridDataSmH(nt1,nt2,nd) = SmH;
                    gridDataSpL(nt1,nt2,nd) = SpL;
                    gridDataSmL(nt1,nt2,nd) = SmL;
                end
            end
        end

        bGrid = abs((gridDataSmH.*gridDataSpL)./(gridDataSmL.*gridDataSpH));
        bGrid1D = squeeze(mean(mean(bGrid,2),1));

        r1Grid = abs(gridDataSmH./gridDataSmL);
        r2Grid = abs(gridDataSmL./gridDataSpL);
        r1Grid2D = squeeze(mean(r1Grid,1));
        r2Grid2D = squeeze(mean(r2Grid,1));

        bGrid_alpha_ADC = bGrid1D;

        r1Grid2D_alpha = r1Grid2D;
        r2Grid2D_alpha = r2Grid2D;
        
        dataBase2D.bGrid_alpha_ADC_B1{na} = bGrid_alpha_ADC;
        dataBase2D.r1Grid2D_alpha_B1{na} = r1Grid2D_alpha;
        dataBase2D.r2Grid2D_alpha_B1{na} = r2Grid2D_alpha;
        

    end
    
    save(filestr,'dataBase2D');
end


% These contain measured ratios
bMeasured = (e2_H.*e1_L)./(e2_L.*e1_H);
r1Measured = abs(e2_H./e2_L);
r2Measured = abs(e2_L./e1_L);

% These will contain parameter estimates.
adcFitBieri = zeros(size(e1_H));
t2Fit2D = zeros(size(e1_H));
adcFit2D = zeros(size(e1_H));


for (xx = 1:size(bMeasured,2))
    for (yy = 1:size(bMeasured,1))
        
        % Select the bGrid_alpha_ADC, r1Grid2D_alpha, and r2Grid2D_alpha
        % that applies to the flip angle value at the pixel.
        [minVal,minInd] = min(abs(alphaFracValues - b1Map(yy,xx)));
        
        bGrid_alpha_ADC = dataBase2D.bGrid_alpha_ADC_B1{minInd};
        r1Grid2D_alpha = dataBase2D.r1Grid2D_alpha_B1{minInd};
        r2Grid2D_alpha = dataBase2D.r2Grid2D_alpha_B1{minInd};

        % Find the index of the Bieri ratio dictionary array that best
        % matches the ratio measured at the pixel.
        [m,ind] = min(abs(bMeasured(yy,xx) - squeeze(bGrid_alpha_ADC(:,1))));
   
        % Assign the estimated diffusion at that pixel as the diffusion
        % corresponding to that the index found above.
        adcFitBieri(yy,xx) = Dvalues(ind);

        
        % Repeat the procedure of finding best matching index, but now do
        % it in 2D.
        r1diffMatrix = r1Measured(yy,xx) - squeeze(r1Grid2D_alpha(:,:,1));
        r2diffMatrix = r2Measured(yy,xx) - squeeze(r2Grid2D_alpha(:,:,1));

        [m,ind2] = min(sqrt(abs(r1diffMatrix(:)).^2 + abs(r2diffMatrix(:)).^2));
        [nt2,nd] = ind2sub([NT2,ND],ind2);
        t2Fit2D(yy,xx) = T2values(nt2);
        adcFit2D(yy,xx) = Dvalues(nd);   
    end
end