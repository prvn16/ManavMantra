function n = int16(this)
%INT16   Convert fi object to signed 16-bit integer
%   INT16(A) converts the fixed-point object A to a signed 16-bit integer 
%   based on the real world value. If the data does not fit in an int16, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.1 pi], 1, 16);
%     int16(a)
%
%   returns
%     -3  0  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = int16(double(this));
else
  n = int16(storedInteger(quantize(this, 1, 16, 0, 'round', 'saturate')));
end
