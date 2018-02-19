function [E1 E2 hdrInfo] = createDESSechoesFromPfile(pFilePath,sliceNo)

pfile_1 = rawloadX(pFilePath);
pfile_1Echo1 = squeeze(pfile_1(:,:,1,:,:));
pfile_1Echo2 = squeeze(pfile_1(:,:,2,:,:));

pfileAvgEcho1 = pfile_1Echo1;
pfileAvgEcho2 = pfile_1Echo2;

acqEcho1Full = fftshift(fft(fftshift(pfileAvgEcho1,1),[],1),1);
acqEcho1Full = fftshift(fft(fftshift(acqEcho1Full,2),[],2),2);
acqEcho1Full = sqrt(sum(abs(acqEcho1Full).^2,4));
acqEcho1Full = flipdim(flipdim(acqEcho1Full,1),2);

acqEcho2Full = fftshift(fft(fftshift(pfileAvgEcho2,1),[],1),1);
acqEcho2Full = fftshift(fft(fftshift(acqEcho2Full,2),[],2),2);
acqEcho2Full = sqrt(sum(abs(acqEcho2Full).^2,4));
acqEcho2Full = flipdim(flipdim(acqEcho2Full,1),2);

E1 = squeeze(acqEcho1Full(:,:,sliceNo));
E2 = squeeze(acqEcho2Full(:,:,sliceNo));





imageheader_offset = 147340;
tr_offset = imageheader_offset + 1056;
te1_offset = imageheader_offset + 1064;
te2_offset = imageheader_offset + 1070;
flipAngle_offset = imageheader_offset + 1412;
gareax_offset = imageheader_offset + 408;
gareay_offset = imageheader_offset + 412;
gareaz_offset = imageheader_offset + 416;
gdur_offset = imageheader_offset + 420;
tr_type = 'uint32';
te1_type = 'uint32';
te2_type = 'uint32';
flipAngle_type = 'uint16';
gareax_type = 'float';
gareay_type = 'float';
gareaz_type = 'float';
gdur_type = 'float';

%disp('Opening file');
fip = fopen(pFilePath,'r','l');
fseek(fip,tr_offset,-1);
% tr_offset
% fip
hdrInfo.TR = fread(fip,1,tr_type);
fseek(fip,te1_offset,-1);
hdrInfo.TE1 = fread(fip,1,te1_type);
fseek(fip,te2_offset,-1);
hdrInfo.TE2 = fread(fip,1,te2_type);
fseek(fip,flipAngle_offset,-1);
hdrInfo.flipAngle = fread(fip,1,flipAngle_type);
fseek(fip,gareax_offset,-1);
hdrInfo.gxarea = fread(fip,1,gareax_type);
fseek(fip,gareay_offset,-1);
hdrInfo.gyarea = fread(fip,1,gareay_type);
fseek(fip,gareaz_offset,-1);
hdrInfo.gzarea = fread(fip,1,gareaz_type);
fseek(fip,gdur_offset,-1);
hdrInfo.gdur = fread(fip,1,gdur_type);
fclose(fip);
%disp('Done reading file');