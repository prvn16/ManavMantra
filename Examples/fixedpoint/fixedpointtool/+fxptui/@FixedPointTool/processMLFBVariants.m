function processMLFBVariants(this, addedvariants)
% PROCESSMLFBVARIANT Process the variant subsystems added during the apply
% phase.

% Copyright 2016-2017 The MathWorks, Inc.

dataController = this.getDataController;

% Update the tree
for i = 1:numel(addedvariants)
    mlfbVariantSubsys = addedvariants(i);
    if isa(mlfbVariantSubsys, 'Simulink.SubSystem')
        variantParent = mlfbVariantSubsys.getParent;                
        existingNode = this.ModelHierarchy.findNode('Object', mlfbVariantSubsys);
        if isempty(existingNode) || ~isequal(existingNode.getParent.Object, variantParent)
            this.ModelHierarchy.addVariantToParent(mlfbVariantSubsys, variantParent);
        end
    end
end

% Update the spreadsheet mapping
newTreeData = this.ModelHierarchy.getAddedTreeData;
if ~isempty(newTreeData)
    viewDS = dataController.getViewDataset;
    viewDS.updateSpreadsheetMappingForVariantAddition({newTreeData});
end

