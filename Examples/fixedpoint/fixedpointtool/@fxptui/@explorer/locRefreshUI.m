function locRefreshUI(h)
% LOCREFRESHUI Refreshes the list and hierarchy of FPT

% Copyright 2014-2015 The MathWorks, Inc.

% Update the UI when the dataset changes.
h.getFPTRoot.firePropertyChanged;
h.getFPTRoot.fireHierarchyChanged;
refreshDetailsDialog(h);


%----------------------------------------------------------------------