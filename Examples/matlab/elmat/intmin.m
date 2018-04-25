function imin = intmin(varargin)
%INTMIN Smallest integer value.
%   X = INTMIN is the smallest value representable in an int32.
%   Any value that is smaller than INTMIN will saturate to INTMIN when
%   cast to int32.
%
%   INTMIN('int32') is the same as INTMIN with no arguments.
%
%   INTMIN(CLASSNAME) is the smallest value in the integer class CLASSNAME.
%   Valid values of CLASSNAME are 'int8', 'uint8', 'int16', 'uint16',
%   'int32', 'uint32', 'int64' and 'uint64'.
%
%   See also INTMAX, REALMIN.

%   Copyright 1984-2017 The MathWorks, Inc. 

if (nargin == 0)
  imin = int32(-2147483648);
elseif (nargin == 1)
  classname = varargin{1};
  if ischar(classname) || (isstring(classname) && isscalar(classname))
    switch (classname)
      case 'int8'
        imin = int8(-128);
      case 'uint8'
        imin = uint8(0);
      case 'int16'
        imin = int16(-32768);
      case 'uint16'
        imin = uint16(0);
      case 'int32'
        imin = int32(-2147483648);
      case 'uint32'
        imin = uint32(0);
      case 'int64'
        imin = int64(-9223372036854775808);
      case 'uint64'
        imin = uint64(0);
      otherwise
        error(message('MATLAB:intmin:invalidClassName'))
    end
  else
    error(message('MATLAB:intmin:inputMustBeString'))
  end
else % nargin > 1
  error(message('MATLAB:intmin:tooManyInputs'));
end
