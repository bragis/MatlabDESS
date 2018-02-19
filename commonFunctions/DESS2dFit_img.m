function [adcFitBieri,t2Fit2D,adcFit2D] = DESS2dFit_img(TR,TE,Tg,GhArea,GlArea,alpha_deg,Nstates,e1_H,e2_H,e1_L,e2_L)

% Compute the gradient amplitudes in G/m
Gh = GhArea/(Tg*1e6)*100;
Gl = GlArea/(Tg*1e6)*100;


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

gridDataSpH = zeros(NT1,NT2,ND);
gridDataSmH = zeros(NT1,NT2,ND);
gridDataSpL = zeros(NT1,NT2,ND);
gridDataSmL = zeros(NT1,NT2,ND);


bGrid_alpha_ADC = zeros(1,ND);
r1Grid2D_alpha = zeros(NT2,ND);
r2Grid2D_alpha = zeros(NT2,ND);

filestr = ['dataBases/signalDatabase', num2str(GhArea), '.mat'];

matchingDatabaseFound = 0;

if (exist(filestr) == 2)
	% We've found a dictionary that might match - let's load it and check
    % its parameters.
    load(filestr);
    if ((dataBase2D.TR == TR) && (dataBase2D.TE == TE) && (dataBase2D.Tg == Tg) ...
        && (dataBase2D.GhArea == GhArea) && (dataBase2D.GlArea == GlArea) && (dataBase2D.alpha_deg == alpha_deg) ...
        && (dataBase2D.Nstates == Nstates) ...
        && isequal(dataBase2D.T1values,T1values) && isequal(dataBase2D.T2values,T2values) && isequal(dataBase2D.Dvalues,Dvalues))
            matchingDatabaseFound = 1;
            bGrid_alpha_ADC = dataBase2D.bGrid_alpha_ADC;
            r1Grid2D_alpha = dataBase2D.r1Grid2D_alpha;
            r2Grid2D_alpha = dataBase2D.r2Grid2D_alpha;
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
    dataBase2D.alphaFracValues = 1;
    dataBase2D.Nstates = Nstates;
    dataBase2D.T1values = T1values;
    dataBase2D.T2values = T2values;
    dataBase2D.Dvalues = Dvalues;
    disp('Creating grid...');


    for (nt1 = 1:NT1)
        for (nt2 = 1:NT2)
            for (nd = 1:ND)
                [SpH,SmH] = computeEchoesEPG(T1values(nt1),T2values(nt2),TR,TE,alpha_deg,Gh,Tg,Dvalues(nd),Nstates);
                [SpL,SmL] = computeEchoesEPG(T1values(nt1),T2values(nt2),TR,TE,alpha_deg,Gl,Tg,Dvalues(nd),Nstates);

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

    r2Grid1D_alpha = squeeze(mean(r2Grid2D_alpha,2));

    dataBase2D.bGrid_alpha_ADC = bGrid_alpha_ADC;
	dataBase2D.r1Grid2D_alpha = r1Grid2D_alpha;
    dataBase2D.r2Grid2D_alpha = r2Grid2D_alpha;
    
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
        % Find the index of the Bieri ratio dictionary array that best
        % matches the ratio measured at the pixel.
        [m,ind] = min(abs(bMeasured(yy,xx) - squeeze(bGrid_alpha_ADC)));

        % Assign the estimated diffusion at that pixel as the diffusion
        % corresponding to that the index found above.
        adcFitBieri(yy,xx) = Dvalues(ind);

        % Repeat the procedure of finding best matching index, but now do
        % it in 2D.
        r1diffMatrix = r1Measured(yy,xx) - squeeze(r1Grid2D_alpha);
        r2diffMatrix = r2Measured(yy,xx) - squeeze(r2Grid2D_alpha);

        [m,ind2] = min(sqrt(abs(r1diffMatrix(:)).^2 + abs(r2diffMatrix(:)).^2));
        [nt2,nd] = ind2sub([NT2,ND],ind2);
        t2Fit2D(yy,xx) = T2values(nt2);
        adcFit2D(yy,xx) = Dvalues(nd);  
 
    end
end