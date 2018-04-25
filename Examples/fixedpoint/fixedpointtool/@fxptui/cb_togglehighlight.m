function cb_togglehighlight
%CB_TOGGLEHILITE Add/remove hiliting of results that are potential issues.

%   Copyright 2010 The MathWorks, Inc.


me = fxptui.getexplorer;
if isempty(me); return; end
if me.isHiliteEnabled
    % remove highliting before restoring it.
    me.unhighlight;
    fxptui.cb_hiliteoverflows;
    fxptui.cb_highlightinfrange;
    me.highlightSUDInTree;
else % unhilite all results.
    me.unhighlight;
    me.highlightSUDInTree;
end

% [EOF]
