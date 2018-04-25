function tb = createtoolbar_launchfpa(h, varargin)
%CREATETOOLBAR_LAUNCHFPA

%   Copyright 2006-2015 The MathWorks, Inc.

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;
	tb = am.createToolBar(h);
end

action = h.getaction('LAUNCHFPA');
tb.addAction(action);

if fxptui.isMATLABFunctionBlockConversionEnabled()
    action = h.getaction('OPEN_CODE_VIEW');
    tb.addAction(action);
end

% [EOF]
