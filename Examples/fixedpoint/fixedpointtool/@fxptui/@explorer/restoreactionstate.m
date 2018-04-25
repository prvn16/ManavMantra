function restoreactionstate(h)
%RESTOREACTIONSTATE   

%   Author(s): G. Taillefer
%   Copyright 2006-2015 The MathWorks, Inc.

actionnames = h.actionstate.keySet.toArray;
for i = 1:numel(actionnames)
	action = actionnames(i);
	state = h.actionstate.get(action);
	h.getaction(action).Enabled = state;
end

h.ExternalViewer.updateGlobalEnabledState(true);
    
% [EOF]
