function [b1SliceLocations] = storeB1Locations(examPath,b1SeriesNo)


b1Info = dicominfo([examPath,b1SeriesNo,'I0001.dcm']);
b1SliceNo = b1Info.ImagesInAcquisition/2;   % I am assuming that the first half of the dicoms contain the B1 maps. This is correct for our implementation of the Bloch-Siegert sequence.
b1SliceLocations = zeros(b1SliceNo,1);
for (nB1Slice = 1:b1SliceNo)
    nB1SliceInfo = dicominfo([examPath,b1SeriesNo,'I00',sprintf('%02d',nB1Slice),'.dcm']);
    b1SliceLocations(nB1Slice) = nB1SliceInfo.SliceLocation;
end