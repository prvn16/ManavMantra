function string = fixENotation(string)
%fixENotation Make string with E notation look similar on all platforms

%   Copyright 2005 The MathWorks, Inc.

if ispc
    string = strrep(string,'E+0','E+');
    string = strrep(string,'E-0','E-');

end
