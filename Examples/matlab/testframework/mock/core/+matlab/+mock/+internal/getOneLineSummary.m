function summary = getOneLineSummary(value)
% This function is undocumented and may change in a future release.

% Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.diagnostics.displayValue;

s.f = value; %#ok<STRNU>
displayedValue = evalc('displayValue(s, false, 30);');
summary = regexp(displayedValue, 'f: (.*)', 'once','tokens','dotexceptnewline');
summary = string(summary{1});

if builtin('ischar', value) || builtin('isstring', value)
    % Further truncate chars and strings to 20 characters
    MAX_LENGTH = 20;
    len = summary.strlength;
    truncation = "...";
    closingQuote = summary.extractAfter(len-1);
    suffix = truncation + closingQuote;
    effectiveLength = MAX_LENGTH - suffix.strlength;
    if len >= effectiveLength
        summary = summary.extractBefore(effectiveLength) + suffix;
    end
end
end

% LocalWords:  STRNU dotexceptnewline isstring strlength
