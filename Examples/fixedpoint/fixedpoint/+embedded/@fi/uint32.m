function n = uint32(this)
%UINT32   Convert fi object to an unsigned 32-bit integer
%   UINT32(A) converts the fixed-point object A to an unsigned 32-bit integer 
%   based on the real world value. If the data does not fit in an uint32, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.5 pi], 0, 32);
%     uint32(a)
%
%   returns
%     0  1  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = uint32(double(this));
else
  n = uint32(storedInteger(quantize(this, 0, 32, 0, 'round', 'saturate')));
end
