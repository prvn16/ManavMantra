function [fileName, foundTarget, fileType] = extractFile(dirInfo, targetName, isCaseSensitive, ext)
    fileTypes = fieldnames(dirInfo);
    if nargin < 4 || isempty(ext)
        fileTypes = setdiff(fileTypes, {'path', 'mat', 'classes', 'packages'});
    else
        fileTypes = fileTypes(strcmpi(fileTypes, ext(2:end)));
        fileName = '';
        foundTarget = false;
        fileType = '';
    end
    for i = 1:length(fileTypes)
        [fileName, foundTarget, fileType] = extractField(dirInfo, fileTypes{i}, targetName, isCaseSensitive);
        if foundTarget
            return;
        end
    end
end

function [fileName, foundTarget, fileType] = extractField(dirInfo, field, targetName, isCaseSensitive)
    fileIndex = matlab.internal.language.introspective.casedStrCmp(isCaseSensitive, dirInfo.(field), [targetName '.' field]);
    foundTarget = any(fileIndex);
    if foundTarget
        [~, fileName, fileType] = fileparts(dirInfo.(field){fileIndex});
    else
        fileName = '';
        fileType = '';
    end
end

%   Copyright 2008 The MathWorks, Inc.
