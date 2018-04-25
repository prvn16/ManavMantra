function str = createClassNameForCommandWindow(name)
% This function is undocumented.

%  Copyright 2012-2016 MathWorks, Inc.

import matlab.unittest.internal.diagnostics.CommandHyperlinkableString;
import matlab.unittest.internal.getSimpleParentName;

str = CommandHyperlinkableString(getSimpleParentName(name), ['helpPopup ', name], ...
    'font-weight:bold');

% LocalWords:  Hyperlinkable
