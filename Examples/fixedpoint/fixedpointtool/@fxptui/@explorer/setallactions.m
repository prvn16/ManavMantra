function setallactions(h, state)
%SETALLACTIONS   

%   Author(s): G. Taillefer
%   Copyright 2006-2015 The MathWorks, Inc.

if(~ismember(state, {'on', 'off'}))
    return;
end
h.backupactionstate;
actionnames = h.getaction_names;
for i = 1:numel(actionnames)
    h.getaction(actionnames{i}).Enabled = state;
end

h.ExternalViewer.updateGlobalEnabledState(strcmp(state, 'on'));


% [EOF]
