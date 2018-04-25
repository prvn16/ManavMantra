function treenode = getSystemForDerive(me)
% GETSYSTEMFORDERIVE Gets the system to perform range analysis on based on
% the user specified option

% Copyright 2015 The MathWorks, Inc.

switch me.DeriveChoice
    case 0
        treenode = me.getSUDUINode;
    case 1
        treenode = me.getTopNode;
end
    