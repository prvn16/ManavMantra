function minimalPath = minimizePath(qualifyingPath, isDir)
    minimalPath = '';
    pathParts = regexp(qualifyingPath, '^(?<qualifyingPath>[^@+]*)(?(qualifyingPath)[\\/])(?<pathItem>[^\\/]*)(?<pathTail>.*)', 'names', 'once');
    qualifyingPath = pathParts.qualifyingPath;
    pathItem = pathParts.pathItem;
    pathTail = pathParts.pathTail;
    if isDir
        firstPath = @(q,p)whatPath(q,p,pathTail);
    else
        firstPath = @(q,p)which(fullfile(q,p,pathTail));
    end
    expectedPath = firstPath(qualifyingPath, pathItem);
    while ~strcmp(expectedPath, firstPath(minimalPath, pathItem))
        [qualifyingPath, pop] = fileparts(qualifyingPath);
        if isempty(pop)
            minimalPath = fullfile(qualifyingPath, minimalPath, pathItem, pathTail);
            return;
        end
        minimalPath = fullfile(pop, minimalPath);
    end
    minimalPath = fullfile(minimalPath, pathItem, pathTail);

%% ------------------------------------------------------------------------
function path = whatPath(qualifyingPath, pathItem, pathTail)
    dirInfo = matlab.internal.language.introspective.hashedDirInfo(fullfile(qualifyingPath, pathItem, pathTail));
    if isempty(dirInfo)
        path = '';
    else
        path = dirInfo(1).path;
    end

%   Copyright 2007 The MathWorks, Inc.
