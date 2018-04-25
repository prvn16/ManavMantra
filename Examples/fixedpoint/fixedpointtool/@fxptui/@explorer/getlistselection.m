function selection = getlistselection(h)
%GELISTSELECTION get the first selected row in the listview

%   Copyright 2007 The MathWorks, Inc.

selection = [];
selections = h.getSelectedListNodes;
%get selection
if(~isempty(selections))
  %ignore multiple selections
  selection = selections(1);
end

% [EOF]
