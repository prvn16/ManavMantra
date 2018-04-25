function delete(this)
% DELETE Deletes the contained objects

% Copyright 2017 The MathWorks, Inc.

modelNodes = [this.TopModelNode this.SubModelNode];
this.unpopulate(modelNodes);
delete(this.ChildParentMap);
uniqueIDKeys = this.UniqueIDMap.keys;
scopingEngine = fxptds.FPTGUIScopingEngine.getInstance();
for i = 1:numel(uniqueIDKeys)
    scopingEngine.removeSubsystemIDFromMap(uniqueIDKeys{i});
end
delete(this.UniqueIDMap);
this.ChildParentMap = [];
this.UniqueIDMap = [];
this.TopModelNode = [];
this.SubModelNode = [];
this.BlockDiagram = [];
