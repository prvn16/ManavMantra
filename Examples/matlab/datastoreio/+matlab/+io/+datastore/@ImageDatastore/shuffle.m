function dsOut = shuffle(ds)
%shuffle Shuffle the files of a copy of the ImageDatastore.
%   DSOUT = SHUFFLE(DS) creates a deep copy of the input ImageDatastore and
%   shuffles the files using randperm, resulting in the datastore DSOUT.
%
%   Example:
%   --------
%      folders = fullfile(matlabroot,'toolbox','matlab',{'demos','imagesci'});
%      exts = {'.jpg','.png','.tif'};
%      imds = imageDatastore(folders,'LabelSource','foldernames','FileExtensions',exts)
%      shuffledDs = shuffle(imds)
%
%   See also imageDatastore, splitEachLabel, countEachLabel, hasdata,
%   readimage, readall, preview, reset.

%   Copyright 2015-2017 The MathWorks, Inc.
try
    dsOut = copy(ds);
    rndIdxes = randperm(dsOut.NumFiles);
    % set ReadFcn to the parent datastore and initialize with
    % only specific indexes of files.
    initWithIndices(dsOut, rndIdxes);
catch e
    throw(e)
end
end
