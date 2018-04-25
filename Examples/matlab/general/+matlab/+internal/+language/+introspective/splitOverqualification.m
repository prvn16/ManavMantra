function [overqualifiedPath, actualName] = splitOverqualification(correctName, inputName, whichName)
    inputParts = splitPath(inputName);
    correctParts = splitPath(correctName);
    splitCount = length(correctParts);
    overqualifiedPath = joinPath(whichName, inputParts(1:end-splitCount));
    if ~isempty(overqualifiedPath) && overqualifiedPath(end) ~= '/'
        overqualifiedPath(end+1) = '/';
    end
    if nargout > 1
        actualName = joinPath(correctName, inputParts(end-splitCount+1:end));
    end
end

function parts = splitPath(name)
    parts = regexp(name, '([\\/.]|^)[@+]?', 'split');
    parts(cellfun(@isempty, parts)) = [];
end

function path = joinPath(fullPath, pathParts)
    path = sprintf('%s/', pathParts{:});
    path = matlab.internal.language.introspective.extractCaseCorrectedName(fullPath, path);
end
%   Copyright 2007 The MathWorks, Inc.
