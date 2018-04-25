function varargout=openmn(varargin)

% Copyright 2013-2017 The MathWorks, Inc.
% .mn files are MuPAD notebooks

if (nargin == 1)
    file = varargin{1};
    % Handle the case where the user has the specified an incompatible extension for this function
    % i.e. if the extension is anything other than .mn
    [fileDir,fileName,fileExt] = fileparts(file);
    if strcmp(fileExt,'.mn')
        nse = connector.internal.fileTypeNotSupportedError(file);
        nse.throwAsCaller;
    else
        % If the file has the incorrect extension, fall back to the original function for error handling
        originalDir = cd(fullfile(matlabroot, 'toolbox','symbolic','symbolic'));
        openHandle = @openmn;
        cd(originalDir);
        openHandle(file);
    end
else
    % If this function is called directly without the correct number of arguments,
    % use the traditional "command not found" error message
    nse = connector.internal.notSupportedError;
    nse.throwAsCaller;
end
