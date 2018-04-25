function b = isValidTreeNode(this)
% ISVALIDTREENODE Returns true of the object being represented by the tree node is a supported node

% Copyright 2014 MathWorks, Inc

b = false;
clz = class(this.DAObject);
switch clz
  case{'Simulink.SubSystem', 'Simulink.BlockDiagram', 'Stateflow.Chart', 'Simulink.ModelReference'}
    b = true;
  otherwise
end
