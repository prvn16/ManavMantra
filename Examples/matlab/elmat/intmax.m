function imax = intmax(varargin)
%INTMAX Largest positive integer value.
%   X = INTMAX is the largest positive value representable in an int32.
%   Any value that is larger than INTMAX will saturate to INTMAX when
%   cast to int32.
%
%   INTMAX('int32') is the same as INTMAX with no arguments.
%
%   INTMAX(CLASSNAME) is the largest positive value in the integer class
%   CLASSNAME. Valid values of CLASSNAME are 'int8', 'uint8', 'int16',
%   'uint16', 'int32', 'uint32', 'int64' and 'uint64'.
%
%   See also INTMIN, REALMAX.

%   Copyright 1984-2017 The MathWorks, Inc. 

if (nargin == 0)
  imax = int32(2147483647);
elseif (nargin == 1)
  classname = varargin{1};
  if ischar(classname) || (isstring(classname) && isscalar(classname))
    switch (classname)
      case 'int8'
        imax = int8(127);
      case 'uint8'
        imax = uint8(255);
      case 'int16'
        imax = int16(32767);
      case 'uint16'
        imax = uint16(65535);
      case 'int32'
        imax = int32(2147483647);
      case 'uint32'
        imax = uint32(4294967295);
      case 'int64'
        imax = int64(9223372036854775807);
      case 'uint64'
        imax = uint64(18446744073709551615);
      otherwise
        error(message('MATLAB:intmax:invalidClassName'))
    end
  else
    error(message('MATLAB:intmax:inputMustBeString'))
  end
else % nargin > 1
  error(message('MATLAB:intmax:tooManyInputs'));
end
