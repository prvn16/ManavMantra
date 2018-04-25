function tb = createtoolbar_collectdata(h, varargin)
%CREATETOOLBAR_COLLECTDATA   

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;
	tb = am.createToolBar(h);
end

action = h.getaction('START');
tb.addAction(action);

action = h.getaction('PAUSE');
tb.addAction(action);

action = h.getaction('STOP');
tb.addAction(action);

action = h.getaction('DERIVE');
tb.addAction(action);

% [EOF]
