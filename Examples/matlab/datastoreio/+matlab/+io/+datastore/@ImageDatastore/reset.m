function reset(imds)
%RESET Reset the datastore to the start of the data.
%   RESET(IMDS) resets IMDS to the beginning of the datastore.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'FileExtensions',exts);
%
%      while hasdata(imds)
%          img = read(imds);      % Read the images
%          imshow(img);           % See images in a loop
%      end
%      reset(imds);               % Reset to the beginning of the datastore
%      img = read(imds)           % Read from the beginning
%
%   See also imageDatastore, read, readimage, readall, hasdata, preview.

%   Copyright 2015-2017 The MathWorks, Inc.
try
    reset@matlab.io.datastore.FileBasedDatastore(imds);
    % set NumFiles so not to calculate whenever numel of files is needed.
    reset(imds.Splitter.Files);
    updateNumSplits(imds.Splitter);
    imds.NumFiles = imds.Splitter.Files.NumFiles;
    resetBatchReading(imds);
    imds.NoOpDuringGetDotFiles = false;
catch ME
    throw(ME);
end
end
