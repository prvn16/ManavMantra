function txt = getDisplayableStringWithNoHeader(value)

%  Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.diagnostics.getDisplayableString;

txt = getDisplayableString(value);

% char, string, and double do not have headers to remove
if ~any(builtin('class',value) == ["char", "string", "double"])
    txt = regexprep(txt, "^.*?" + class(value) + "[^\r\n]*\n*", "");
end
end

