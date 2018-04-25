function topNode = getTopNode(h)
%GETTOPNODE Get the top node, could be top model or model FPT launched from
%   OUT = GETAPPDATA(ARGS) <long description>

%   Copyright 2007 The MathWorks, Inc.

rootNode = h.getRoot;

if isa(rootNode, 'fxptui.BAERoot')
    topNode = rootNode.topchildren;
else
    % isa(rootNode, 'fxptui.baetreenode')
    topNode = rootNode;
end

% should assert of any other kinds of nodes were found 

% [EOF]
