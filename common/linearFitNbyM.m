function [T2map,DDmap,T1map] = linearFitNbyM(S1p_image,S1m_image,S2p_image,S2m_image,T1T2DDspace)

S1p = double(S1p_image);
S1m = double(S1m_image);
S2p = double(S2p_image);
S2m = double(S2m_image);

N = size(S1p,1);
M = size(S1p,2);

SC1matrix = abs(T1T2DDspace(:,:,:,5))./abs(T1T2DDspace(:,:,:,4));
SC2matrix = abs(T1T2DDspace(:,:,:,7))./abs(T1T2DDspace(:,:,:,6));
SC3matrix = abs(T1T2DDspace(:,:,:,4))./abs(T1T2DDspace(:,:,:,6));

T1map = zeros(N,M);
T2map = zeros(N,M);
DDmap = zeros(N,M);

tic
for (p=1:N)
    for (q=1:M)
        
        [i,j,k] = linearSearch(S1p(p,q),S1m(p,q),S2p(p,q),S2m(p,q),SC1matrix,SC2matrix,SC3matrix);
        
        T1map(p,q) = T1T2DDspace(i,j,k,1);
        T2map(p,q) = T1T2DDspace(i,j,k,2);
        DDmap(p,q) = T1T2DDspace(i,j,k,3);
    end
    disp(['Have fitted ', num2str(p/N*100), '% of image']);
end
t = toc;
disp(['Fitting the image (',num2str(numel(S1p_image)),' points) took ', num2str(t),' seconds.']);