function colorVal = colorFilter(propValue)
%COLORFILTER Makes sure the color of a scribe object is non-null.
%   ret = COLORFILTER(PROPVALUE) returns [0 0 0] if PROPVALUE is null.
%   If it is not, it will return the property value in tact.

% Copyright 2006 The MathWorks, Inc.

% This is called by various get methods as a get may be called before valid
% values have been stored, causing a post-get error.

if isempty(propValue)
    colorVal = [0 0 0];
else
    colorVal = propValue;
end