function normlizedfullFileName = normalizeFullFileName(fullFileName)
%NORMALIZEFULLFILENAME Get the actual file name in the file system on a 
%   case-insensitive platform. If the user types a wrong-casing filename, 
%   this function will convert it to the correct file name in the filesystem.
%   The assumption is that the passed in filename exists in the filesystem,
%   otherwise the filename would be empty in the return value.
%
%    Copyright 2015 The MathWorks, Inc

    [filePath, file, ext] = fileparts(fullFileName);
    passedInFileName = [file, ext];

    % MLAPP file names under the same folder
    mlappFileNames = dir(fullfile(filePath, '*.mlapp'));
    
    if ~any(strcmp(passedInFileName, mlappFileNames))       
        % Can't find the file by case-sensitive matching, and must be a
        % case-insensitive filesystem and the user passes in a wrong-casing
        % filename
        idx = cellfun(@(name)strcmpi(name, passedInFileName), {mlappFileNames.name});

        % Actual full file name on filesystem
        normlizedfullFileName = fullfile(filePath, mlappFileNames(idx).name);
    else
        normlizedfullFileName = fullFileName;
    end
end

