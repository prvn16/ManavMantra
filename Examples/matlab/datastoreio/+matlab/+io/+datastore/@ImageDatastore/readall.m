function data = readall(imds)
%READALL Read all of the image files from the datastore.
%   IMGARR = READALL(IMDS) reads all of the image files from IMDS.
%   IMGARR is a cell array containing all the images returned by the
%   readimage method.
%
%   See also imageDatastore, hasdata, read, readimage, preview, reset.

%   Copyright 2015-2017 The MathWorks, Inc.

try
    % If empty files return an empty cell array
    if isEmptyFiles(imds)
        data = cell(0,1);
        return;
    end
    nFiles = imds.NumFiles;
    if isequal(imds.CachedRead, 'off') || ~imds.IsReadFcnDefault
        data = cell(nFiles, 1);
        for ii = 1:nFiles
            data{ii} = readimage(imds, ii);
        end
    else
        idxes = true(nFiles, 1);
        % Create a copy so we don't mess with the states in the prefetching
        % for read.
        cpyDs = copy(imds);
        reset(cpyDs);
        data = readUsingPreFetcher(cpyDs, cpyDs.Files, idxes, [], nFiles);
    end
catch ME
    throw(ME);
end

end
