function [] = fitSliceOneTouch3D(nDessSlice,examPath,seriesNo)




%%%%%%%%%%%%%%%%%
% stringHdir = [examPath,seriesNo.Hi];
% stringLdir = [examPath,seriesNo.Lo];
% echo1H_info = dicominfo([stringHdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
% echo1L_info = dicominfo([stringLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
stringHLdir = [examPath,seriesNo.HiLo];
echo1HLInfo = dicominfo([stringHLdir,'I',sprintf('%04d',1*2-1),'.dcm']);
echo1HLOneTouchInfo = echo1HLInfo.Private_0043_1038;
tempAngleA = double(echo1HLOneTouchInfo(20));
tempGxAreaA = echo1HLInfo.GxArea;
tempGyAreaA = echo1HLInfo.GyArea;
tempGzAreaA = echo1HLInfo.GzArea;
tempGAreaA = sqrt(tempGxAreaA^2 + tempGyAreaA^2 + tempGzAreaA^2);
tempAngleB = double(echo1HLOneTouchInfo(21));
tempGxAreaB = double(echo1HLOneTouchInfo(22));
tempGyAreaB = double(echo1HLOneTouchInfo(23));
tempGzAreaB = double(echo1HLOneTouchInfo(24));
tempGAreaB = sqrt(tempGxAreaB^2 + tempGyAreaB^2 + tempGzAreaB^2);


TRh = echo1HLInfo.RepetitionTime/1000;
TEh = echo1HLInfo.EchoTime/1000;
Tgh = echo1HLInfo.Tg/1e6;
TRl = TRh;
TEl = TEh;
Tgl = Tgh;

Nstates = 6;

numDessSlices = echo1HLInfo.Private_0021_104f;

echo1A = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
echo1A = double(echo1A);
echo2A = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',nDessSlice*2),'.dcm']);
echo2A = double(echo2A);
echo1B = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',(nDessSlice + numDessSlices)*2-1),'.dcm']);
echo1B = double(echo1B);
echo2B = dicomread([examPath,seriesNo.HiLo,'I',sprintf('%04d',(nDessSlice + numDessSlices)*2),'.dcm']);
echo2B = double(echo2B);



if (tempGAreaA > tempGAreaB)
    alphah_deg = tempAngleA;                         % Degrees
    alphal_deg = tempAngleB;                         % Degrees
    GhArea = tempGAreaA;
    GlArea = tempGAreaB;
    
    echo1H = echo1A;
    echo2H = echo2A;
    echo1L = echo1B;
    echo2L = echo2B;
else 
	alphah_deg = tempAngleB;                         % Degrees
    alphal_deg = tempAngleA;                         % Degrees
    GhArea = tempGAreaB;
    GlArea = tempGAreaA;
    
    echo1H = echo1B;
    echo2H = echo2B;
    echo1L = echo1A;
    echo2L = echo2A;
end



% Temp fix
% Tg = 0.0034;
% GhArea = 15660;
% GlArea = 1566;


% Do the parameter fit.
[adcMap3D,t2Map3D,t1Map3D] = DESS3dFit_img(TRh,TEh,Tgh,TRl,TEl,Tgl,GhArea,GlArea,alphah_deg,alphal_deg,Nstates,echo1H,echo2H,echo1L,echo2L);

assumedT1 = 1.2;
t2FitWelschNew = -2*(TRl-TEl)./log(echo2L./(echo1L * (sind(alphal_deg/2)).^2 * (1 + exp(-TRl/assumedT1))/(1 - cosd(alphal_deg)*exp(-TRl/assumedT1))));


disp('Done fitting slice');



% Mask out noise
M = ones(size(echo1L));
M(echo1L < 0.15*max(abs(echo1L(:)))) = 0;

adcMap3D = adcMap3D .* M;
t2Map3D = t2Map3D .* M;
t1Map3D = t1Map3D .* M;
t2FitWelschNew = t2FitWelschNew .* M;




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
% 


% T2 fit with improved Welsch's method
t2FitWelschNew_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t2_Welsch_new_sl',num2str(nDessSlice)];
str2 = 't2_Welsch_new';
t2FitWelschNew_info.FileName = ['outputDicoms/', str1, '.dcm'];
t2FitWelschNew_info.SeriesNumber = t2FitWelschNew_info.SeriesNumber*1000 + 70;
t2FitWelschNew_info.ImagesInAcquisition = 1;
t2FitWelschNew_info.SeriesDescription = [str2];
t2FitWelschNew_ForDicom = t2FitWelschNew/65535*1000;
% adcFitBieri_20_notCorr_ForDicom = adcFitBieri_20_notCorr*1e12;
dicomwrite(t2FitWelschNew_ForDicom,['outputDicoms/', str1, '.dcm'],t2FitWelschNew_info);




% T1 fit with "3D method"
t1Map3d_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t1Map3d_sl',num2str(nDessSlice)];
str2 = 't1Map3d';
t1Map3d_info.FileName = ['outputDicoms/', str1, '.dcm'];
t1Map3d_info.SeriesNumber = t1Map3d_info.SeriesNumber*1000 + 110;
t1Map3d_info.ImagesInAcquisition = 1;
t1Map3d_info.SeriesDescription = [str2];
t1Map3d_ForDicom = t1Map3D/65535*1000;
dicomwrite(t1Map3d_ForDicom,['outputDicoms/', str1, '.dcm'],t1Map3d_info);

% T2 fit with "3D method"
t2Map3d_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['t2Map3d_sl',num2str(nDessSlice)];
str2 = 't2Map3d';
t2Map3d_info.FileName = ['outputDicoms/', str1, '.dcm'];
t2Map3d_info.SeriesNumber = t2Map3d_info.SeriesNumber*1000 + 120;
t2Map3d_info.ImagesInAcquisition = 1;
t2Map3d_info.SeriesDescription = [str2];
t2Map3d_ForDicom = t2Map3D/65535*1000;
dicomwrite(t2Map3d_ForDicom,['outputDicoms/', str1, '.dcm'],t2Map3d_info);

% ADC fit with "3D method"
adcMap3d_info = dicominfo([stringHLdir,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
str1 = ['adcMap3d_sl',num2str(nDessSlice)];
str2 = 'adcMap3d';
adcMap3d_info.FileName = ['outputDicoms/', str1, '.dcm'];
adcMap3d_info.SeriesNumber = adcMap3d_info.SeriesNumber*1000 + 130;
adcMap3d_info.ImagesInAcquisition = 1;
adcMap3d_info.SeriesDescription = [str2];
adcMap3d_ForDicom = adcMap3D/65535*1e12;
dicomwrite(adcMap3d_ForDicom,['outputDicoms/', str1, '.dcm'],adcMap3d_info);
