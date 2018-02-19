clear all
close all
clc

e1A = dicomread('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0057.dcm');
e1Ainfo = dicominfo('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0057.dcm');
e2A = dicomread('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0058.dcm');    
e2Ainfo = dicominfo('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0058.dcm');
e1B = dicomread('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0149.dcm');    
e1Binfo = dicominfo('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0149.dcm');
e2B = dicomread('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0150.dcm');    
e2Binfo = dicominfo('/bmrNAS/people/bragi/dicoms/fromBas_2016-11-11/ex8883/003/I0150.dcm');

e1A = double(e1A);
e2A = double(e2A);
e1B = double(e1B);
e2B = double(e2B);

% e1A(120:121,49:50)
% e2A(120:121,49:50)
% e1B(120:121,49:50)
% e2B(120:121,49:50)

figure(1)
imagesc(e1A);
figure(2)
imagesc(e2A);
figure(3)
imagesc(e1B);
figure(4)
imagesc(e2B);