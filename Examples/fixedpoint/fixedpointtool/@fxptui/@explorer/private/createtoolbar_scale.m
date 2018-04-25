function tb = createtoolbar_scale(h, varargin)
%CREATETOOLBAR_DATA

%   Author(s): G. Taillefer
%   Copyright 2006-2015 The MathWorks, Inc.

if(nargin > 1)
  tb = varargin{1};
else
  am = DAStudio.ActionManager;
  tb = am.createToolBar(h);
end

action = h.getaction('SCALE_PROPOSEDT');
tb.addAction(action);

action = h.getaction('SCALE_APPLYDT');
tb.addAction(action);

% [EOF]
