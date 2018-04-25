%% Pack data to RGBA format
function [outRGB] = pack_rgbData(img)

% Extract the image parameters
[rows,cols,nChannels] = size(img);
% Initialize the output matrix
outRGB = zeros([rows*(nChannels+1),cols],'uint8');
%% Perform the RGBA column major packing 
for rowidx=1:rows
    for colidx=1:cols
        %Copy the RGB
        for ch=1:nChannels
            outRGB((rowidx-1)*(nChannels+1)+ch,colidx) = img(rowidx,colidx,ch);
        end
        % Zero the Alpha channel when it is not available
        outRGB((rowidx-1)*(nChannels+1)+4,colidx) = 0;
    end
end
end