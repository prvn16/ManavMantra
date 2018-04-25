function setRunSelection(h, hDlg, hTag)
%SETSELECTION Set the Selection
%   OUT = SETSELECTION(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.

value = hDlg.getWidgetValue(hTag);
try
    h.selectedRunForDiff = h.runsForDiff{value+1};
catch e
    % consume error
end

% [EOF]
