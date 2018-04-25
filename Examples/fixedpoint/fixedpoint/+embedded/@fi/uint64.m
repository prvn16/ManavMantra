function n = uint64(this)
%UINT64  Convert fi object to an unsigned 64-bit integer
%   UINT64(A) converts the fixed-point object A to an unsigned 64-bit integer 
%   based on the real world value. If the data does not fit in an uint64, 
%   then the data is rounded-to-nearest and saturated with no warning.
%
%   Example:
%
%     a = fi([-pi 0.5 pi], 0, 64);
%     uint64(a)
%
%   returns
%     0  1  3
%
%   See also FI, EMBEDDED.FI/storedInteger

%   Copyright 1999-2015 The MathWorks, Inc.

if ((this.WordLength<53)&&this.isscalingbinarypoint) || this.isboolean || this.isfloat
  n = uint64(double(this));
else
  n = uint64(storedInteger(quantize(this, 0, 64, 0, 'round', 'saturate')));
end
