classdef WorkflowController < handle
    % WORKFLOWCONTROLLER Handles server-client communication for model and proposal settings
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access = 'private')
        ApplyConfigurationSubChannel = '/fpt/applyConfiguration';
        ShortcutPublishChannel = '/fpt/customshortcutinfo';
        CollectRunNamePublishChannel = '/fpt/collectrunNameinfo';
        VerifyRunNamePublishChannel = '/fpt/verifyrunNameinfo';
        SimPublishChannel = '/fpt/simSettinginfo';
        SimSettingChannel = '/fpt/updateSimSetting';
        ShortcutGetCollectRunNameChannel = '/fpt/getCollectRunName';
        ShortcutGetVerifyRunNameChannel = '/fpt/getVerifyRunName';
        ProposalOptionChannel = '/fpt/updateProposalOptions';
        ProposalOptionPublishChannel = '/fpt/proposalOptionInfo';
        RangeModeUpdateChannel = '/fpt/updateRangeModes';
        UpdateCustomShortcutsPublishChannel = '/fpt/customshortcutinfo';
        TriggerProposalActionChannel = '/fpt/codeview/proposal';
        TriggerApplyActionChannel = '/fpt/codeview/apply';
        PublishProposalOptionsValidity = '/fpt/proposalOptionsValidation';
        Subscriptions
        UpdateCustomShortcutsListener
        Model
    end
    
    events
        UpdateCustomShortcuts;
    end
    
    methods
        function this = WorkflowController(uniqueID)
            % Ensure the connector is on before subscribing
            connector.ensureServiceOn;
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            mgr = fptInstance.getShortcutManager;
            
            this.initializeSubscriptions(uniqueID);
            
            this.ShortcutPublishChannel = sprintf('%s/%s',this.ShortcutPublishChannel, uniqueID);
            this.UpdateCustomShortcutsPublishChannel = sprintf('%s/%s',this.UpdateCustomShortcutsPublishChannel, uniqueID);
            this.SimPublishChannel = sprintf('%s/%s',this.SimPublishChannel, uniqueID);
            this.ProposalOptionPublishChannel = sprintf('%s/%s',this.ProposalOptionPublishChannel, uniqueID);
            this.PublishProposalOptionsValidity = sprintf('%s/%s',this.PublishProposalOptionsValidity, uniqueID);
            this.CollectRunNamePublishChannel = sprintf('%s/%s',this.CollectRunNamePublishChannel, uniqueID);
            this.VerifyRunNamePublishChannel = sprintf('%s/%s',this.VerifyRunNamePublishChannel, uniqueID);
            this.TriggerProposalActionChannel = sprintf('%s/%s',this.TriggerProposalActionChannel, uniqueID);
            this.TriggerApplyActionChannel = sprintf('%s/%s',this.TriggerApplyActionChannel, uniqueID);
            
            this.UpdateCustomShortcutsListener = addlistener(mgr, 'UpdateCustomShortcuts', @this.publishUpdateCustomShortcuts);
        end
    end
    
    methods(Hidden)
        function setModel(this, modelName)
            this.Model = modelName;
        end
        
        function publishData(this)
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            mgr = fptInstance.getShortcutManager;
            customShortcutMap = mgr.getCustomShortcuts;
            customNames = {''};
            for i = 1:customShortcutMap.getCount
                customNames{i} = customShortcutMap.getKeyByIndex(i);
            end
            
            message.publish(this.ShortcutPublishChannel, customNames);
            message.publish(this.SimPublishChannel, get_param(this.Model,'MinMaxOverflowArchiveMode'));
            this.publishProposalOptions();
        end
        
        
        function publishProposalOptions(this)
            appData = SimulinkFixedPoint.getApplicationData(this.Model);
            proposalOptions = appData.AutoscalerProposalSettings;
            serverProposalOptions.isAutoSignedness = proposalOptions.isAutoSignedness;
            serverProposalOptions.isWLSelectionPolicy = proposalOptions.isWLSelectionPolicy;
            serverProposalOptions.ProposeForInherited = proposalOptions.ProposeForInherited;
            serverProposalOptions.ProposeForFloatingPoint = proposalOptions.ProposeForFloatingPoint;
            serverProposalOptions.DefaultWordLength = proposalOptions.DefaultWordLength;
            serverProposalOptions.DefaultFractionLength = proposalOptions.DefaultFractionLength;
            serverProposalOptions.isUsingSimMinMax = proposalOptions.isUsingSimMinMax;
            serverProposalOptions.isUsingDerivedMinMax = proposalOptions.isUsingDerivedMinMax;
            serverProposalOptions.SafetyMarginForSimMinMax = proposalOptions.SafetyMarginForSimMinMax;
            
            message.publish(this.ProposalOptionPublishChannel, serverProposalOptions);
        end
        
        function delete(this)
            for i = 1:numel(this.Subscriptions)
                message.unsubscribe(this.Subscriptions{i});
            end
            delete(this.UpdateCustomShortcutsListener);
            this.UpdateCustomShortcutsListener = [];
            this.Subscriptions = [];
        end
        
        function triggerProposalForCodeView(this)
            % Triggers the proposal action from the client when requested
            % by codeview. We do this so that the user will be given the
            % correct run selection dialog when needed.
            msgObj.message = 'propose';
            message.publish(this.TriggerProposalActionChannel,msgObj);
        end
        
        function triggerApplyForCodeView(this)
            % Triggers the apply action from the client when requested
            % by codeview. We do this so that the user will be given the
            % correct run selection dialog when needed.
            msgObj.message = 'apply';
            message.publish(this.TriggerApplyActionChannel,msgObj);
        end
        
        function publishProposalOptionsValidity(this, data)
            % Notify the client when an invalid input is specified to the
            % proposal options widgets
            
            % Manipulate the identifier in Exception object to identify the
            % settings that was changed
            % Identifier - SimulinkFixedPoint:autoscalerProposalSettings:invalidSafetyMargin
            % msgObj.identifier - invalidSafetyMargin
            identifier = strsplit(data.identifier, ':');
            msgObj.identifier = identifier{end};
            msgObj.statusText = data.message;
            message.publish(this.PublishProposalOptionsValidity, msgObj);
        end
        
        function success = updateProposalOptions(this, clientData)
            success = true;
            appData = SimulinkFixedPoint.getApplicationData(this.Model);
            proposalSetting = appData.AutoscalerProposalSettings;
            try
                if isfield(clientData, 'RangeOption')
                    switch clientData.RangeOption
                        case 0
                            proposalSetting.isUsingSimMinMax = true;
                            proposalSetting.isUsingDerivedMinMax = true;
                        case 1
                            proposalSetting.isUsingSimMinMax = true;
                            proposalSetting.isUsingDerivedMinMax = false;
                        case 2
                            proposalSetting.isUsingSimMinMax = false;
                            proposalSetting.isUsingDerivedMinMax = true;
                    end
                end
                if isfield(clientData, 'isAutoSignedness')
                    proposalSetting.isAutoSignedness = clientData.isAutoSignedness;
                end
                if isfield(clientData, 'isWLSelectionPolicy')
                    proposalSetting.isWLSelectionPolicy = clientData.isWLSelectionPolicy;
                end
                if isfield(clientData, 'ProposeForInherited')
                    proposalSetting.ProposeForInherited = clientData.ProposeForInherited;
                end
                if isfield(clientData, 'ProposeForFloatingPoint')
                    proposalSetting.ProposeForFloatingPoint = clientData.ProposeForFloatingPoint;
                end
                if isfield(clientData, 'DefaultWordLength')
                    proposalSetting.DefaultWordLength = clientData.DefaultWordLength;
                end
                if isfield(clientData, 'DefaultFractionLength')
                    % Fractional/ Decimal values entered by the
                    % user are rounded and sent to the client. If an invalid/
                    % out of range value is entered, the server sends the
                    % last valid value
                    proposalSetting.DefaultFractionLength = clientData.DefaultFractionLength;
                end
                if isfield(clientData, 'SafetyMarginForSimMinMax')
                    % safetyMargin in (-100, Inf)
                    proposalSetting.SafetyMarginForSimMinMax = clientData.SafetyMarginForSimMinMax;
                end
            catch err
                success = false;
                % Invalid Proposal Settings value. Notify the client
                this.publishProposalOptionsValidity(err);
                return;
            end
            this.publishProposalOptions;
        end        
    end
    
    methods(Access='private')
        function initializeSubscriptions(this, uniqueID)
            this.Subscriptions{1} = message.subscribe(sprintf('%s/%s',this.ApplyConfigurationSubChannel,uniqueID), @(config)this.applyConfiguration(config));
            this.Subscriptions{2} = message.subscribe(sprintf('%s/%s',this.SimSettingChannel,uniqueID), @(clientData)this.applySimSetting(clientData));
            this.Subscriptions{3} = message.subscribe(sprintf('%s/%s',this.ShortcutGetCollectRunNameChannel,uniqueID), @(clientData, e)this.publishRunName(clientData, 'collect'));
            this.Subscriptions{4} = message.subscribe(sprintf('%s/%s',this.ShortcutGetVerifyRunNameChannel,uniqueID), @(clientData, e)this.publishRunName(clientData, 'verify'));
            this.Subscriptions{5} = message.subscribe(sprintf('%s/%s',this.ProposalOptionChannel,uniqueID), @(clientData, e)this.updateProposalOptions(clientData));
            this.Subscriptions{6} = message.subscribe(sprintf('%s/%s',this.RangeModeUpdateChannel, uniqueID), @(clientData) this.updateRangeModeSelection(clientData));
        end
        
        function applyConfiguration(this, config)
            % Get the FPT instance on which the settings are being made
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            
            % Get the shortcut to be applied
            shortcutName = this.getShortcutName(config.configSetting.label);
            fptInstance.getShortcutManager.applyShortcut(shortcutName);
            
            if ~isempty(config.runName)
                set_param(fptInstance.getModel,'FPTRunName',config.runName);
            end
        end
        
        function applySimSetting(this, clientData)
            if clientData.mergeOption
                set_param(this.Model,'MinMaxOverflowArchiveMode','merge');
            else
                set_param(this.Model,'MinMaxOverflowArchiveMode','overwrite');
            end
        end
        
        function shortcutName = getShortcutName(~, shortcutName)
            switch shortcutName
                case 'UseCurrent'
                    shortcutName = '';
                case 'DoubleOverride'
                    shortcutName = fxptui.message('lblDblOverride');
                case 'SingleOverride'
                    shortcutName = fxptui.message('lblSglOverride');
                case 'ScaledDoubles'
                    shortcutName = fxptui.message('lblSclDblOverride');
                case 'SpecifiedType'
                    shortcutName = fxptui.message('lblFxptOverride');
                otherwise
            end
        end
        
        function publishRunName(this, clientData, phase)
            fptInstance = fxptui.FixedPointTool.getExistingInstance;
            mgr = fptInstance.getShortcutManager;
            runName = '';
            shortcutName = this.getShortcutName(clientData.name);
            if ~isempty(shortcutName)
                runName = mgr.getRunNameForShortcut(shortcutName);
            end
            if isempty(runName)
                runName = get_param(this.Model,'FPTRunName');
            end
            if strcmpi(phase, 'collect')
                message.publish(this.CollectRunNamePublishChannel,runName);
            else
                message.publish(this.VerifyRunNamePublishChannel,runName);
            end
        end
        
        function publishUpdateCustomShortcuts(this, ~, eventdata)
            msgObj = struct('customShortcut',{eventdata.CustomShortcut}, 'action',eventdata.Action);
            message.publish(this.UpdateCustomShortcutsPublishChannel, msgObj);
        end
              
        function updateRangeModeSelection(this, clientData)
            fpt = fxptui.FixedPointTool.getExistingInstance;
            if ~isempty(fpt)
                shortcutManager = fpt.getShortcutManager;
                shortcutName = this.getShortcutName(clientData.name);
                if strcmpi(clientData.stage, 'rangecollection')
                    shortcutManager.setIdealizedShortcut(shortcutName);
                else
                    shortcutManager.setVerifyShortcut(shortcutName);
                end
            end
        end
    end
end

% LocalWords:  fpt customshortcutinfo collectrun Nameinfo verifyrun Sgl Scl
% LocalWords:  Settinginfo lbl Fxpt DTOMMO MMO rangecollection codeview
