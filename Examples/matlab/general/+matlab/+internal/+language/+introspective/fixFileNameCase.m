function [fileName, qualifyingPath, fullPath, hasMFileForHelp, alternateHelpFunction] = fixFileNameCase(fname, helpPath, whichTopic)
    fileName = fname;
    qualifyingPath = '';
    hasMFileForHelp = false;
    alternateHelpFunction = '';
    if nargin > 2 && ~isempty(whichTopic)
        fullPath = whichTopic;
        fname = regexprep(fname, '\.p$', '');
    else
        fullPath = matlab.internal.language.introspective.safeWhich(fname);
    end
    if isempty(fullPath)
        return;
    end
    if ~isempty(helpPath)
        helpPath = [filesep helpPath filesep];
        if isempty(strfind(fullPath, helpPath))
            [~, name] = fileparts(fname);
            allPaths = which('-all',fname);
            for entry=1:length(allPaths)
                pathEntry = allPaths{entry};
                [~, entryName] = fileparts(pathEntry);
                if strcmpi(name, entryName)
                    startPos = strfind(pathEntry, helpPath);
                    if ~isempty(startPos)
                        qualifyingPath = fileparts(matlab.internal.language.introspective.minimizePath(pathEntry(startPos(1)+1:end), false));
                        fullPath = pathEntry;
                        break;
                    end
                end
            end
        end
    end
    fileName = matlab.internal.language.introspective.extractCaseCorrectedName(fullPath, fname);
    [alternateHelpFunction, hasMFileForHelp] = matlab.internal.language.introspective.getAlternateHelpFunction(fullPath);
    if ~hasMFileForHelp && isempty(alternateHelpFunction)
        fullPath = '';
    end
end

%   Copyright 2007 The MathWorks, Inc.
