function mdlList = getValidSystemList(system)
% GETALLVALIDSYSTEMS Get all the valid referenced models and model blocks
% that are under a given system. This supports the F2F workflow needs

% Copyright 2016 The MathWorks, Inc. 

systemObj = get_param(system,'Object');
source = bdroot(system);
% Need to look for referenced models under the specified system
model = system;
refMdls = {};
mdlBlks = {};

isValidModel = true;
if isa(systemObj,'Simulink.ModelReference')
    source = system;
    % For a model reference, we need to look at the hierarchy under the referenced model.
    model = systemObj.ModelName;    
end

% Find all referenced models and model block instances under a give
% system. If any of the referenced models are not on the path, the API will
% error out. For the purposes of the F2F workflow, we will do the below when
% the API errors out: 
% 1) If the system is a model instance block, then try to load the model it 
% points to.  
% 2) If the loading errors out, it means that the model instance block is 
% not pointing to a valid model and its dataset should not be taken into 
% account.  
% 3) If the model loads successfully, then even though the API errors out, 
% the data for the submodel should be considered.  The above scenario is an 
% edge case, but needs to be handled for the proper functioning of the workflow.
errorLoadingModels = false;
try
    [refMdls, mdlBlks] = find_mdlrefs(model);
catch       
    % Could not find referenced models. Ignore error
    errorLoadingModels = true;
end

if errorLoadingModels
    try
        load_system(model);
    catch
        isValidModel = false;
    end    
end

mdlList = [refMdls', mdlBlks'];
% Add the model block as a source if the system was a model block.
if isValidModel
    mdlList = [mdlList, source];
    % Add the submodel to the list if there were errors loading the
    % referenced model under the model block
    if errorLoadingModels
        mdlList = [mdlList, model];
    end
end

% Remove duplicates
mdlList = unique(mdlList);
