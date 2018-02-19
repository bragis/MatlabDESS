function [] = fitSliceOneTouch2D(nDessSlice,examPath,seriesNo)


stringHLdir = [examPath,seriesNo.HiLo];
echo1HLInfo = dicominfo([stringHLdir,'I',sprintf('%04d',1*2-1),'.dcm']);
echo1HLOneTouchInfo = echo1HLInfo.Private_0043_1038;
tempAngleA = double(echo1HLOneTouchInfo(20));
tempGxAreaA = echo1HLInfo.GxArea;
tempGyAreaA = echo1HLInfo.GyArea;
tempGzAreaA = echo1HLInfo.GzArea;
%tempAngleA = 25;
%tempGxAreaA = 0;
%tempGyAreaA = 0;
%tempGzAreaA = 1566;
tempGAreaA = sqrt(tempGxAreaA^2 + tempGyAreaA^2 + tempGzAreaA^2);
tempAngleB = double(echo1HLOneTouchInfo(21));
tempGxAreaB = double(echo1HLOneTouchInfo(22));
tempGyAreaB = double(echo1HLOneTouchInfo(23));
tempGzAreaB = double(echo1HLOneTouchInfo(24));
%tempAngleB = 25;
%tempGxAreaB = 0;
%tempGyAreaB = 0;
%tempGzAreaB = 15660;
tempGAreaB = sqrt(tempGxAreaB^2 + tempGyAreaB^2 + tempGzAreaB^2);


TR = echo1HLInfo.RepetitionTime/1000
TE = echo1HLInfo.EchoTime/1000
Tg = echo1HLInfo.Tg/1e6

Nstates = 6;

numDessSlices = echo1HLInfo.Private_0021_104f
numDessSlices = numDessSlices(1)

echo1A = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
echo1A = double(echo1A);
echo2A = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',nDessSlice*2),'.dcm']);
echo2A = double(echo2A);
echo1B = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',(nDessSlice + numDessSlices)*2-1),'.dcm']);
echo1B = double(echo1B);
echo2B = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',(nDessSlice + numDessSlices)*2),'.dcm']);
echo2B = double(echo2B);



if (tempGAreaA > tempGAreaB)
    disp('This was done in the order high-low');
    alphah_deg = tempAngleA;                         % Degrees
    alphal_deg = tempAngleB;                         % Degrees
    GhArea = tempGAreaA;
    GlArea = tempGAreaB;
    
    echo1H = echo1A;
    echo2H = echo2A;
    echo1L = echo1B;
    echo2L = echo2B;
else
    disp('This was done in the order low-high');
    alphah_deg = tempAngleB;                         % Degrees
    alphal_deg = tempAngleA;                         % Degrees
    GhArea = tempGAreaB;
    GlArea = tempGAreaA;
    
    echo1H = echo1B;
    echo2H = echo2B;
    echo1L = echo1A;
    echo2L = echo2A;
end
alphah_deg
alphal_deg
GhArea
GlArea




% Do the parameter fit.
[adcFitBieri_notCorr,t2Fit2D_notCorr,adcFit2D_notCorr] = DESS2dFit_img(TR,TE,Tg,GhArea,GlArea,alphal_deg,Nstates,echo1H,echo2H,echo1L,echo2L);

assumedT1 = 1.2;
t2FitWelschNew_notCorr = -2*(TR-TE)./log(echo2L./(echo1L * (sind(alphal_deg/2)).^2 * (1 + exp(-TR/assumedT1))/(1 - cosd(alphal_deg)*exp(-TR/assumedT1))));


disp('Done fitting slice');



% Mask out noise
M = ones(size(echo1L));
M(echo1L < 0.15*max(abs(echo1L(:)))) = 0;

adcFitBieri_notCorr = adcFitBieri_notCorr .* M;
adcFit2D_notCorr = adcFit2D_notCorr .* M;
t2Fit2D_notCorr = t2Fit2D_notCorr .* M;
t2FitWelschNew_notCorr = t2FitWelschNew_notCorr .* M;




% Write to dicoms

% ADC fit with "Bieri method"
adcFitBieri_notCorr_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['adc_bieri_m_sl',num2str(nDessSlice)];
str2 = 'adc_bieri_m';
adcFitBieri_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
adcFitBieri_notCorr_info.SeriesNumber = adcFitBieri_notCorr_info.SeriesNumber*1000 + 20;
adcFitBieri_notCorr_info.ImagesInAcquisition = 1;
adcFitBieri_notCorr_info.SeriesDescription = [str2];
adcFitBieri_notCorr_ForDicom = adcFitBieri_notCorr/65535*1e12;
dicomwrite(adcFitBieri_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],adcFitBieri_notCorr_info);

% ADC fit with "Toronto method"
adcFit2D_notCorr_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['adc_2d_m_sl',num2str(nDessSlice)];
str2 = 'adc_2d_m';
adcFit2D_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
adcFit2D_notCorr_info.SeriesNumber = adcFit2D_notCorr_info.SeriesNumber*1000 + 30;
adcFit2D_notCorr_info.ImagesInAcquisition = 1;
adcFit2D_notCorr_info.SeriesDescription = [str2];
adcFit2D_notCorr_ForDicom = adcFit2D_notCorr/65535*1e12;
dicomwrite(adcFit2D_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],adcFit2D_notCorr_info);

% T2 fit with "Toronto method"
t2Fit2D_notCorr_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t2_2d_m_sl',num2str(nDessSlice)];
str2 = 't2_2d_m';
t2Fit2D_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
t2Fit2D_notCorr_info.SeriesNumber = t2Fit2D_notCorr_info.SeriesNumber*1000 + 50;
t2Fit2D_notCorr_info.ImagesInAcquisition = 1;
t2Fit2D_notCorr_info.SeriesDescription = [str2];
t2Fit2D_notCorr_ForDicom = t2Fit2D_notCorr/65535*1000;
dicomwrite(t2Fit2D_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],t2Fit2D_notCorr_info);

% T2 fit with improved Welsch's method
t2FitWelschNew_notCorr_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t2_Welsch_new_sl',num2str(nDessSlice)];
str2 = 't2_Welsch_new';
t2FitWelschNew_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
t2FitWelschNew_notCorr_info.SeriesNumber = t2FitWelschNew_notCorr_info.SeriesNumber*1000 + 70;
t2FitWelschNew_notCorr_info.ImagesInAcquisition = 1;
t2FitWelschNew_notCorr_info.SeriesDescription = [str2];
t2FitWelschNew_notCorr_ForDicom = t2FitWelschNew_notCorr/65535*1000;
% adcFitBieri_20_notCorr_ForDicom = adcFitBieri_20_notCorr*1e12;
dicomwrite(t2FitWelschNew_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],t2FitWelschNew_notCorr_info);
