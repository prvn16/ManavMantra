function cb_clearallruns(varargin)
%CB_CLEARACTIVERUN   Action callback to clear all runs.

%   Copyright 2010-2014 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me)
    return; 
end
res = me.getresults;
if isempty(res)
    res = me.getBlkDgmResults;
end
if ~isempty(res)
    fxptds.AbstractActions.selectAndInvoke('clearAllRuns', res(1));
end





