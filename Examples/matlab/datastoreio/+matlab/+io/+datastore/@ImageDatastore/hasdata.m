function tf = hasdata(imds)
%HASDATA Returns true if there is unread data in the ImageDatastore.
%   TF = HASDATA(IMDS) returns true if the datastore has one or more images
%   available to read with the read method. read(IMDS) returns an error
%   when HASDATA(IMDS) returns false.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      while hasdata(imds)
%         img = read(imds);      % Read one image at a time
%      end
%
%   See also imageDatastore, read, readimage, readall, preview, reset.

%   Copyright 2015 The MathWorks, Inc.
try
    tf = hasdata@matlab.io.datastore.FileBasedDatastore(imds);
catch e
    throw(e);
end
end
