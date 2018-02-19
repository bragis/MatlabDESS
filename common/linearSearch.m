function [i,j,k] = linearSearch(S1p,S1m,S2p,S2m,SC1matrix,SC2matrix,SC3matrix)

if ((S1p==0)&&(S1m==0)&&(S2p==0)&&(S2m==0))
    i = 1;
    j = 1;
    k = 1;
    return;
end

SC1 = SC(S1m,S1p);
SC2 = SC(S2m,S2p);
SC3 = SC(S1p,S2p);

R = sqrt((SC1-SC1matrix).^2 + (SC2-SC2matrix).^2 + (SC3-SC3matrix).^2);
[min_val,pos] = min(R(:));
[i,j,k] = ind2sub(size(R),pos);