%
% Testing a simple T2d fit by fitting the singal decay to an exponential
% curve and solving for T2, thereby ignoring any diffusion effects
%
%
% Sp = M0*exp(-TE1/T2)
% Sm = M0*exp(-TE2/T2)
% Sp/Sm = exp((TE2-TE1)/T2)
% ln(Sp/Sm) = (TE2-TE1)/T2
% T2 = (TE2-TE1)/ln(Sp/Sm)

function [T2map] = fitT2d(Sp_image,Sm_image,TR,TE1,TE2)

T2map = (TE2-TE1)./log(abs(Sp_image)./abs(Sm_image));