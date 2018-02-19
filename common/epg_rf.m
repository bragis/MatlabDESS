function [FpFmZ,RR] = epg_rf(FpFmZ,alpha,phi)
%
%	Propagate EPG states through an RF rotation of 
%	alpha, with phase phi (both radians).
%	
%	INPUT:
%		FpFmZ = 3xN vector of F+, F- and Z states.
%

% -- From Weigel at al, JMR 205(2010)276-285, Eq. 8.

RR = [(cos(alpha/2))^2 exp(2*i*phi)*(sin(alpha/2))^2 -i*exp(i*phi)*sin(alpha);
      exp(-2*i*phi)*(sin(alpha/2))^2 (cos(alpha/2))^2 i*exp(-i*phi)*sin(alpha);
      -i/2*exp(-i*phi)*sin(alpha) i/2*exp(i*phi)*sin(alpha)      cos(alpha)];


FpFmZ = RR * FpFmZ;


