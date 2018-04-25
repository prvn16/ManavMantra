function this = subsasgnDot(this,s,rhs)

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if ~isstruct(s), s = struct('type','.','subs',s); end

name = s(1).subs;

% For nested subscript, get the property and call subsasgn on it
if ~isscalar(s)
    switch name
    case 'Format'
        value = this.fmt;
    otherwise
        if isCharString(name)
            error(message('MATLAB:duration:UnrecognizedProperty',name));
        else
            error(message('MATLAB:duration:InvalidPropertyName'));
        end
    end
    rhs = builtin('subsasgn',value,s(2:end),rhs);
end

% Assign the rhs to the property
switch name
case 'Format'
    this.fmt = verifyFormat(rhs);
otherwise
    if isCharString(name)
        error(message('MATLAB:duration:UnrecognizedProperty',name));
    else
        error(message('MATLAB:duration:InvalidPropertyName'));
    end
end
