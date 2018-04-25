function obj = setProperty(varargin)
%    FOR INTERNAL USE ONLY -- This function is intentionally undocumented
%    and is intended for use only with the scope of function in the MATLAB 
%    Engine APIs.  Its behavior may change, or the function itself may be 
%    removed in a future release.

% Copyright 2017-2018 The MathWorks, Inc.

% SETPROPERTY sets a property of a MATLAB class object.
    objArray = varargin{1};
    n = 1;
    % when index is NOT provided
    if length(varargin) == 3
        propertyName = varargin{2};
        property = varargin{3};
    % when index is provided
    else
        idx = varargin{2};
        propertyName = varargin{3};
        property = varargin{4};
        s(n).type = '()';
        s(n).subs = {idx};
        n = n+1;
    end
    s(n).type = '.';
    s(n).subs = propertyName;
    obj = subsasgn(objArray, s, property);
end
