% This function is undocumented.

%  Copyright 2015 The MathWorks, Inc.
function str = indentWithArrow(str)
import matlab.unittest.internal.diagnostics.indent;
str = indent(str);
str(1:3) = '-->';
end