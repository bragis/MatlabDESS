%
%   function [S1,S2] = computeEchoesEPG(T1,T2,TR,TE,alpha,G,Tg,D,NS)
%
%	EPG Simulation of DESS (Double-Echo in Steady State), using
%	a steady state matrix formulation of EPG.
%
%   This function used to be called epg_dess_mat2
%
%	Sequence is alpha - TE - Tx - Tg - Tx - TE  (Duration TR)
%
%	TE = echo time, Tg = gradient time, Tx = (TR-Tg)/2-TE (all seconds)
%	G = G/m, alpha=degrees.
%	T1,T2 = seconds
%	D = ADC, m^2/s
%	NS = number of F,Z states in simulation
%

function [S1,S2] = computeEchoesEPG(T1,T2,TR,TE,alpha,G,Tg,D,NS)

%--For testing as script
%D = 2*10^(-9);  % Diffusion (m^2/s)
%TR = .02;       % 30ms
%TE = 0.000;     % 0ms
%
%G = 1000;               % G/m 
%Tg = .001;      % Gradient Duration (s)
%T1 = 0.29;      % s
%T2 = .26;       % s
%
%alpha = 20;
if (nargin < 9) NS=6; end;

alpha = pi/180*alpha;	% to radians.
gamma = 4258*2*pi;	% Gamma, Rad/(G*s).

noadd=1;
dk = gamma*G*Tg;

% ======== FIRST SET UP DUMMY MATRICES FOR PROPAGATION ============

FpFmZ = [0;0;1];	% Equilibrium Magnetization.
			% [F+; F-; Z],  all longitudinal in Z0 state.

FpFmZ(1,NS)=0;	% Allocate NS states.
F=FpFmZ;		% Dummy argument

[A1,B1] = epg_sm_rf(alpha,0,NS);		% Get RF propagation.

% -- GET PROPAGATION MATRICES FOR SEGMENTS:
%	-- 0 to TE1
[FF,EEa,BVa] = epg_grelax(F,T1,T2,TE,dk ,D,0,noadd);	
[A2,B2] = epg_sm_grelax(EEa,BVa,D,0);

% -- TE1 to gradient
[FF,EEb,BVb] = epg_grelax(F,T1,T2,(TR-Tg)/2-TE,dk ,D,0,noadd);	
[A3,B3] = epg_sm_grelax(EEb,BVb,D,0);

%	-- Gradient
[FF,EEc,BVc] = epg_grelax(F,T1,T2,Tg,dk ,D,1,noadd);	
[A4,B4] = epg_sm_grelax(EEc,BVc,D,1);

%	-- Gradient end to TE2
[FF,EEd,BVd] = epg_grelax(F,T1,T2,(TR-Tg)/2-TE,dk ,D,0,noadd);	
[A5,B5] = epg_sm_grelax(EEd,BVd,D,0);

%	-- TE2 to end
[FF,EEe,BVe] = epg_grelax(F,T1,T2,TE,dk ,D,0,noadd);	
[A6,B6] = epg_sm_grelax(EEe,BVe,D,0);



% -- Steady State at 1st Echo:
AA = A2*A1*A6*A5*A4*A3;
BB = A2*(A1*(A6*(A5*(A4*B3+B4)+B5)+B6)+B1)+B2;


%F1 = inv(eye(6*NS)-AA)*BB; 
F1 = (eye(6*NS)-AA)\BB;            % Backslash is quicker than inv



% -- To 2nd Echo
AA1 = A5*A4*A3;
BB1 = A5*(A4*B3+B4)+B5;

F2 = AA1*F1+BB1;


S1 = F1(1)+i*F1(2);
S2 = F2(1)+i*F2(2);






