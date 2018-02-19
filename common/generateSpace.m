% T1start: Minimum T1 value (seconds)
% T1end: Maximum T1 value (seconds)
% NT1points: Number of different T1 values
% T2start: Minimum T2 value (seconds)
% T2end: Maximum T2 value (seconds)
% NT2points: Number of different T2 values
% DDstart: Minimum DD value (m^2/s)
% DDend: Maximum DD value (m^2/s)
% NDDpoints: Number of different DD values
%
% TR: Repetition time of sequence (seconds)
% TE: Echo time of sequence (seconds)
% Tg: Gradient duration (seconds)
% alpha1: Flip angle of strongly diffusion weighted sequence (degrees)
% G1: Gradient amplitude of strongly diffusion weighted sequence (Gauss/m)
% alpha2: Flip angle of weakly diffusion weighted sequence (degrees)
% G2: Gradient amplitude of weakly diffusion weighted sequence (Gauss/m)
%
% Nstates: Number of phase states (only used in EPG model)
% signalModel: Signal model to use (0=EPG, 1=Wu-Buxton)
%
% Example: T1T2DDspace = generateSpace(0.25, 1.5, 100, 0.001, 0.1, 100, ...
% 0.001e-9, 2.5e-9, 200, 0.0203, 0.008, 18.0, 607.73, 35.0, 303.86, ...
% 0.0014, 6, 1);
%

function [T1T2DDspace] = generateSpace(T1start,T1end,NT1points,T2start,...
    T2end,NT2points,DDstart,DDend,NDDpoints,TR,TE,alpha1,G1,alpha2,G2,...
    Tg,Nstates,signalModel)

T1values = [T1start:(T1end-T1start)/(NT1points-1):T1end];
T2values = [T2start:(T2end-T2start)/(NT2points-1):T2end];
DDvalues = [DDstart:(DDend-DDstart)/(NDDpoints-1):DDend];

T1T2DDspace = zeros(NT1points,NT2points,NDDpoints,7);

disp('Generating space...');
c = 0;
numpoints = NT1points*NT2points*NDDpoints;
tic;
for (i=1:NT1points)
    T1_ijk = T1values(i);
    for (j=1:NT2points)
        T2_ijk = T2values(j);
        for (k=1:NDDpoints)
            DD_ijk = DDvalues(k);
            
            if (signalModel == 0)
                [S1p,S1m] = computeEchoesEPG(T1_ijk,T2_ijk,TR,TE,alpha1,G1,Tg,DD_ijk,Nstates);
                [S2p,S2m] = computeEchoesEPG(T1_ijk,T2_ijk,TR,TE,alpha2,G2,Tg,DD_ijk,Nstates);
            else
                [S1p,S1m] = computeEchoesWuBuxton(alpha1,TR,G1,Tg,(TR-Tg)/2,TE,2*TR-TE,T1_ijk,T2_ijk,DD_ijk);
                [S2p,S2m] = computeEchoesWuBuxton(alpha2,TR,G2,Tg,(TR-Tg)/2,TE,2*TR-TE,T1_ijk,T2_ijk,DD_ijk);
            end
            
            T1T2DDspace(i,j,k,1) = T1_ijk;
            T1T2DDspace(i,j,k,2) = T2_ijk;
            T1T2DDspace(i,j,k,3) = DD_ijk;
            
            T1T2DDspace(i,j,k,4) = S1p;
            T1T2DDspace(i,j,k,5) = S1m;
            T1T2DDspace(i,j,k,6) = S2p;
            T1T2DDspace(i,j,k,7) = S2m;
            
            c = c+1;
            if (mod(c*100,numpoints)==0)
                disp(['Done with computing ', num2str(c/numpoints*100),'% of space']);
            end
        end
    end
end
t = toc;
disp(['Generating space with ', num2str(numpoints), ' points took ', num2str(t), ' seconds.']);