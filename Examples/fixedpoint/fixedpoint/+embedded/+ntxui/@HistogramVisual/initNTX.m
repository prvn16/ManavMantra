function initNTX(this, hVisParent)
%INITNTX  Initializes the NTXUI object. This creates the new histogram visual.

%   Copyright 2010-2017 The MathWorks, Inc.

embedded.ntxui.HistogramVisual.setPosition(this.Application.Parent);
this.NTExplorerObj = embedded.ntxui.NTX(hVisParent);

% [EOF]
