function fptoolcallback(event, modelHndl)
%FPTOOLCALLBACK Responds to engine events in order to save the shortcuts in
%an external file.

%   Copyright 2011-2016 The MathWorks, Inc.


% Update the FPTDatset mapping if saving under a new name which will change
% the SID.
bd = get_param(modelHndl,'Object');
if (isempty(bd) || ~isa(bd, 'Simulink.BlockDiagram')), return; end
[~, oldMdlName,~] = fileparts(bd.PreviousFileName);
[~, newMdlName,~] = fileparts(bd.FileName);
me = fxptui.getexplorer;

if strcmpi(event,'presave')
    if ~isempty(bd.MinMaxOverflowArchiveData)
        fptRepositoryInstance = fxptds.FPTRepository.getInstance;
        sources = fptRepositoryInstance.getAllSources;
        % We need to reconstruct the SID based on new name
        for i = 1:length(sources)
            curSource = sources{i};
            idx = regexp(curSource,['^',regexptranslate('escape',oldMdlName),'$'],'once');
            if isempty(idx)
                idx = regexp(curSource,['^',regexptranslate('escape',oldMdlName),'\s*:\s*\d+','$'],'once');
            end
            % The source needs to be updated
            if ~isempty(idx)
                idx1 = regexp(curSource,':','start');
                if ~isempty(idx1)
                    newSID = [newMdlName curSource(idx1:end)];
                else
                    newSID = newMdlName;
                end
                if ~strcmp(curSource, newSID)
                    fptRepositoryInstance.updateSourceNameForDataset(curSource, newSID);
                    if slfeature('FPTWeb')
                        % The new source should match the dataset source 
                        % strings. For Model references, the dataset source is the block SID.                        
                        fxptui.FPTModelSaveAsUtility.updateScopingEngine(curSource, newSID);
                    end
                end
            else
                % check if this is a referenced model block that is pointing
                % to a model that just got renamed.
                try
                    blkHndl = Simulink.ID.getHandle(curSource);
                    blkObj = get_param(blkHndl, 'Object');
                    % This additional check only applies to model
                    % reference. All other cases should be resolved in the
                    % above 'if' branch.
                    if isa(blkObj,'Simulink.ModelReference')
                        modelName = get_param(blkHndl,'ModelName');
                        % If the model name points to the one being
                        % renamed, then clear out the results contained.
                        % This gives the same behavior as if the model it
                        % was pointing to was closed (since it it no longer
                        % in memory)
                        idx = regexp(modelName,['^',regexptranslate('escape',oldMdlName),'$'],'once');
                        if ~isempty(idx)
                            topModel = Simulink.ID.getModel(curSource);
                            topApplicationData = SimulinkFixedPoint.getApplicationData(topModel);
                            if topApplicationData.subDatasetMap.isKey(blkHndl)
                                subDataset = topApplicationData.subDatasetMap(blkHndl);
                                runNames = subDataset.getAllRunNames();
                                subDataset.clearResultsInRuns;
                                
                                for ridx = 1:numel(runNames)
                                   subDataset.cleanupForRunDeletion({runNames{ridx}}); 
                                end
                                
                            end
                        end
                    end
                catch
                    continue;
                    % ignore error and continue
                end
            end
        end
    end
end


switch lower(event)
    case 'presave'
        if ~(isempty(me) || ~isa(me, 'fxptui.explorer'))
            topModel = me.getTopNode.getDAObject;
            if (isempty(topModel) || ~isa(topModel, 'Simulink.BlockDiagram')), return; end
            % Respond to events only if the FPT object is valid.
            if isequal(bd, topModel)
                % Update only if the model name is different.
                if ~strcmpi(newMdlName, oldMdlName)
                    updateShortcutsForModelNameChange(me, bd, oldMdlName);
                end
                me.saveshortcuts(bd);
            elseif ~isempty(bd.PreviousFileName)
                % If the model being saved is a referenced model, then just
                % edit the shortcut maps with the new name.
                try
                    [refMdls, ~]      = find_mdlrefs(topModel.getFullName);
                    [~, oldMdlName,~] = fileparts(bd.PreviousFileName);
                    [~, newMdlName,~] = fileparts(bd.FileName);
                    % Update only if the modle name is different.
                    if ~strcmpi(newMdlName, oldMdlName) && any(ismember(refMdls,oldMdlName))
                        updateShortcutsForModelNameChange(me, bd, oldMdlName);
                    end
                catch mdl_not_found_exception % Model not on path.
                    fxptui.showdialog('modelnotfound',mdl_not_found_exception);
                    return;
                end
            end
        elseif slfeature('FPTWeb')
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            if ~isempty(fptInstance)
                topModel = fptInstance.getModelObject;
                shortcutMgr = fptInstance.getShortcutManager;
                % Respond to events only if the FPT object is valid.
                if isequal(topModel, bd)
                    % Update only if the model name is different.
                    if ~strcmpi(newMdlName, oldMdlName)
                        shortcutMgr.updateShortcutsForModelNameChange(bd, oldMdlName);
                    end
                    shortcutMgr.saveShortcuts;
                elseif ~isempty(bd.PreviousFileName)
                    % If the model being saved is a referenced model, then just
                    % edit the shortcut maps with the new name.
                    try
                        [refMdls, ~]      = find_mdlrefs(topModel.getFullName);
                        [~, oldMdlName,~] = fileparts(bd.PreviousFileName);
                        [~, newMdlName,~] = fileparts(bd.FileName);
                        % Update only if the modle name is different.
                        if ~strcmpi(newMdlName, oldMdlName) && any(ismember(refMdls,oldMdlName))
                            shortcutMgr.updateShortcutsForModelNameChange(bd, oldMdlName);
                        end
                    catch mdl_not_found_exception % Model not on path.
                        fxptui.showdialog('modelnotfound',mdl_not_found_exception);
                        return;
                    end
                end
            end
        end
    case 'updatesiglogdata'
        if slfeature('FPTWeb')
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            if ~isempty(fptInstance)
                topModel = get_param(fptInstance.getModel,'Object');
                if (isempty(topModel) || ~isa(topModel, 'Simulink.BlockDiagram')), return; end
                currHandle = get_param(topModel.getFullName,'Handle');
                if isequal(modelHndl, currHandle)
                    fptInstance.postProcessSimulationData;
                else
                    % FPT root could be a referenced model and the parent was
                    % simulated.
                    try
                        [~, childM] = find_mdlrefs(bd.getFullName);
                    catch mdl_not_found_exception %#ok<NASGU> % Model not on path.
                    end
                    if isempty(childM); return; end % no referenced models
                    try
                        for i = 1:length(childM)
                            childNames = get_param(childM{i}, 'ModelName');
                            if isequal(get_param(childNames,'Handle'),currHandle)
                                fptInstance.postProcessSimulationData;
                                break;
                            end
                        end
                    catch e %#ok<NASGU>
                        disp error% ignore error as model might not be loaded.
                    end
                end
                fptInstance.updateData('append');
                ed = fxptui.FPTEventDispatcher.getInstance;
                ed.broadcastEvent('DataUpdated',fxptui.UIEventData('done'));
                % This callback is invoked only after InspectLoggedSignals
                % has been processed in
                % DefaultSimulationExecutionInstance.cpp. We will restore
                % the settings here with the assumption that all data has
                % been added.
                fptInstance.notify('SimulationDataCompleteEvent');
            end
        end
        if (isempty(me) || ~isa(me, 'fxptui.explorer')), return; end
        topModel = me.getTopNode.getDAObject;
        if (isempty(topModel) || ~isa(topModel, 'Simulink.BlockDiagram')), return; end
        
        currHandle = get_param(topModel.getFullName,'Handle');
        if isequal(modelHndl, currHandle)
            hupdatedata(me);
        else
            % FPT root could be a referenced model and the parent was
            % simulated.
            try
                [~, childM] = find_mdlrefs(bd.getFullName);
            catch mdl_not_found_exception %#ok<NASGU> % Model not on path.
            end
            if isempty(childM); return; end % no referenced models
            try
                for i = 1:length(childM)
                    childNames = get_param(childM{i}, 'ModelName');
                    if isequal(get_param(childNames,'Handle'),currHandle)
                        hupdatedata(me);
                        break;
                    end
                end
            catch e %#ok<NASGU>
                % ignore error as model might not be loaded.
            end
        end
    otherwise
        % Do nothing.
end
end

% [EOF]

% LocalWords:  presave FPT fxptui updatesiglogdata modelnotfound
