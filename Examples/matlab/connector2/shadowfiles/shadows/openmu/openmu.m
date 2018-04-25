function varargout=openmu(varargin)

% Copyright 2013-2017 The MathWorks, Inc.
% .mu files are MuPAD program files

if (nargin == 1)
    file = varargin{1};
    % Handle the case where the user has the specified an incompatible extension for this function
    % i.e. if the extension is anything other than .mu
    [fileDir,fileName,fileExt] = fileparts(file);
    if strcmp(fileExt,'.mu')
        nse = connector.internal.fileTypeNotSupportedError(varargin);
        nse.throwAsCaller;
    else
        % If the file has the incorrect extension, fall back to the original function for error handling
        originalDir = cd(fullfile(matlabroot, 'toolbox','symbolic','symbolic'));
        openHandle = @openmu;
        cd(originalDir);
        openHandle(varargin);
    end
else
    % If this function is called directly without the correct number of arguments,
    % use the traditional "command not found" error message
    nse = connector.internal.notSupportedError;
    nse.throwAsCaller;
end
