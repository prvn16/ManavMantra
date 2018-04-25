function cb_opensignaldlg_sys(idx)
%CB_OPENSIGNALDLG_SYS opens the Signal Properties dialog for the outport of
%this block

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

fxptui.AbstractTreeNodeActions.selectAndInvoke('openSignalDialog');

% [EOF]
