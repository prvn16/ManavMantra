function populate(h, varargin)
%POPULATE Populates the root
%   Copyright 2009-2012 MathWorks, Inc.
%   

if nargin == 1
    return;
end

mdlname = varargin{1}.getFullName; 
topmodeobj = get_param(mdlname, 'Object');

h.daobject = topmodeobj;

child = fxptui.BAETreeNode(topmodeobj);

h.children = child;
connect(h, child, 'down');

h.topchildren = child;
try
    [refMdls, ~] = find_mdlrefs(mdlname); 
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

% The last element in the list is the name of the model        
for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    load_system(refMdlName);
    refMdlObj = get_param(refMdlName, 'Object');
    refMdlchild = fxptui.BAESubMdlNode(refMdlObj);
    h.children(end+1) = refMdlchild;    
    connect(h, refMdlchild, 'down');
    % populate map with key of sub-model name and value of instances
%     mdlBlkInstanceNode = find(h, '-isa', 'fxptui.BAEMdlBlkNode', 'modelName', refMdlName);  %#ok<GTARG>
%     h.SubMdlToBlkMap.insert(refMdlName, mdlBlkInstanceNode);
end

% The last element in the list is the name of the model        
for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    % populate map with key of sub-model name and value of instances
    mdlBlkInstanceNode = find(h, '-isa', 'fxptui.BAEMdlBlkNode', 'modelName', refMdlName);  %#ok<GTARG>
    h.SubMdlToBlkMap.insert(refMdlName, mdlBlkInstanceNode);
end
