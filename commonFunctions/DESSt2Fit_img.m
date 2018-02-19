function [t2Fit] = DESSt2Fit_img(TR,TE,Tg,GlArea,alpha_deg,Nstates,assumedT1,e1_L,e2_L)

% Compute the gradient amplitudes in G/m
Gl = GlArea/(Tg*1e6)*100;



T2start = 0.01;
% T2end = 0.08;
T2end = 0.1;
NT2 = 90;
T2values = [T2start:(T2end-T2start)/(NT2-1):T2end];


gridDataSpL = zeros(NT2,1);
gridDataSmL = zeros(NT2,1);


r1Grid1D_alpha = zeros(NT2,1);

filestr = ['dataBases/signalDatabase', num2str(GlArea), '.mat'];

matchingDatabaseFound = 0;

if (exist(filestr) == 2)
	% We've found a dictionary that might match - let's load it and check
    % its parameters.
    load(filestr);
    if ((dataBase1D.TR == TR) && (dataBase1D.TE == TE) && (dataBase1D.Tg == Tg) ...
        && (dataBase1D.GlArea == GlArea) && (dataBase1D.alpha_deg == alpha_deg) ...
        && (dataBase1D.Nstates == Nstates) ...
        && isequal(dataBase1D.T2values,T2values))
            matchingDatabaseFound = 1;
            r1Grid1D_alpha = dataBase1D.r1Grid1D_alpha;
    else
        clear dataBase1D;
    end
end
if (matchingDatabaseFound == 0)
    % We can't find a dictionary matching our scan parameters - create new
    % one.
    dataBase1D.TR = TR;
    dataBase1D.TE = TE;
    dataBase1D.Tg = Tg;
    dataBase1D.GlArea = GlArea;
    dataBase1D.alpha_deg = alpha_deg;
    dataBase1D.alphaFracValues = 1;
    dataBase1D.Nstates = Nstates;
    dataBase1D.T2values = T2values;
    disp('Creating grid...');


    for (nt2 = 1:NT2)
        [SpL,SmL] = computeEchoesEPG(assumedT1,T2values(nt2),TR,TE,alpha_deg,Gl,Tg,1e-12,Nstates);

        gridDataSpL(nt2) = SpL;
        gridDataSmL(nt2) = SmL;
    end


    r1Grid1D = abs(gridDataSmL./gridDataSpL);


    r1Grid1D_alpha = r1Grid1D;


	dataBase1D.r1Grid1D_alpha = r1Grid1D_alpha;
    
    save(filestr,'dataBase1D');
end




% These contain measured ratios    

r1Measured = abs(e2_L./e1_L);

% These will contain parameter estimates.
t2Fit = zeros(size(e1_L));


for (xx = 1:size(r1Measured,2))
    for (yy = 1:size(r1Measured,1))
        % Find the index of the Bieri ratio dictionary array that best
        % matches the ratio measured at the pixel.
        [m,ind] = min(abs(r1Measured(yy,xx) - squeeze(r1Grid1D_alpha)));

        % Assign the estimated diffusion at that pixel as the diffusion
        % corresponding to that the index found above.
        t2Fit(yy,xx) = T2values(ind);


 
    end
end