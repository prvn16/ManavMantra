classdef StartupController < handle
    % STARTUPCONTROLLER Controls communication between MATLAB & the FPT startup
    % JS application
    
    % Copyright 2014-2017 The MathWorks, Inc.
    
    
    properties (SetAccess = private, GetAccess = private)
        SUDSubscribeChannel = '/fpt/model/sud'
        SUDPublishChannel = '/fpt/sud_selection'
        SUDTreeRefreshChanel = '/fpt/sud_refresh'
        EnableCodeViewPublishChannel = '/fpt/enableCodeView';
        CurrentSubscriptions
        TreeController
        SystemForConversion
        AppURL
        SUD
    end
    
    events
        SUDChangedEvent
    end
    
    
    methods
        function this = StartupController(uniqueID, modelHierarchy, model)
            % Ensure the connector is on before subscribing
            connector.ensureServiceOn;
            uuid = sprintf('_%s_%s','startup',uniqueID);
            this.TreeController = fxptui.Web.TreeController(uuid, false, modelHierarchy);
            this.SUDSubscribeChannel = sprintf('%s/%s',this.SUDSubscribeChannel,uniqueID);
            this.SUDPublishChannel = sprintf('%s/%s',this.SUDPublishChannel,uniqueID);
            this.EnableCodeViewPublishChannel = sprintf('%s/%s',this.EnableCodeViewPublishChannel, uniqueID);
            this.SUDTreeRefreshChanel = sprintf('%s/%s',this.SUDTreeRefreshChanel,uniqueID);
            this.initializeSubscriptions;
            
            if nargin > 2
                sys = find_system('type','block_diagram','Name',model);
                if isempty(sys)
                    [msg, identifier] = fxptui.message('modelNotLoaded',model);
                    e = MException(identifier, msg);
                    throwAsCaller(e);
                else
                    this.setModel(model);
                end
            end
        end
        
        function updateSelectedSystem(this, systemPath)
            this.SystemForConversion = systemPath;
        end
        
        function delete(this)
            % Remove subscriptions when the object is destroyed
            for i = 1: numel(this.CurrentSubscriptions)
                message.unsubscribe(this.CurrentSubscriptions{i});
            end
            this.CurrentSubscriptions = [];
            delete(this.TreeController);
            this.TreeController = [];
        end
    end
    
    methods(Hidden)
        function publishHierarchy(this, clientData)
            this.TreeController.sendModelHierarchy(clientData);
        end
        
        function publishModelData(this, clientData)
            this.TreeController.sendModelHierarchy(clientData);
        end
        
        function publishEnableCodeView(this)
            % Publish channel to launch the Code View if there are function blocks
            % present in the SUD.
            msgObj = struct('enableCodeView', false);
            if fxptui.isMATLABFunctionBlockConversionEnabled() && coder.internal.mlfb.gui.fxptToolIsCodeViewEnabled()
                msgObj.enableCodeView = true;
            end
            message.publish(this.EnableCodeViewPublishChannel, msgObj);
        end
        
        function publishData(this, clientData)
            data = this.getSUDInfoForClient;
            message.publish(this.SUDPublishChannel, data);
            this.publishEnableCodeView;
            this.publishModelData(clientData);
        end
        
        function setModel(this, modelName)
            this.TreeController.setModel(modelName);
        end
        
        function model = getModel(this)
            model = this.TreeController.getModel;
        end
        
        function sys = getSystemForConversion(this)
            sys = this.SystemForConversion;
        end
        
        % Return true if the controller needs to be updated based on its
        % current uniqueID and the new one from the client
        function b = needsUpdate(this, clientData)
            tempChannel = sprintf('%s/%s','/fpt/model/sud',clientData.oldUniqueID);
            b = strcmp(tempChannel, this.SUDSubscribeChannel);
        end
        
        function updateChannels(this, clientData)
            % Remove subscriptions when the object is destroyed
            for i = 1: numel(this.CurrentSubscriptions)
                message.unsubscribe(this.CurrentSubscriptions{i});
            end
            this.SUDSubscribeChannel = strrep(this.SUDSubscribeChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.SUDPublishChannel = strrep(this.SUDPublishChannel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.SUDTreeRefreshChanel = strrep(this.SUDTreeRefreshChanel, clientData.oldUniqueID, clientData.startupTreeUniqueID);
            this.initializeSubscriptions;
            this.TreeController.updateChannels(clientData);
        end
    end
    
    methods(Access = 'private')
        function data = getSUDInfoForClient(this)
            sysname = this.SystemForConversion;
            dh = fxptds.SimulinkDataArrayHandler;
            sysObj = get_param(this.SystemForConversion, 'Object');
            sudData = fxptui.TreeNodeData;
            sudData.Object = sysObj;
            sudData.Name = fxptui.removeLineBreaksFromName(sysname);
            sudData.Path = fxptui.removeLineBreaksFromName(sysObj.getFullName);
            sudData.Identifier = dh.getUniqueIdentifier(struct('Object',sysObj)).UniqueKey;
            sudData.Class = fxptui.getClassFromObject(sysObj);
            sudData.IconClass = fxptui.ModelHierarchy.getIconClass(sysObj);
            sudData.IsWithinStateflow = sudData.isWithinStateflowParent;
            sudData.ItemFullyLoaded = false;
            data = sudData.convertToStruct;
        end
        
        function setSUD(this, data)
            % The identifier sent from the client has the unique key format
            % which is the hexID::element. We need to the block handle by
            % excluding the element info.
            clientInfo = data.SUD;
            try
                sysName = fxptds.getBlockPathFromIdentifier(data.SUD.identifier, data.SUD.class);
                this.SystemForConversion = sysName;
                data.SUD = sysName;
                notify(this, 'SUDChangedEvent',fxptui.UIEventData(data));
                clientInfo.name = sysName;
            catch
                % User chosen SUD could not be resolved. Resend the
                % previous SUD selection.
                sud = this.SystemForConversion;
                if ~strcmp(clientInfo.path, sud)
                    clientInfo = getSUDInfoForClient(this);
                end
                fxptui.showdialog('invalidSUD');
            end
            message.publish(this.SUDPublishChannel, clientInfo);
            this.publishEnableCodeView;
        end
        
        function update(this, clientData)
            if this.needsUpdate(clientData)
                this.updateChannels(clientData);
                this.publishHierarchy(clientData);
            end
        end
        
        function initializeSubscriptions(this)
            this.CurrentSubscriptions{1} = message.subscribe(this.SUDSubscribeChannel, @(data)this.setSUD(data));
            this.CurrentSubscriptions{2} = message.subscribe(this.SUDTreeRefreshChanel, @(clientData)this.publishHierarchy(clientData));
            this.CurrentSubscriptions{3} = message.subscribe('/fxp/SUD/refreshID',@(data)this.update(data));
        end
        
    end
end
