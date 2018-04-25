function b = isHGHandleOfType(val, type)
% Returns true if val is a hghandle and is the same type as the input type.

% Copyright 2012-2017 The MathWorks, Inc.

if nargin > 0
    val = convertStringsToChars(val);
end

if nargin > 1
    type = convertStringsToChars(type);
end

b = isgraphics(val) && strcmpi(get(val,'Type'),type); % ishghandle(val)
