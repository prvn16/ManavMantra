function createBatchExplorer(h)
%CREATEBATCHEXPLORER <short description>
%   OUT = CREATEBATCHEXPLORER(ARGS) <long description>

%   Copyright 2012   MathWorks, Inc.

% Create the BatchSetting Explorer

h.BAExplorer = fxptui.BAExplorer(h.getFPTRoot.getDAObject);

% [EOF]
