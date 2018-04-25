function cb_hiliteoverflows
%CB_HILITEOVERFLOWS <short description>
%   OUT = CB_HILITEOVERFLOWS(ARGS) <long description>

%   Copyright 2010 The MathWorks, Inc.

me = fxptui.getexplorer;
if isempty(me); return; end
res = [me.getBlkDgmResults me.getMdlBlkResults];

for i = 1:length(res)
    if res(i).hasOverflows
        me.hilightListNode(res(i),[0.7 0 0])
    end
end

% [EOF]
