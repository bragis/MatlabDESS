function [T2images,DDimages,T1images] = createTestParameterMaps(T1min,T1max,T2min,T2max,DDmin,DDmax,Npixels1D,nSteps)

pointsInStep = floor(Npixels1D/nSteps);

T1image = ones(Npixels1D,Npixels1D);
T2image = ones(Npixels1D,Npixels1D);
DDimage = ones(Npixels1D,Npixels1D);

T1array = [T1min:(T1max-T1min)/(Npixels1D-1):T1max];
T2array = [T2min:(T2max-T2min)/(Npixels1D-1):T2max];
DDarray = [DDmin:(DDmax-DDmin)/(Npixels1D-1):DDmax];


T1array = floor((T1array-T1min)/((T1max-T1min)/nSteps))*((T1max-T1min)/nSteps)+T1min;
T2array = floor((T2array-T2min)/((T2max-T2min)/nSteps))*((T2max-T2min)/nSteps)+T2min;
DDarray = floor((DDarray-DDmin)/((DDmax-DDmin)/nSteps))*((DDmax-DDmin)/nSteps)+DDmin;

[T2images,DDimages,T1images] = meshgrid(T2array,DDarray,T1array);