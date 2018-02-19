function [b1Map] = alignedB1Map(examPath,seriesNo,nDessSlice,nB1Slice)


% 'I',sprintf('%04d',nDessSlice*2-1),'.dcm'
% dessSlice = dicomread([examPath,seriesNo.Hi,'I00',sprintf('%02d',nDessSlice*2-1),'.dcm']);
% dessSliceInfo = dicominfo([examPath,seriesNo.Hi,'I00',sprintf('%02d',nDessSlice*2-1),'.dcm']);
% b1Slice = dicomread([examPath,seriesNo.B1,'I00',sprintf('%02d',nB1Slice),'.dcm']);
% b1SliceInfo = dicominfo([examPath,seriesNo.B1,'I00',sprintf('%02d',nB1Slice),'.dcm']);
dessSlice = dicomread([examPath,seriesNo.Hi,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
dessSliceInfo = dicominfo([examPath,seriesNo.Hi,'I',sprintf('%04d',nDessSlice*2-1),'.dcm']);
b1Slice = dicomread([examPath,seriesNo.B1,'I',sprintf('%04d',nB1Slice),'.dcm']);
b1SliceInfo = dicominfo([examPath,seriesNo.B1,'I',sprintf('%04d',nB1Slice),'.dcm']);


% Now map each pixel in the DESS image to a pixel in the flip angle map, 
% thereby creating a new map 
b1Map = zeros(size(dessSlice)); 
%sum = 0; 
for (xPix_DESS=1:size(dessSlice,2)) 
	for (yPix_DESS=1:size(dessSlice,1)) 
        xPix_B1 = round((xPix_DESS * dessSliceInfo.PixelSpacing(1) + (dessSliceInfo.ImagePositionPatient(1)- b1SliceInfo.ImagePositionPatient(1)))/b1SliceInfo.PixelSpacing(1)); 
        yPix_B1 = round((yPix_DESS * dessSliceInfo.PixelSpacing(2) + (dessSliceInfo.ImagePositionPatient(2)- b1SliceInfo.ImagePositionPatient(2)))/b1SliceInfo.PixelSpacing(2)); 

        if ((xPix_B1 > 0)&&(xPix_B1 < size(b1Slice,1))&&(yPix_B1 > 0)&&(yPix_B1 < size(b1Slice,2))) 
            b1Map(xPix_DESS,yPix_DESS) = b1Slice(xPix_B1,yPix_B1); 
        end 
    end
end

% Scale the flip angle map to percentage values.
% I'm assuming that the Bloch-Siegert scan has been used and processed such
% that the map displays 10x the measured flip angle
b1Map = b1Map/(b1SliceInfo.FlipAngle*10);