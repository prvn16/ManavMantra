function captureCurrentSystemSettings(this)
% Capture the current DTO & RunName settings on the model. FPT will
% use this information to restore the settings after sim/derived
% actions.

% Copyright 2016-2017 The MathWorks, Inc.

% Launch it in hidden mode
originalDirtyFlag = get_param(this.Model,'Dirty');

currentSystem = this.Model;
batchName = fxptui.message('lblOriginalSettings');
if ~isempty(currentSystem)
    systems = getSystemsInModel(currentSystem);
    for idx = 1:length(systems)
        systemObj = get_param(systems{idx}, 'Object');
        saveSystemSettings(systemObj, this, batchName);
        saveGlobalSettings(systemObj, this , batchName);
    end
end

this.getShortcutManager.updateCustomShortcuts(batchName, 'add');

% Restore the dirty flag after capturing the original settings
set_param(this.Model,'Dirty', originalDirtyFlag);

end

%-----------------------------------------------------------------------
function saveSystemSettings(treeNode,this, batchName)
% Capture the blk settings

topModel = this.Model;
shortcutManager = this.getShortcutManager;
blkSID = Simulink.ID.getSID(treeNode);
settingMap = shortcutManager.getSystemSettingMapForShortcut(blkSID,batchName);
for m = {'DataTypeOverride','MinMaxOverflowLogging'}
    param = m{:};
    setting = 'UseLocalSettings';
    % The treeNode could be a Simulink.ModelReference object that does not
    % have either the DTO or MMO parameter.
    try
        setting = get_param(treeNode.getFullName,param);
    catch
    end
    % If the setting is UseLocal then there is no need to store it in the
    % map
    if ~strcmpi(setting, 'UseLocalSettings')
        % Save settings on the system
        try
            settingMap.insert(param,setting);
        catch
        end
        % Save both the daobject and the SID
        settingMap.insert('DAObject',treeNode);
        if isa(treeNode,'Simulink.ModelReference') ||...
                ~isequal(bdroot(treeNode.getFullName), topModel)
            node_parent_model = bdroot(treeNode.getFullName);
            if ~isequal(node_parent_model,topModel)
                topCh = getChildrenForSystem(topModel);
                topModelTracePath = '';
                for i = 1:length(topCh)
                    if fxptds.isStateflowChartObject(topCh(i))
                        topCh(i) = topCh(i).up;
                    end
                    if isa(topCh(i), 'Simulink.ModelReference')
                        if isequal(topCh(i).ModelName,node_parent_model)
                            topModelTracePath = {Simulink.ID.getSID(topCh(i))};
                            break;
                        end
                    end
                end
                if isempty(topModelTracePath)
                    children = getSystemsInModel(topModel);
                    modelName = node_parent_model;
                    while ~isequal(modelName, topModel)
                        breakOuterLoop = false;
                        for i = length(children):-1:1
                            child = children{i};
                            if isequal(modelName, child)
                                continue;
                            end
                            ch = getChildrenForSystem(child);
                            for np = 1:length(ch)
                                if isa(ch(np),'Simulink.ModelReference')
                                    if isequal(ch(np).ModelName, modelName)
                                        if isempty(topModelTracePath)
                                            topModelTracePath = {Simulink.ID.getSID(ch(np))};
                                        else
                                            topModelTracePath = [topModelTracePath, {Simulink.ID.getSID(ch(np))}]; %#ok<AGROW>
                                        end
                                        modelName = bdroot(ch(np).getFullName);
                                        breakOuterLoop = true;
                                        break;
                                    end
                                end
                            end
                            if breakOuterLoop
                                break;
                            end
                        end
                        % Forcefully break the while loop if we have reached the
                        % end of the iteration
                        if (i == 1)
                            modelName = topModel;
                        end
                    end
                end
                settingMap.insert('TopModelTracePath',topModelTracePath);
            end
        end
        settingMap.insert('SID',blkSID);
        
        
        if strcmpi(param,'DataTypeOverride') && ~strcmpi(treeNode.(param),'UseLocalSettings')
            try
                % The treeNode does not have this parameter
                settingMap.insert('DataTypeOverrideAppliesTo',treeNode.DataTypeOverrideAppliesTo);
            catch
                % We don't have to do anything here, If the parameter is not available on the object, we will not add it
                % to the shortcut map.
            end
        end
    end
end
children = getChildrenForSystem(treeNode.getFullName);
% Go through the entire tree and save active settings for all the nodes.
for i = 1:length(children)
    child = children(i);
    if fxptds.isStateflowChartObject(child)
        child = child.up;
    end
    saveSystemSettings(child, this, batchName);
end
end
%---------------------------------------------------------------------------------------------
function saveGlobalSettings(treeNode,this,batchName)
% Save the global data for the model. These parameters don't change per
% subsystem. Capture this data only once.

mdlSettingMap = this.getShortcutManager.getGlobalSettingMapForShortcut(batchName);

for m = {'DAObject','CaptureDTO','CaptureInstrumentation','ModifyDefaultRun'}
    param = m{:};
    switch param
        case 'DAObject'
            mdlSettingMap.insert(param, treeNode);
            mdlSettingMap.insert('SID',Simulink.ID.getSID(treeNode));
        otherwise
            mdlSettingMap.insert(param,true)
            mdlSettingMap.insert('RunName',get_param(this.Model, 'FPTRunName'));
    end
end
end

%--------------------------------------------------------------------------
function children = getChildrenForSystem(sysName)
% Get the children of a given system including model references.

bdObj = get_param(sysName,'Object');
chartObj = [];
if fxptds.isSFMaskedSubsystem(bdObj)
    chartObj = fxptds.getSFChartObject(bdObj);
end
children = bdObj.getHierarchicalChildren;
if ~isempty(children)
    children = find(children, '-depth',0, '-isa','Stateflow.Chart',...
        '-or','-isa', 'Stateflow.LinkChart',...
        '-or','-isa', 'Stateflow.EMChart',...
        '-or','-isa', 'Stateflow.TruthTableChart',...
        '-or','-isa', 'Stateflow.ReactiveTestingTableChart',...
        '-or','-isa', 'Stateflow.StateTransitionTableChart',...
        '-or','-isa', 'Simulink.SubSystem',...
        '-or','-isa', 'Simulink.ModelReference'); %#ok<GTARG>
    if ~isempty(chartObj)
        idx = find(children == chartObj);
        if ~isempty(idx)
            children(idx) = [];
        end
    end
end
end

%--------------------------------------------------------------------------
function mdls = getSystemsInModel(topModel)
% Get all the referenced models in the top model.
mdls = {topModel};
try
    [mdls, ~] = find_mdlrefs(topModel);
catch
end
end

% LocalWords:  lbl FPT
