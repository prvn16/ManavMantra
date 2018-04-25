function s = ordinalString(i)
%ORDINALSTRING Convert an integer to an ordinal character vector.
%   S = ORDINALSTRING(I) returns the character vector '1st' for 1, '2nd'
%   for 2, etc.

%   Copyright 2012-2016 The MathWorks, Inc.

switch mod(abs(i),100)
case {11 12 13}
    s = getString(message('MATLAB:table:ordinalstrings:Nth',i));
otherwise
    switch mod(abs(i),10)
    case 1,    s = getString(message('MATLAB:table:ordinalstrings:First',i));
    case 2,    s = getString(message('MATLAB:table:ordinalstrings:Second',i));
    case 3,    s = getString(message('MATLAB:table:ordinalstrings:Third',i));
    otherwise, s = getString(message('MATLAB:table:ordinalstrings:Nth',i));
    end
end
end

