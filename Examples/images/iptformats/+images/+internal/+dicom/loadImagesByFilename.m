function X = loadImagesByFilename(filenames)
% Copyright 2016-2017 The MathWorks, Inc.

if (numel(filenames) == 0)
    X = [];
    return
end

if ischar(filenames) || (isstring(filenames) && numel(filenames) == 1)
    filenames = {filenames};
end

tmp = dicomread(filenames{1});
numImages = numel(filenames);

if numImages == 1
    X = tmp;
else
    X = zeros(size(tmp,1), size(tmp,2), size(tmp,3), numImages, 'like', tmp);
    X(:,:,:,1) = tmp;
    
    for idx = 2:numel(filenames)
        X(:,:,:,idx) = dicomread(filenames{idx});
    end
end
end
