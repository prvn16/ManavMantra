function n = uint8(this)
%UINT8  Convert fi object to an unsigned 8-bit integer
%   UINT8(A) converts the fixed-point object A to an unsigned 8-bit integer 
%   based on the real world value. If the data does not fit in an uint8, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.5 pi], 0, 8);
%     uint8(a)
%
%   returns
%     0  1  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = uint8(double(this));
else
  n = uint8(storedInteger(quantize(this, 0, 8, 0, 'round', 'saturate')));
end
