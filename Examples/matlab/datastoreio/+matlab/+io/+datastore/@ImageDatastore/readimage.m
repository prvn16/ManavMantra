function [data, info] = readimage(imds, index)
%READIMAGE Read a specified image from the ImageDatastore.
%   IMG = READIMAGE(IMDS,I) reads the I-th image from IMDS.
%   By default, IMG is an
%      [MxN] Integer   - For grayscale images
%      [MxNx3] Integer - For color images
%      [MxNx4] Integer - For CMYK images
%
%   [IMG,INFO] = READIMAGE(IMDS,I) also returns a structure with
%   additional information about IMG. The fields of INFO are:
%      Filename - Name of the file from which the image was read
%      FileSize - Size of the file in bytes
%      Label    - Label for the file
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      img2 = readimage(imds,2);       % Read 2nd image
%
%   See also imageDatastore, read, readall, hasdata, preview, reset.

%   Copyright 2015 The MathWorks, Inc.
try
    validateattributes(index, {'numeric'}, ...
        {'scalar', 'positive', 'integer', '<=', imds.NumFiles}, ...
        'ImageDatastore', 'INDEX', 2);
    [data, info] = readUsingSplitReader(imds, index);
catch ME
    throw(ME);
end
end
