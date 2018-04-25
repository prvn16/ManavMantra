function setVariable(varargin)
%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB 
%    Engine APIs.  Its behavior may change, or the function itself may be 
%    removed in a future release.

% Copyright 2017 The MathWorks, Inc.

% SETVARIABLE set a MATLAB variable to the base or global workspace.
    varname = varargin{1};
    var = varargin{2};
    workspaceType = varargin{3};
    if strcmp(workspaceType, 'global')
        statement = ['global ' varname];
        evalin('caller', statement);
        assignin('caller', varname, var);
    else
        assignin('base', varname, var);
    end
end
