function [fname, hasLocalFunction, shouldLink, qualifyingPath, fullPath, alternateHelpFunction] = fixLocalFunctionCase(fname, helpPath)
    justChecking = nargin > 1;
    if ~justChecking
        helpPath = '';
    end
    
    hasLocalFunction = false;
    shouldLink       = false;
    
    qualifyingPath   = '';
    fullPath         = '';
    alternateHelpFunction = '';
    
    split = regexp(fname, filemarker, 'split', 'once');
    
    if length(split) > 1
        
        hasLocalFunction = true;
        [fileName, qualifyingPath, fullPath, hasMFileForHelp, alternateHelpFunction] = matlab.internal.language.introspective.fixFileNameCase(split{1}, helpPath);
        
        if ~hasMFileForHelp
            nameResolver = matlab.internal.language.introspective.resolveName(fileName, helpPath, false);
            
            fullPath        = nameResolver.whichTopic;
            hasMFileForHelp = exist(fullPath, 'file') == 2;
        end
        
        if hasMFileForHelp
            [~, mainFunctionName] = fileparts(fullPath);
            try %#ok<TRYNC>
                % Note: -subfun is an undocumented and unsupported feature
                localFunctions     = [{mainFunctionName}; which('-subfun', fullPath)];
                localFunctionIndex = strcmpi(localFunctions, split{2});
                
                if any(localFunctionIndex)
                    shouldLink = true;
                    if justChecking
                        fname = [fileName, filemarker, localFunctions{localFunctionIndex}];
                    else
                        if isempty(alternateHelpFunction) 
                            [filePath, fileName] = fileparts(fullPath);
                            filePath = [filePath, filesep, fileName];
                        else
                            filePath = fullPath;
                        end
                        fname = [filePath, filemarker, localFunctions{localFunctionIndex}];
                    end
                end
            end
            
            if ~shouldLink && matlab.internal.language.introspective.isClassMFile(fullPath)
                fname = [fileName, filesep, split{2}];
                hasLocalFunction = false;
            end
        end
    end
end

%   Copyright 2007 The MathWorks, Inc.
