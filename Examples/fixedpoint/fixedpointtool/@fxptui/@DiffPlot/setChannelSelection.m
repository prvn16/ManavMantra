function setChannelSelection(h, hDlg, hTag)
%SETCHANNELSELECTION Set the Selection
%   OUT = SECHANNELTSELECTION(ARGS) <long description>

%   Copyright 2011 The MathWorks, Inc.

value = hDlg.getWidgetValue(hTag);
try
    h.selectedChannelForDiff = value+1;
catch e
    % consume error
end
