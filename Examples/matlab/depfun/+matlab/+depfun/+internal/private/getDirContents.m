function fileNames = getDirContents(fullPath)
%getDirContents Get files with MATLAB executable extensions
%    fileNames = getDirContents(fullPath) returns a cell array
%    of the file names.  The innput must be a string representing a valid 
%    directory.  The function will return an empty cell array if no files 
%    in the directory have executable MATLAB file extension. 

    import matlab.depfun.internal.requirementsConstants
    dirCommandPrefix = [fullPath filesep '*'];
    
    fileExt = requirementsConstants.executableMatlabFileExt;
    if strcmp(computer('arch'),'win32')
        fileExt{end+1} = '.dll'; %#ok
    end
    dirContents = cellfun(@(ext)getDirFiles([dirCommandPrefix ext]), ...
                       requirementsConstants.executableMatlabFileExt, ...
                       'UniformOutput', false);
    fileNames = [ dirContents{:} ]';
end

function files = getDirFiles(pth)
    dirContents = dir(pth);
    if isempty(dirContents)
        files = {};
    else
        files = {dirContents.name};
    end
end