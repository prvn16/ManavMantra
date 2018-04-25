function n = int8(this)
%INT8  Convert fi object to signed 8-bit integer
%   INT8(A) converts the fixed-point object A to a signed 8-bit integer 
%   based on the real world value. If the data does not fit in an int8, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.1 pi], 1, 8);
%     int8(a)
%
%   returns
%     -3  0  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = int8(double(this));
else
  n = int8(storedInteger(quantize(this, 1, 8, 0, 'round', 'saturate')));
end
