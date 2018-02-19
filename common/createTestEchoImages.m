function [S1p_image,S1m_image,S2p_image,S2m_image] = createTestEchoImages(T1originalMap,T2originalMap,DDoriginalMap,TR,TE,Tg,alpha1,G1,alpha2,G2,NS,l,method)

% Old definition: createTestEchoImages(TR,TE,Tg,alpha1,G1,alpha2,G2,NS,method,T2originalMap,DDoriginalMap,T1originalMap)

N = size(T1originalMap,1);
M = size(T1originalMap,2);
S1p = zeros(N,N);
S1m = zeros(N,N);
S2p = zeros(N,N);
S2m = zeros(N,N);

T1 = T1originalMap(1,1);

for (n=[1:N])
    for (m=[1:M])
        T2 = T2originalMap(n,m);
        DD = DDoriginalMap(n,m);
        if (method == 0)    % EPG
            [S1p,S1m] = computeEchoesEPG(T1,T2,TR,TE,alpha1,G1,Tg,DD,NS);
            [S2p,S2m] = computeEchoesEPG(T1,T2,TR,TE,alpha2,G2,Tg,DD,NS);
        elseif (method == 1)
            [S1p,S1m] = computeEchoesWuBuxton(alpha1,TR,G1,Tg,(TR-Tg)/2,TE,2*TR-TE,T1,T2,DD);
            [S2p,S2m] = computeEchoesWuBuxton(alpha2,TR,G2,Tg,(TR-Tg)/2,TE,2*TR-TE,T1,T2,DD);
        else
            [S1p,S1m] = computeEchoesFreed(alpha1,TR,G1,TE,2*TR-TE,T1,T2,DD,l);
            [S2p,S2m] = computeEchoesFreed(alpha2,TR,G2,TE,2*TR-TE,T1,T2,DD,l);
        end
        S1p_image(n,m) = S1p;
        S1m_image(n,m) = S1m;
        S2p_image(n,m) = S2p;
        S2m_image(n,m) = S2m;
    end
end