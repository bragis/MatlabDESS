function [] = fitSliceOneScanLookup(nDessSlice,examPath,seriesNo)


% echo1H = dicomread([examPath,seriesNo.Hi,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
% echo1H = double(echo1H);
% echo2H = dicomread([examPath,seriesNo.Hi,'I',sprintf('%04d',nDessSlice*2),'.dcm']);
% echo2H = double(echo2H);
echo1L = dicomread([examPath,seriesNo.Lo,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
echo1L = double(echo1L);
echo2L = dicomread([examPath,seriesNo.Lo,'I',sprintf('%04d',nDessSlice*2),'.dcm']);
echo2L = double(echo2L);



%%%%%%%%%%%%%%%%%
% stringHdir = [examPath,seriesNo.Hi];
stringLdir = [examPath,seriesNo.Lo];
% echo1H_info = dicominfo([stringHdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
echo1L_info = dicominfo([stringLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);

TR = echo1L_info.RepetitionTime/1000;
TE = echo1L_info.EchoTime/1000;
Tg = echo1L_info.Tg/1e6;
alpha_deg = echo1L_info.FlipAngle;                         % Degrees
Nstates = 6;
% GhArea = sqrt(echo1H_info.GxArea^2 + echo1H_info.GyArea^2 + echo1H_info.GzArea^2);
GlArea = sqrt(echo1L_info.GxArea^2 + echo1L_info.GyArea^2 + echo1L_info.GzArea^2);

% Temp fix
% Tg = 0.0034;
% GhArea = 15660;
% GlArea = 1566;


% Do the parameter fit.
% [adcFitBieri_notCorr,t2Fit2D_notCorr,adcFit2D_notCorr] = DESS2dFit_img(TR,TE,Tg,GhArea,GlArea,alpha_deg,Nstates,echo1H,echo2H,echo1L,echo2L);

alpha_deg_L = echo1L_info.FlipAngle;
assumedT1 = 1.2;

t2FitLookup = DESSt2Fit_img(TR,TE,Tg,GlArea,alpha_deg_L,Nstates,assumedT1,echo1L,echo2L);
%t2FitWelschNew_notCorr = -2*(TR-TE)./log(echo2L./(echo1L * (sind(alpha_deg_L/2)).^2 * (1 + exp(-TR/assumedT1))/(1 - cosd(alpha_deg_L)*exp(-TR/assumedT1))));


disp('Done fitting slice');



% Mask out noise
M = ones(size(echo1L));
M(echo1L < 0.15*max(abs(echo1L(:)))) = 0;

% adcFitBieri_notCorr = adcFitBieri_notCorr .* M;
% adcFit2D_notCorr = adcFit2D_notCorr .* M;
% t2Fit2D_notCorr = t2Fit2D_notCorr .* M;
t2FitLookup = t2FitLookup .* M;




% Write to dicoms

% % ADC fit with "Bieri method"
% adcFitBieri_notCorr_info = dicominfo([stringHdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
% str1 = ['adc_bieri_m_sl',num2str(nDessSlice)];
% str2 = 'adc_bieri_m';
% adcFitBieri_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
% adcFitBieri_notCorr_info.SeriesNumber = adcFitBieri_notCorr_info.SeriesNumber*1000 + 20;
% adcFitBieri_notCorr_info.ImagesInAcquisition = 1;
% adcFitBieri_notCorr_info.SeriesDescription = [str2];
% adcFitBieri_notCorr_ForDicom = adcFitBieri_notCorr/65535*1e12;
% dicomwrite(adcFitBieri_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],adcFitBieri_notCorr_info);
% 
% % ADC fit with "Toronto method"
% adcFit2D_notCorr_info = dicominfo([stringHdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
% str1 = ['adc_2d_m_sl',num2str(nDessSlice)];
% str2 = 'adc_2d_m';
% adcFit2D_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
% adcFit2D_notCorr_info.SeriesNumber = adcFit2D_notCorr_info.SeriesNumber*1000 + 30;
% adcFit2D_notCorr_info.ImagesInAcquisition = 1;
% adcFit2D_notCorr_info.SeriesDescription = [str2];
% adcFit2D_notCorr_ForDicom = adcFit2D_notCorr/65535*1e12;
% dicomwrite(adcFit2D_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],adcFit2D_notCorr_info);
% 
% % T2 fit with "Toronto method"
% t2Fit2D_notCorr_info = dicominfo([stringHdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
% str1 = ['t2_2d_m_sl',num2str(nDessSlice)];
% str2 = 't2_2d_m';
% t2Fit2D_notCorr_info.FileName = ['outputDicoms/', str1, '.dcm'];
% t2Fit2D_notCorr_info.SeriesNumber = t2Fit2D_notCorr_info.SeriesNumber*1000 + 50;
% t2Fit2D_notCorr_info.ImagesInAcquisition = 1;
% t2Fit2D_notCorr_info.SeriesDescription = [str2];
% t2Fit2D_notCorr_ForDicom = t2Fit2D_notCorr/65535*1000;
% dicomwrite(t2Fit2D_notCorr_ForDicom,['outputDicoms/', str1, '.dcm'],t2Fit2D_notCorr_info);

% T2 fit with improved Welsch's method
t2FitLookup_info = dicominfo([stringLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t2_Lookup_sl',num2str(nDessSlice)];
str2 = 't2_Lookup';
t2FitLookup_info.FileName = ['outputDicoms/', str1, '.dcm'];
t2FitLookup_info.SeriesNumber = t2FitLookup_info.SeriesNumber*1000 + 71;
t2FitLookup_info.ImagesInAcquisition = 1;
t2FitLookup_info.SeriesDescription = [str2];
t2FitLookup_ForDicom = t2FitLookup/65535*1000;
% adcFitBieri_20_notCorr_ForDicom = adcFitBieri_20_notCorr*1e12;
dicomwrite(t2FitLookup_ForDicom,['outputDicoms/', str1, '.dcm'],t2FitLookup_info);

% BSv: Added on 2016-09-16: Write T2 map to CSV file
csvwrite(['csvFiles/t2MapCsv_Slice',num2str(nDessSlice),'.dat'],t2FitLookup*1000);