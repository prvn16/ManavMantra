function [qualifyingPath, pathItem] = getPathItem(hp)
    [qualifyingPath, pathItem, ext] = fileparts(hp.fullTopic);
    if ~hp.isDir
        hp.isContents = strcmp(pathItem, 'Contents') && strcmp(ext,'.m') && ~matlab.internal.language.introspective.containers.isClassDirectory(qualifyingPath);
        if hp.isContents
            hp.isDir = true;
            pathItem = matlab.internal.language.introspective.minimizePath(qualifyingPath, true);
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
