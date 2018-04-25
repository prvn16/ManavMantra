classdef WizardController < handle
    % WizardController Class that handles communication between the
    % client and the server for look-up table optimization.
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess=private)
        LutFinishSubscribeChannel = '/lookuptable/finish'
        LutTypeSelectSubscribeChannel = '/lookuptable/objective/luttypeselect'
        LutPathUpdateSubscribeChannel = '/lookuptable/setup/lutpathupdate'
        LutDesignTypeSubscribeChannel = '/lookuptable/setup/getdesigntypeinfo'
        OptimizeLutSubscribeChannel = '/lookuptable/create/optimizelut'
        OptimizeParamsChangeSubscribeChannel = '/lookuptable/create/optimizeparamschange'
        OutputTypeChangeSubscribeChannel = '/lookuptable/setup/outputtypechange'
        
        DesignInputInfoChangeSubscribeChannel = '/lookuptable/setup/designinputinfochange';
        
        LutDTUpdateSubscribeChannel = '/lookuptable/setup/designtypeupdate'
        
        LutDesignTypePublishChannel = '/lookuptable/setup/designtypeinfo'
        LutPathPublishChannel = '/lookuptable/setup/lutpathinfo'  
        DesignTypesValidityPublishChannel = '/lookuptable/setup/designtypesvalidity'
        
        DesignInputInfoValidityPublishChannel = '/lookuptable/setup/designinputinfovalidity';
        
        OptimizationParamsValidityPublishChannel = '/lookuptable/create/optimizeparamsvalidity'
        OptimizationParamsPublishChannel = '/lookuptable/create/optimizeparamsinfo'
        OptimizedLutInfoPublishChannel = '/lookuptable/create/optimizedlutinfo'
        CurrentBlockPathPublishChannel = '/lookuptable/setup/gcbpathinfo'
        
        Subscriptions
        MsgServiceInterface        
        DataManager
    end
    
    methods
        function this = WizardController(uniqueID, msgServiceInterface)
            connector.ensureServiceOn;
            this.MsgServiceInterface = msgServiceInterface;                   
            dataManager = FuncApproxUI.Web.DataManager();
            this.setDataManager(dataManager);
            this.addIdToChannels(uniqueID);
            this.initializeSubscriptions;
        end
        
        function delete(this)
            % Remove subscriptions when the object is destroyed
            for i = 1: numel(this.Subscriptions)
                this.MsgServiceInterface.unsubscribe(this.Subscriptions{i});
            end
            this.Subscriptions = [];
        end
    end
    
    methods(Hidden)      
        function onFinishClick(~, ~)
            lutInstance = FuncApproxUI.Wizard.getExistingInstance;
            lutInstance.close();
        end
        
        function selection = getSelectedLutType(this)
            selection = this.DataManager.getSelectedType();
        end
        
        function setSelectedLutType(this, selection)
            this.DataManager.setSelectedType(selection);
        end
        
        function solution = getLutSolution(this)
            solution = this.DataManager.getSolution();
        end
        
        function msgServiceInterface = getMsgServiceInterface(this)
            msgServiceInterface = this.MsgServiceInterface;
        end
        
        function dataManager = getDataManager(this)
            dataManager = this.DataManager;
        end
        
        function setDataManager(this, dataManager)
            this.DataManager = dataManager;
        end
        
        % Methods that publish data to the client
        publishCurrentBlockPath(this, data);        
        
        % Methods that subscribe to the client messages
        handleSelectedType(this, selectedType);
        handleBlockPathUpdate(this, blockPath);
        handleGetDesignTypeInfo(this, allowUpdateDiagram);
        handleOptimizationParametersChange(this, options);
        handleOutputDesignTypeChange(this, designTypeInfo);       
        handleDesignInputInfoChange(this, clientData)          
        handleDesignTypeUpdate(this, designTypeInfo);
        handleOptimize(this, optimizationParams);      
    end
    
    methods(Access=private)
        initializeSubscriptions(this);
        addIdToChannels(this, uniqueID);
        publishBlockInfo(this, data, update);
        publish(this, channel, data);
    end
end

% LocalWords:  lookuptable luttypeselect lutpathupdate getdesigntypeinfo
% LocalWords:  optimizelut designtypeinfo lutpathinfo designtypeupdate
% LocalWords:  optimizeparamsinfo optimizedlutinfo gcbpathinfo
