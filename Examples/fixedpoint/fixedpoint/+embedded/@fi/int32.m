function n = int32(this)
%INT32  Convert fi object to signed 32-bit integer
%   INT32(A) converts the fixed-point object A to a signed 32-bit integer 
%   based on the real world value. If the data does not fit in an int32, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.1 pi], 1, 32);
%     int32(a)
%
%   returns
%     -3  0  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = int32(double(this));
else
  n = int32(storedInteger(quantize(this, 1, 32, 0, 'round', 'saturate')));
end
