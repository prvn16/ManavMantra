function wp = checkWhitePoint(in) %#codegen
%checkWhitePoint Check validity of white point argument
%
%   wp = images.color.internal.checkWhitePoint(in)
%
%   Checks that the input, in, is either a floating-point, three-element
%   row vector or is a string containing one of the recognized standard
%   white points. Returns a valid floating-point, three-element vector or
%   errors using throwAsCaller.
%
%   Example 1
%   ---------
%   Check a valid white-point vector.
%
%       wp = images.color.internal.checkWhitePoint([0.9 1.0 0.8])
%
%   Example 2
%   ---------
%   Check a valid white-point name.
%
%       wp = images.color.internal.checkWhitePoint('d50')
%
%   Example 3
%   ---------
%   Throw an error for invalid vector.
%
%       wp = images.color.internal.checkWhitePoint([0.9 1.0])
%
%   Example 4
%   ---------
%   Throw an error for an ambiguous white-point name.
%
%       wp = images.color.internal.checkWhitePoint('d')
%
%   See also whitepoint

%   Copyright 2009-2015 The MathWorks, Inc.

if ischar(in)
    s = validatestring(in,{'A','C','E','D50','D55','D65','ICC'},mfilename);
    wp = whitepoint(s);
else
    validateattributes(in,{'single','double'},{'real','row','numel',3},mfilename);
    wp = in;
end