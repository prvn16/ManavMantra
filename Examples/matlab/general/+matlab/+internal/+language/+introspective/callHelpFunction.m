function helpStr = callHelpFunction(helpFunction, fullPath)
    
    [filePath, fileName, fileExt] = fileparts(fullPath);
    split = regexp(fileExt, filemarker, 'split', 'once');
    if split{1} == ".p"
        split{1} = '.m';
    end
    fileName = [fileName, split{1}];
    if isscalar(split)
        localFunction = '';
    else
        localFunction = [filemarker, split{2}];
    end
    
    helpStr = getHelpTextFromFile(helpFunction, fullfile(filePath, 'en', fileName), localFunction);
    
    if isempty(helpStr)
        helpStr = getHelpTextFromFile(helpFunction, fullfile(filePath, fileName), localFunction);
    end
end

function helpStr = getHelpTextFromFile(helpFunction, helpFile, localFunction)

    helpStr = '';

    try
        if exist(helpFile, 'file')
            helpStr = feval(helpFunction, [helpFile, localFunction]);
            if ~ischar(helpStr)
                helpStr = '';
            end
        end
    catch
    end
end
    