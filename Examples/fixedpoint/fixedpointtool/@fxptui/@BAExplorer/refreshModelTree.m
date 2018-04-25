function isRefreshed = refreshModelTree(this)
% REFRESHMODELTREE Reloads all the referenced models if it was previously closed.

%     Copyright  2012 MathWorks, Inc.


isRefreshed = false;

mdlroot = this.getTopNode;
try
    [refMdls, ~] = find_mdlrefs(mdlroot.daobject.getFullName);
    if numel(refMdls) == 1 % only listed root model
        return; 
    end
catch mdl_not_found_exception % Model not on path.
    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
    return;
end

for idx = 1:(length(refMdls)-1)
    refMdlName = refMdls{idx};
    try
        load_system(refMdlName);
        mdlObj = get_param(refMdlName,'Object');
        mdlNode = find(this.getRoot,'daobject',mdlObj,'-isa','fxptui.BAESubMdlNode'); %#ok<GTARG>
        if isempty(mdlNode)
            addNodeToTree(this, mdlObj);
            isRefreshed = true;
        end
    catch e %#ok<NASGU>
        % Model is probably not on path. Ignore and continue.
    end
end
