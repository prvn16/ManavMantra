function n = int64(this)
%INT64 Convert fi object to signed 64-bit integer
%   INT64(A) converts the fixed-point object A to a signed 64-bit integer 
%   based on the real world value. If the data does not fit in an int64, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.1 pi], 1, 64);
%     int64(a)
%
%   returns
%     -3  0  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = int64(double(this));
else
  n = int64(storedInteger(quantize(this, 1, 64, 0, 'round', 'saturate')));
end
