function [data, info] = read(imds)
%READ Read the next image from the datastore.
%   IMG = READ(IMDS) reads the next consecutive image from IMDS.
%   By default, IMG is an
%      [MxN] Integer   - For grayscale images
%      [MxNx3] Integer - For color images
%      [MxNx4] Integer - For CMYK images
%   When ReadSize property of ImageDatastore is greater than 1, IMG is a
%   cell array of image data.
%   READ(IMDS) errors if there is no image data in IMDS and should be used
%   with hasdata(IMDS).
%
%   [IMG,INFO] = READ(IMDS) also returns a structure with additional
%   information about IMG. The fields of INFO are:
%      Filename - Name of the file from which the image was read
%      FileSize - Size of the file in bytes
%      Label    - Label for the file
%   When ReadSize property of ImageDatastore is greater than 1, the fields
%   of INFO are:
%      Filename - Cell array of filenames
%      FileSize - A vector of file sizes
%      Label    - A vector of labels
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
%   See also imageDatastore, hasdata, readimage, readall, preview, reset.

%   Copyright 2015-2017 The MathWorks, Inc.
try
    
    if isequal(imds.CachedRead, 'off') || ~imds.IsReadFcnDefault
        if imds.IsUsingCachedRead
            imds.SplitReader = createReader(imds.Splitter, imds.SplitIdx);
            reset(imds.SplitReader);
            imds.IsUsingCachedRead = false;
        end
        if imds.ReadSize == 1
            [data, info] = readData(imds);
            info.Label = getLabelUsingIndex(imds, imds.SplitIdx);
        else
            readSize = getTrueReadSize(imds);
            [files, idxes] = nextFilesToRead(imds, readSize);
            data = cell(readSize, 1);
            ii = 1;
            [data{ii}, info] = readData(imds);
            while hasdata(imds) && ii < readSize
                ii = ii + 1;
                data{ii} = readData(imds);
            end
            if ii == 1
                data = data(1);
            else
                info = getInfoForBatch(imds, files, idxes);
            end
        end
    else
        if ~imds.IsUsingCachedRead
            imds.BatchReader = [];
            imds.IsUsingCachedRead = true;
        end
        [data, info] = preFetchRead(imds);
        if imds.ReadSize == 1
            data = data{1};
        end
    end
catch e
    throw(e)
end

end
