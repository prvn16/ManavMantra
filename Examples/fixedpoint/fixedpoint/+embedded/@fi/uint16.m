function n = uint16(this)
%UINT16  Convert fi object to an unsigned 16-bit integer
%   UINT16(A) converts the fixed-point object A to an unsigned 16-bit integer 
%   based on the real world value. If the data does not fit in an uint16, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.5 pi], 0, 16);
%     uint16(a)
%
%   returns
%     0  1  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = uint16(double(this));
else
  n = uint16(storedInteger(quantize(this, 0, 16, 0, 'round', 'saturate')));
end
