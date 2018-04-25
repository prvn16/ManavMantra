function numFiles = countNumFiles(dirName, includeSubfolders)

% Copyright 2017 The MathWorks, Inc.

if includeSubfolders
    numFiles = dirMapReduce(dirName, @countFiles, @addResults);
else
    numFiles = countFiles(dirName);
end

end


function reducedResult = dirMapReduce(dirName, mapFcn, reduceFcn, varargin)

% Remove . and .. directories.
details = dir(dirName);
details = removeSpecialDirectories(details);

% Traverse.
subdirDetails = details([details.isdir]);
reducedResult = [];
for idx = 1:numel(subdirDetails)
    subdirResult = dirMapReduce(fullfile(dirName,subdirDetails(idx).name), mapFcn, reduceFcn, varargin{:});
    reducedResult = reduceFcn(reducedResult, subdirResult);
end

% Process.
fileDetails = details(~[details.isdir]);
thisDirResult = mapFcn(fileDetails, varargin{:});
reducedResult = reduceFcn(reducedResult, thisDirResult);

end


function details = removeSpecialDirectories(details)

directoryIndices = find([details.isdir]);

indicesToRemove = [];
for idx = directoryIndices
    if (isequal(details(idx).name, '.') || isequal(details(idx).name, '..'))
        indicesToRemove(end+1) = idx; %#ok<AGROW>
    end
end

details(indicesToRemove) = [];

end


function numFiles = countFiles(fileDetails)

numFiles = numel(fileDetails);

end


function result = addResults(value1, value2)

if isempty(value1)
    value1 = 0;
end

if isempty(value2)
    value2 = 0;
end

result = value1 + value2;

end
