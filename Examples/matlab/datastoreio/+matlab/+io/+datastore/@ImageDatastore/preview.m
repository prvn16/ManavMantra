function data = preview(imds)
%PREVIEW Read the first image from the datastore.
%   IMG = PREVIEW(IMDS) always reads the first image from IMDS.
%   By default, IMG is an
%      [MxN]   Integer - For grayscale images
%      [MxNx3] Integer - For color images
%      [MxNx4] Integer - For CMYK images
%   PREVIEW does not affect the state of IMDS.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      imshow(preview(imds));      %Preview the first image
%
%   See also imageDatastore, hasdata, readall, read, readimage, reset.

%   Copyright 2015-2016 The MathWorks, Inc.

try
    % If files are empty, return empty cell
    if isEmptyFiles(imds)
        data = cell(0,1);
        return;
    end
    data = readimage(imds, 1);
catch e
    throw(e);
end
end
