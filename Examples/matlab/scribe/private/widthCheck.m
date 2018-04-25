function errorStruct = widthCheck(propValue)
%WIDTHCHECK Makes sure the width of a scribe object is non-negative.
%   ret = HGCHECK(PROPVALUE) checks if PROPVALUE is a non-negative number.
%   If it is not, it will return an error structure. Otherwise, the empty 
%   matrix is returned.

% Copyright 2006 The MathWorks, Inc.

errorStruct = [];

if propValue < 0
    errorStruct.message = sprintf('Value must be non-negative.');
    errorStruct.identifier = 'MATLAB:annotation:InvalidWidth';
end