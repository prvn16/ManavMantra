function ret=getVariable(varargin)
%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB 
%    Engine APIs.  Its behavior may change, or the function itself may be 
%    removed in a future release.

% Copyright 2016-2017 The MathWorks, Inc.

% GETVARIABLE returns a MATLAB variable from the base or global workspace.
    varname = varargin{1};
    %By default, it is base workspace.  Python Engine only supports base
    %workspace.
    workspaceType = 'base';
    if length(varargin) > 1
        workspaceType = varargin{2};
    end
    if strcmp(workspaceType, 'global')
        statement = ['global ' varname];
        eval(statement);
        %If the global variable doesn't exist, it returns an empty array.
        ret = eval(varname);
    else
            flag = evalin(workspaceType, ['exist(''' varname ''',''var'')']);
            if flag
	            ret = evalin(workspaceType, varname);
            else
	            error(['Undefined variable ''' varname '''.']);
            end
    end

end
