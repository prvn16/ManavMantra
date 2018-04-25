function captureHierarchy(this)
% DISCOVERHIERARCHY Creates the node objects for the model components and
% chains them in a tree

% Copyright 2017 The MathWorks, Inc.

this.TopModelNode = this.createNode(this.BlockDiagram);
% Do not return tree nodes from a function. The MATLAB memory management
% will introduce a performance issue. Instead, pass in the parent node and
% connect the hierarchies in the function.
this.discoverSystemHierarchy(this.BlockDiagram, this.TopModelNode);

% Capture model reference hierarchy
try
    allModels = find_mdlrefs(this.BlockDiagram.getFullName);
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

this.SubModelNode = double.empty(0, numel(allModels)-1);
count = 1;
for i = 1:numel(allModels)
    if ~strcmpi(allModels{i}, this.BlockDiagram.getFullName)
        load_system(allModels{i});
        bdObj = get_param(allModels{i}, 'Object');
        if (count == 1)
            this.SubModelNode = this.createNode(bdObj);
        else
            this.SubModelNode(count) = this.createNode(bdObj);
        end
        this.discoverSystemHierarchy(bdObj, this.SubModelNode(count));
        count = count + 1;
    end
end
end