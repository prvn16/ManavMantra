function updateProperties(this, prop, propVal)
%SETPROPERTIES Set the Properties
%   OUT = SETPROPERTIES(ARGS) <long description>

%   Copyright 2010-2012 The MathWorks, Inc.

objectHandle = get_param(this.modelName, 'Object');
% identify the sub-models
subMdlName = this.daobject.ModelName;
% find the block from root
baexplr = fxptui.BAExplorer.getBAExplorer;
root = baexplr.getRoot;
subModelNode = find(root.Children, '-isa', 'fxptui.BAESubMdlNode', 'daobject', objectHandle);  %#ok<GTARG>

allInstances = root.SubMdlToBlkMap.getDataByKey(subMdlName);

for index = 1:length(allInstances)
    allInstances(index).(prop) = propVal;
    allInstances(index).firepropertychange;
end
subModelNode.(prop) = propVal;
% broadcast changes on submodel node
subModelNode.firepropertychange;

% [EOF]

% LocalWords:  fxptui BAE daobject cbo appliesto
