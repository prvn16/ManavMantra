function str = getValueDisplay(value) 
% getValueDisplay - evalc a value and extract the displayable output

% This function is undocumented.

%  Copyright 2014-2016 MathWorks, Inc.

import matlab.unittest.internal.diagnostics.AlternativeRichString;

plain = displayValueAndRemoveHeader(value, false);
hyperlinked = displayValueAndRemoveHeader(value, true);
str = AlternativeRichString(plain, hyperlinked);
end

function valueDisplay = displayValueAndRemoveHeader(value, shouldHyperlink) %#ok<INUSD> % evalc'ed below
import matlab.unittest.internal.diagnostics.displayValue;

numColumns = 300; %#ok<NASGU>
valueDisplay = evalc('displayValue(value, shouldHyperlink, numColumns)');
valueDisplay = regexprep(valueDisplay, ...
    {'^\s*(ans|value) =[ \t\v\f]*[\r\n]*', '^\n+', '\n+$'}, '');
end

% LocalWords:  evalc'ed
