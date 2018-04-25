function changeDTXFracSpanText(ntx,hThisMenu)
% Change fraction span text display option
% 1 = Fraction length
% 2 = Scale factor

%   Copyright 2010 The MathWorks, Inc.

% Get selected value from userdata of context menu
ntx.DTXFracSpanText = get(hThisMenu,'UserData');
initHistDisplay(ntx);
