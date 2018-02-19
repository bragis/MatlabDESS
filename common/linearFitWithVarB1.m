% S1p_image: First echo of the strongly diffusion weighted sequence
% S1m_image: Second echo of the strongly diffusion weighted sequence
% S2p_image: First echo of the weakly diffusion weighted sequence
% S2m_image: Second echo of the weakly diffusion weighted sequence

function [T2map,DDmap,T1map] = linearFitWithVarB1WithThres(S1p_image,S1m_image,S2p_image,S2m_image,T1T2DDspaces,alpha1Array,alpha1Matrix)

S1p = double(S1p_image);
S1m = double(S1m_image);
S2p = double(S2p_image);
S2m = double(S2m_image);

N = size(S1p,1);
M = size(S1p,2);

for (r=1:length(alpha1Array))
    SC1matrix{r} = abs(T1T2DDspaces{r}(:,:,:,5))./abs(T1T2DDspaces{r}(:,:,:,4));
    SC2matrix{r} = abs(T1T2DDspaces{r}(:,:,:,7))./abs(T1T2DDspaces{r}(:,:,:,6));
    SC3matrix{r} = abs(T1T2DDspaces{r}(:,:,:,4))./abs(T1T2DDspaces{r}(:,:,:,6));
end

T1map = zeros(N,M);
T2map = zeros(N,M);
DDmap = zeros(N,M);

noiseThreshold = 0;

tic
for (p=1:N)
    for (q=1:M)
        
        % Check if the signal is too noisy
        if (S1p(p,q) > noiseThreshold)
            % Find the space that best fits the pixel by determining which flip
            % angle in alpha1Array is closest to the flip angle of the pixel
            [minVal,minInd] = min(abs(alpha1Array-alpha1Matrix(p,q)));
%             if ((p==97)&&(q==145))
%                 disp('For x = 145, y = 97');
%                 alpha1Array'
%                 alpha1Matrix(p,q)
%                 disp(['minVal = ', num2str(minVal)]);
%                 disp(['minInd = ', num2str(minInd)]);
%             end

            [i,j,k] = linearSearch(S1p(p,q),S1m(p,q),S2p(p,q),S2m(p,q),SC1matrix{minInd},SC2matrix{minInd},SC3matrix{minInd});

            T1map(p,q) = T1T2DDspaces{minInd}(i,j,k,1);
            T2map(p,q) = T1T2DDspaces{minInd}(i,j,k,2);
            DDmap(p,q) = T1T2DDspaces{minInd}(i,j,k,3);
        else
            T1map(p,q) = 0;
            T2map(p,q) = 0;
            DDmap(p,q) = 0;
        end
    end
    disp(['Have fitted ', num2str(p/N*100), '% of image']);
end
t = toc;
disp(['Fitting the image (',num2str(numel(S1p_image)),' points) took ', num2str(t),' seconds.']);