function opentoline(varargin)
%OPENTOLINE Open to specified line in function file in Editor
%   This function is unsupported and for internal use only.

% Copyright 2010-2013 The MathWorks, Inc.

import com.mathworks.matlabserver.workercommon.client.*;
clientServiceRegistryFacade = ClientServiceRegistryFactory.getClientServiceRegistryFacade();
editorService = clientServiceRegistryFacade.getEditorService();

% Checks for a minimum of two input arguments and a maximum of 3
narginchk(2, 3);

fileName = varargin{1};
lineNumber = varargin{2};

if (nargin == 2)
    column = 1; %if two arguments, then set column number as 1
else
    column = varargin{3}; %if three args, then use that value
end

[pathstr, name, ext] = fileparts(fileName);
if strcmp(ext, '.p')
    mFileName = fullfile(pathstr, [name '.m']);
    if exist(mFileName, 'file')
        % open the mfile instead
        fileName = mFileName;
    end
elseif strcmp(ext,'.mlapp')
    nse = connector.internal.fileTypeNotSupportedError(fileName);
    nse.throwAsCaller;
end

editorService.openToLine(fileName, lineNumber, column);
