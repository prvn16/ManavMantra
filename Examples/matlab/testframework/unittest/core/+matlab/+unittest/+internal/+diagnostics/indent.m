% This function is undocumented.

%  Copyright 2010-2017 The MathWorks, Inc.

function str = indent(str, indention)
if nargin == 1
    indention = "    ";
end
str = sprintf('%s%s', indention, regexprep(str, "\n", "\n" + indention));
end
