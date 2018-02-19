%
%	function [A,B] = epg_sm_rf(alpha,phi,N)
%
%	Function generates propagation matrix A and vector B so
%	that the effect of an RF pulse 
%	is modeled by F' = A*F+B, where
%
%	F is a vector of EPG F+, F- and Z states 0 to N-1 of the form:
%		F = [ Fp; Fm; Z ]
%	
%	and Fp = [real(Fp1);imag(Fp1);real(Fp2);imag(Fp2);...imag(Fp(N-1))]
%	and Fm = [real(Fm1);imag(Fm1);real(Fm2);imag(Fm2);...imag(Fm(N-1))]
%	and z  = [real( Z1);imag( Z1);real( Z2);imag( Z2);...imag( Z(N-1))]
%

function [A,B] = epg_sm_rf(alpha,phi,N)

[F,RR] = epg_rf([0;0;0],alpha,phi);

% --- Split up rotation matrix over N states, 
%	also with complex values expressed as a+bi
%

AA = zeros(2*N,2*N,9);

for (k=1:9)
  % -- matrix to relate [real;imag] = R*[real;imag]
  a = [real(RR(k)) -imag(RR(k)); imag(RR(k)) real(RR(k))];
  b = {a};
  for q=2:N
    b = {b{:} a};	% -- List of 2x2 blocks.
  end;
  AA(:,:,k) = blkdiag(b{:});
end;

% -- Assemble 3x3 blocks into matrix A.
A = [ 	[AA(:,:,1) AA(:,:,4) AA(:,:,7)]; 
	[AA(:,:,2) AA(:,:,5) AA(:,:,8)]; 	
	[AA(:,:,3) AA(:,:,6) AA(:,:,9)] ];
B = 0*A(:,1);	% -- No recovery term during RF.


