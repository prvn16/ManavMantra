function cb_togglehighlightoption
% CB_TOGGLEHIGHLIGHTOPTION Toggles the option to highlight results with
% issues

% Copyright 2015 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me); return; end
me.isHiliteEnabled = ~me.isHiliteEnabled;
fxptui.cb_togglehighlight;
