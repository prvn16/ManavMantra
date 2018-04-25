function varargout = appdesigner(varargin)

% Copyright 2016 The MathWorks, Inc.
if (nargin == 1)
    % Editing in Appdesigner not yet supported on MATLAB Online
    ense = connector.internal.editNotSupportedError;
    ense.throwAsCaller;
else
    % Appdesigner not supported on MATLAB Online
    nse = connector.internal.notSupportedError;
    nse.throwAsCaller;
end


