function success = loadReferencedModels(this)
% LOADREFERENCEDMODELS Loads all models referenced by the top model on
% which FPT is open.

% Copyright 2015-2017 The MathWorks, Inc.

    success = true;
    try
        [refMdls, ~] = find_mdlrefs(this.Model);
        if numel(refMdls) == 1 % only listed root model
            return;
        end
    catch mdl_not_found_exception % Model not on path.
        success = false;
        fxptui.showdialog('modelnotfound',mdl_not_found_exception);
        return;
    end
    
    for idx = 1:(length(refMdls)-1)
        refMdlName = refMdls{idx};
        load_system(refMdlName);
    end
end

% LocalWords:  modelnotfound
