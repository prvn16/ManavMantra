function thumbnailFilename = createThumbnail(fullSizeImage)
%createThumbnail  Create standard-sized thumbnail.

% Copyright 2015 The MathWorks, Inc.

thumbnailSize = iptui.internal.segmenter.getThumbnailSize(); %px

% Resize and preserve the aspect ratio.
if(size(fullSizeImage,1) > size(fullSizeImage,2))
    thumbnail = imresize(fullSizeImage, [thumbnailSize, NaN], 'nearest');
else
    thumbnail = imresize(fullSizeImage, [NaN, thumbnailSize], 'nearest');
end

thumbnailFilename = [tempname '.png'];
imwrite(thumbnail, thumbnailFilename)

end
