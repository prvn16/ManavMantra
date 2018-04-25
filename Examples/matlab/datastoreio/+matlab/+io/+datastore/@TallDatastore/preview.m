function data = preview(tds)
%PREVIEW Read data rows from the start of a TallDatastore.
%   A = PREVIEW(TDS) reads data rows from the beginning of TDS.
%   TDS.ReadSize controls the number of data rows that are read.
%   PREVIEW does not affect the state of TDS.
%
%   Example:
%   --------
%      % Create a simple tall double.
%      t = tall(rand(500,1))
%      % Write to a new folder.
%      newFolder = fullfile(pwd, 'myTest');
%      write(newFolder, t)
%      % Create an TallDatastore from newFolder
%      tds = datastore(newFolder)
%
%      a = PREVIEW(tds)
%
%   See also matlab.io.datastore.TallDatastore, hasdata, readall, read, reset.

%   Copyright 2016-2017 The MathWorks, Inc.

try
    % If files are empty, return an array of same type as
    % the data returned by a non-empty datastore, with zero first dimension.
    if isEmptyFiles(tds)
        data = getZeroFirstDimData(tds);
        return;
    end
    tdsCopy = copy(tds);
    reset(tdsCopy);
    data = read(tdsCopy);
    if size(data, 1) > 8
        tds.BufferedSubstruct.subs{1} = 1:8;
        data = subsref(data, tds.BufferedSubstruct);
        if tds.BufferedComplexityInfo.HasComplexVariables
            data = matlab.io.datastore.internal.applyComplexityInfo(...
                data, tds.BufferedComplexityInfo.ComplexVariables);
        end
    end
catch e
    throw(e);
end
end
