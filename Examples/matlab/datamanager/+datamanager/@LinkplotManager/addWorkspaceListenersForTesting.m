function addWorkspaceListenersForTesting(h)
%   This function is undocumented and will change in a future release

%   Copyright 2011 The MathWorks, Inc.

if ~isempty(h.LinkListener)
    com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.removeWorkspaceChangeObserver(...
        h.LinkListener);
    com.mathworks.mlwidgets.workspace.MatlabWorkspaceListener.addWorkspaceChangeObserverNoUpdate(...
        h.LinkListener);
end