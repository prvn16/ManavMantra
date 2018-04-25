function tb = createtoolbar_result(h, varargin)
%CREATETOOLBAR_RESULT 

%   Author(s): G. Taillefer
%   Copyright 2006 The MathWorks, Inc.

if(nargin > 1)
	tb = varargin{1};
else
	am = DAStudio.ActionManager;	
	tb = am.createToolBar(h);
end

action = h.getaction('VIEW_RUNCOMPARE');
tb.addAction(action);

action = h.getaction('VIEW_DIFFINFIGURE');
tb.addAction(action);

action = h.getaction('VIEW_TSINFIGURE');
tb.addAction(action);

action = h.getaction('VIEW_HISTINFIGURE');
tb.addAction(action);


% [EOF]
