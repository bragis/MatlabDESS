% clear all
% close all
% clc


%addpath('~/epg/matlab/bragi/fall_2010');

function [] = createTestEchoDicoms(S1p_image,S1m_image,S2p_image,S2m_image,S1pDicomPath,S1mDicomPath,S2pDicomPath,S2mDicomPath,TR,TE,Tg,alpha1,G1,alpha2,G2)

dicomdict('set','bragis_dicom_dict.txt');
load DicomStandardInfo;

S1pinf = S1pStandardInfo;
S1pinf.Filename = S1pDicomPath;
S1pinf.Width = 256;
S1pinf.Height = 256;
S1pinf.StudyDescription = 'DESS maps testing';
S1pinf.SeriesDescription = 'DESS Hi';
S1pinf.PatientName = 'DESStestName';
S1pinf.PatientID = 'DESS test';
S1pinf.PatientBirthDate = '20010101';
S1pinf.ProtocolName = 'NO_PROTOCOL';
S1pinf.ReceiveCoilName = 'NO_COIL';
S1pinf.RepetitionTime = TR*1000;
S1pinf.EchoTime = TE*1000;
S1pinf.FlipAngle = alpha1;
S1pinf.GxArea = G1/sqrt(3)*Tg*1e4;
S1pinf.GyArea = G1/sqrt(3)*Tg*1e4;
S1pinf.GzArea = G1/sqrt(3)*Tg*1e4;
S1pinf.Tg = Tg*1e6;
S1pinf.StudyID = '0001';
S1pinf.SeriesNumber = 1;


S1minf = S1mStandardInfo;
S1minf.Filename = S1mDicomPath;
S1minf.Width = 256;
S1minf.Height = 256;
S1minf.StudyDescription = 'DESS maps testing';
S1minf.SeriesDescription = 'DESS Hi';
S1minf.PatientName = 'DESStestName';
S1minf.PatientID = 'DESS test';
S1minf.PatientBirthDate = '20010101';
S1minf.ProtocolName = 'NO_PROTOCOL';
S1minf.ReceiveCoilName = 'NO_COIL';
S1minf.RepetitionTime = TR*1000;
S1minf.EchoTime = TE*1000;
S1minf.FlipAngle = alpha1;
S1minf.GxArea = G1/sqrt(3)*Tg*1e4;
S1minf.GyArea = G1/sqrt(3)*Tg*1e4;
S1minf.GzArea = G1/sqrt(3)*Tg*1e4;
S1minf.Tg = Tg*1e6;
S1minf.StudyID = '0001';
S1minf.SeriesNumber = 2;

S2pinf = S2pStandardInfo;
S2pinf.Filename = S2pDicomPath;
S2pinf.Width = 256;
S2pinf.Height = 256;
S2pinf.StudyDescription = 'DESS maps testing';
S2pinf.SeriesDescription = 'DESS Lo';
S2pinf.PatientName = 'DESStestName';
S2pinf.PatientID = 'DESS test';
S2pinf.PatientBirthDate = '20010101';
S2pinf.ProtocolName = 'NO_PROTOCOL';
S2pinf.ReceiveCoilName = 'NO_COIL';
S2pinf.RepetitionTime = TR*1000;
S2pinf.EchoTime = TE*1000;
S2pinf.FlipAngle = alpha2;
S2pinf.GxArea = G2/sqrt(3)*Tg*1e4;
S2pinf.GyArea = G2/sqrt(3)*Tg*1e4;
S2pinf.GzArea = G2/sqrt(3)*Tg*1e4;
S2pinf.Tg = Tg*1e6;
S2pinf.StudyID = '0001';
S2pinf.SeriesNumber = 3;

S2minf = S2mStandardInfo;
S2minf.Filename = S2mDicomPath;
S2minf.Width = 256;
S2minf.Height = 256;
S2minf.StudyDescription = 'DESS maps testing';
S2minf.SeriesDescription = 'DESS Lo';
S2minf.PatientName = 'DESStestName';
S2minf.PatientID = 'DESS test';
S2minf.PatientBirthDate = '20010101';
S2minf.ProtocolName = 'NO_PROTOCOL';
S2minf.ReceiveCoilName = 'NO_COIL';
S2minf.RepetitionTime = TR*1000;
S2minf.EchoTime = TE*1000;
S2minf.FlipAngle = alpha2;
S2minf.GxArea = G2/sqrt(3)*Tg*1e4;
S2minf.GyArea = G2/sqrt(3)*Tg*1e4;
S2minf.GzArea = G2/sqrt(3)*Tg*1e4;
S2minf.Tg = Tg*1e6;
S2minf.StudyID = '0001';
S2minf.SeriesNumber = 4;

S1p_dcmImage = dicomwrite(abs(S1p_image),S1pDicomPath,S1pinf,'WritePrivate',true);
S1m_dcmImage = dicomwrite(abs(S1m_image),S1mDicomPath,S1minf,'WritePrivate',true);
S2p_dcmImage = dicomwrite(abs(S2p_image),S2pDicomPath,S2pinf,'WritePrivate',true);
S2m_dcmImage = dicomwrite(abs(S2m_image),S2mDicomPath,S2minf,'WritePrivate',true);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            

