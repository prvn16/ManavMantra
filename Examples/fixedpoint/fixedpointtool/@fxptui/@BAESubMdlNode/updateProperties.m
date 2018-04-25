function updateProperties(this, prop, propVal)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

% identify the model reference block used in the model
% find the block from root
baexplr = fxptui.BAExplorer.getBAExplorer;
root = baexplr.getRoot;
ModelBlksNode = root.SubMdlToBlkMap.getDataByKey(this.daobject.getFullName);

for index = 1:length(ModelBlksNode)
    ModelBlksNode(index).(prop) = propVal;
    ModelBlksNode(index).firepropertychange;
end

this.(prop) = propVal;
% broadcast changes on submodel node
this.firepropertychange;

% [EOF]

% LocalWords:  fxptui BAE daobject cbo appliesto
