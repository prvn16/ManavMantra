function backupactionstate(h)
%BACKUPACTIONSTATE   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

actionnames = h.getaction_names;
h.actionstate.clear;
for i = 1:numel(actionnames)
	action = actionnames{i};
	state = h.getaction(action).Enabled;
	h.actionstate.put(action, state);
end

% [EOF]
