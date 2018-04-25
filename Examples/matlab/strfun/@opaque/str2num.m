function x = str2num(s)
%STR2NUM Convert Java string object to numeric array.

%   Copyright 1984-2011 The MathWorks, Inc.

x = str2num(fromOpaque(s));

function z = fromOpaque(x)
z=x;

if isjava(z)
  z = char(z);
end

if isa(z,'opaque')
 error(message('MATLAB:str2num:CannotConvertClass', class( x )));
end
