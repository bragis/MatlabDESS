clear all
close all
clc

% This script creates parameter estimates from two DESS scans based on the
% methods described by Bieri et al (MRM 68:720-729, 2012) and by Sveinsson
% et al (Proc. ISMRM 2015, 6545). The scans should have a strong and a weak
% spoiler. Ideally, all other scan parameters (including flip angle) should
% be the same.
% The script is based on a dictionary approach - computing signals for a
% range of tissue parameters and then choosing the entry that best matches
% your measured signals as the tissue parameter estimates. It starts by
% trying to find a dictionary that matches the scan parameters in your
% dicom header. If it can't find one, it creates one. This takes a long
% time, especially if B1 correction is applied, since a new dictionary must
% be computed for a range of flip angles, adding a dimension to the
% dictionary. However, this should only be needed once for each scan
% setting - the dictionary then gets saved and is loaded in subsequent runs
% of the script.

addpath ../common/;
addpath ../commonFunctions/
dicomdict('set','bragis_dicom_dict.txt');

set(0,'defaultAxesFontSize',10);
set(0,'DefaultLineLineWidth',1);
% set(0,'defaultAxesFontSize',20);
% set(0,'DefaultLineLineWidth',2);
set(0,'defaultAxesLineWidth',1);
set(0,'defaultfigurecolor',[1 1 1]);

% Enter the directory containing your series directories. This assumes the
% directory structure of the Lucas Dicom computers, with series labeled
% /001, /002, etc.
% It assumes that the DESS dicoms are named I0001.dcm, I0002.dcm, ... where
% I000[2n-1].dcm and I000[2n].dcm correspond to echoes 1 and 2 of slice n,
% respectively.
% So if for example the "High DESS" was acquired as the first series, the
% dicoms corresponding to the two echoes of the first slice should be
% /path/to/dicoms/001/I0001.dcm, /path/to/dicoms/001/I0002.dcm, etc.
examPath = '/data/bragi-data/temp/dicoms/ex32697_2016-03-04/';
seriesNo.Hi = '007/';
seriesNo.Lo = '006/';
% Type in the range of slices that you want to fit.
sliceRange = [1:28];


sliceCount = 0;
for (nSlice = sliceRange)
    sliceCount = sliceCount + 1;
    disp(['Fitting slice no. ', num2str(nSlice), ' (', num2str(sliceCount/length(sliceRange)*100), '% ...)']);
    fitSlice2(nSlice,examPath,seriesNo)
end