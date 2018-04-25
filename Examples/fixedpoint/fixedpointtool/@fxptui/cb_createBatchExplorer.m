function cb_createBatchExplorer
%CB_CREATEBATCHEXPLORER <short description>
%   OUT = CB_CREATEBATCHEXPLORER(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.


me = fxptui.getexplorer;
if ~isempty(me)
    createBatchExplorer(me);
end

% [EOF]
