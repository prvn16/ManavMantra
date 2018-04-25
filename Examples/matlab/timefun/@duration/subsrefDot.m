function value = subsrefDot(this,s)

%   Copyright 2014-2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString

if ~isstruct(s), s = struct('type','.','subs',s); end

name = s(1).subs;
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

% None of the properties can return a CSL, so a single output is sufficient. 
if ~isscalar(s)
    value = subsref(value,s(2:end));
end
