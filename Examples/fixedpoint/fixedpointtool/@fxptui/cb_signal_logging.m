function cb_signal_logging(varargin)
%CB_SIGNAL_LOGGING turn signal logging on for all blocks in the
%selected subsystem and below

%   Copyright 2007-2012 The MathWorks, Inc.

fxptui.AbstractTreeNodeActions.selectAndInvoke('logAllSignals');

% me =  fxptui.explorer;
% me.getTopNode.enablesiglog;
% selection = me.imme.getCurrentTreeNode;
% me.sleep;
% selection.setlogging(varargin{:});
% me.wake;

% [EOF]
