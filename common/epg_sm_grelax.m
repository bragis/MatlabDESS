%
%	function [A,B] = epg_sm_grelax(EE,BV,D,Gon)
%
%	Function generates propagation matrix A and vector B so
%	that the effect of diffusion and (an optional)  gradient 
%	are modeled by F' = A*F+B, where
%
%	F is a vector of EPG F+, F- and Z states 0 to N-1 of the form:
%		F = [ Fp; Fm; Z ]
%	
%	and Fp = [real(Fp1);imag(Fp1);real(Fp2);imag(Fp2);...imag(Fp(N-1))]
%	and Fm = [real(Fm1);imag(Fm1);real(Fm2);imag(Fm2);...imag(Fm(N-1))]
%	and z  = [real( Z1);imag( Z1);real( Z2);imag( Z2);...imag( Z(N-1))]
%

function [A,B] = epg_sm_grelax(EE,BV,D,Gon)

[M,N] = size(BV);

% -- Relaxation:
Em = EE*ones(size(BV)); Em=[Em Em];		% -- Decay, all states
Em = Em.';
Ar = diag([Em(:)]);				% -- Diagonal decay

% -- Recovery:
Dm = 0*Em; Dm(1,3)=1-EE(3,3); 			% -- Recovery, only real(Z0)
Br = Dm(:);                             % -- Zeros except Z0

% -- Diffusion:
BV = cat(3,BV,BV); BV = permute(BV,[3,2,1]);
Ad = diag(exp(-([BV(:)]*D)));
Bd = 0*Br;

% -- Gradient Dephasing Propagation for F+ and F- states:
ud = eye(2*N-2); ud(2*N,2*N)=0; ud = circshift(ud,[0,2]);	
ld = ud.';

% -- Combine matrices
A = Ad*Ar;
B = Ad*Br+Bd;

% -- Add propagation to next dephased states if gradient on.
if (Gon)
  Ag = blkdiag(ld,ud,eye(2*N));
  Ag(1,2*N+3) =1; Ag(2,2*N+4)=-1;		% Fp0 = conj(Fm(-1))
  A = Ag*A;
  B = Ag*B;
  
end;


 
