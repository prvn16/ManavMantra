function validatedFileName = getValidatedInputAppFileName(inputFileNameOrPath)
%GETVALIDATEDINPUTFILENAME Check and return the validated input .mlapp file 
% name. 
%   If the file name is not valid or not exist, error will be thrown
%   otherwise, return a validated full file name
%
%    Copyright 2017 The MathWorks, Inc

    % the filename can either be a character vector or string, but if a
    % string it must be scalar (i.e. dimension of 1)
    if ~ischar(inputFileNameOrPath) && ~(isstring(inputFileNameOrPath) && isscalar(inputFileNameOrPath))
        error(message('MATLAB:appdesigner:appdesigner:InvalidInput'));
    end
    inputFileNameOrPath = char(inputFileNameOrPath);

    fileExt = '.mlapp';
    [filePath, file, ext] = fileparts(inputFileNameOrPath);

    if iskeyword(file)
        error(message('MATLAB:appdesigner:appdesigner:FileNameFailsIsKeyword'));
    end

    if ~isvarname(file)
        error(message('MATLAB:appdesigner:appdesigner:FileNameFailsIsVarName', file));
    end

    % Append the default file extension if necessary.
    if isempty(ext)
        ext = fileExt;
    elseif ~strcmp(ext, fileExt)
        error(message('MATLAB:appdesigner:appdesigner:InvalidFileExtension', inputFileNameOrPath));
    end

    % Get the file path with the correct extension.
    validatedFileName = fullfile(filePath, [file ext]);

    if ~exist(validatedFileName, 'file')
        error(message('MATLAB:appdesigner:appdesigner:InvalidFileName', validatedFileName));
    end

    % Get the full file path of the app.
    [success, fileInfo, ~] = fileattrib(validatedFileName);
    if success
        validatedFileName = appdesigner.internal.application.normalizeFullFileName(fileInfo.Name);
    else
        % which only works for the file in the MATLAB search path, and also
        % return the normalized file path
        validatedFileName = which(validatedFileName);
    end
end