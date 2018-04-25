function addChild(h, mdlObj)
%ADDCHILD Add a child to the hierarchy

%   Copyright 2012 MathWorks, Inc.

mdlname = mdlObj.getFullName;
child = fxptui.BAESubMdlNode(mdlObj);
if isempty(h.children)
    h.children = child;
else
    h.children(end+1) = child;
end
connect(h, child, 'down');
try
    [refMdls, ~] = find_mdlrefs(mdlname); 
catch  mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end


% The last element in the list is the name of the model        
for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    try
        load_system(refMdlName);
        refMdlObj = get_param(refMdlName, 'Object');
        mdlNode = find(h,'daobject',refMdlObj,'-isa','fxptui.BAESubMdlNode'); %#ok<*GTARG>
        if isempty(mdlNode)
            refMdlchild = fxptui.BAESubMdlNode(refMdlObj);
            h.children(end+1) = refMdlchild;
            connect(h, refMdlchild, 'down');
        end
    catch e %#ok<NASGU>
        % Model is probably not on path. ignore and continue.
    end
end

% The last element in the list is the name of the model        
for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    % populate map with key of sub-model name and value of instances
    mdlBlkInstanceNode = find(h, '-isa', 'fxptui.BAEMdlBlkNode', 'modelName', refMdlName);  %#ok<GTARG>
    h.SubMdlToBlkMap.insert(refMdlName, mdlBlkInstanceNode);
end

% [EOF]
