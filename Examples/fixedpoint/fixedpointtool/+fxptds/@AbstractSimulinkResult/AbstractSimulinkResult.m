classdef AbstractSimulinkResult < fxptds.AbstractResult
% ABSTRACTSIMULINKRESULT Abstract class definition for results from "Simulink"
    
% Copyright 2012-2017 The MathWorks, Inc.
    
    properties(SetAccess = protected)
        Outport
        DataObject
        ActualSourceIDs
        SLListeners
        Figures
        ReplaceOutDataType
        ReplacementOutDTName
        CompiledInputDT
        CompiledOutputDT
        CompiledInputComplex
        CompiledOutputComplex
    end
    
    properties(SetAccess = protected, AbortSet)
        LogSignal = false;
    end
    
    properties(SetAccess=protected)
        ParameterSaturation
        HasSupportingMinMax = false
    end
    
    methods
        function this = AbstractSimulinkResult(data)
        % Class should be able to instantiate with no input arguments
            if nargin  == 0
                argList = {};
            else
                argList = {data};
            end
            this@fxptds.AbstractResult(argList{:});
            if nargin > 0
                this.Outport = this.getPortForResult;
                addSimulinkListeners(this);
                this.Figures = java.util.HashMap;
            end
        end
        
        function calculateRangesForResult(this, proposalSettings)
            extremumSet = this.getExtremumSet(proposalSettings);
            concatenatedExtremumSet = SimulinkFixedPoint.safeConcat(this.InitialValueMin,...
            this.ModelRequiredMin, ...
            this.InitialValueMax, ...
            this.ModelRequiredMax, extremumSet);
            this.setLocalExtremum(concatenatedExtremumSet);
        end    
        
        function set.LogSignal(this, value)
        % Set the LogSignal property
           this.LogSignal = value;
        end
        
        function b = hasMinMaxInformation(this)
            b = hasMinMaxInformation@fxptds.AbstractResult(this) || this.HasSupportingMinMax;
                
        end
        
        [b, numOutputs] = hasOutput(this);
        
        function [b, numInputs] = hasInput(this)
            %  Returns true if the block has inputs and optionally returns the number of input ports.
            b = false;
            numInputs = [];
            blkObj = this.getUniqueIdentifier.getObject;
            portHandles = blkObj.PortHandles;
            inportHandles = portHandles.Inport;
            if ~isempty(inportHandles)
                b = true;
                numInputs = numel(inportHandles);
            end
        end
        function subsystemId = getSubsystemId(this)
        % GETSUBSYSTEMID function queries for uniqueIdentifier's parent
        % object and uses it to create a subsystem identifier
            blkObj = this.UniqueIdentifier.getObject.getParent;
            subsystemIdentifier = '';
            if isprop(blkObj, 'Handle')
                subsystemIdentifier = fxptds.Utils.getSubsystemIdUsingBlkObj(blkObj, num2hex(blkObj.Handle));
            elseif isprop(blkObj, 'Id')
                subsystemIdentifier = fxptds.Utils.getSubsystemIdUsingBlkObj(blkObj, num2hex(blkObj.Id));
            end
            subsystemId = {subsystemIdentifier.UniqueKey};
            
        end

    end
       
    methods(Hidden)
        function val = getPropertyValue(this, prop)
            % Convenience method to get the property value of the result
            val = this.(prop);
        end
        
        function actSrcIDs = getActualSourceIDs(this)
            actSrcIDs = this.ActualSourceIDs;
        end
                
        function b = isReadonlyProperty(this, propName)
        % Used by ME to check if a property should be editable in the UI.
            b = true;
            if(strcmp('LogSignal', propName))
                model = this.getHighestLevelParent;
                if isempty(model); return; end
                if this.hasOutput && strcmp(this.getRunName, get_param(model,'FPTRunName'))
                    b = false;
                else
                    b = true;
                end
                return;
            end
            b = isReadonlyProperty@fxptds.AbstractResult(this, propName);
        end
        
        function setPropValue(this, propName, propVal)
        % Function to set the property values from a UI interaction.
            if strcmpi(propName,'LogSignal')
                if str2double(propVal)
                    propVal = true;
                else
                    propVal = false;
                end
                this.LogSignal = propVal;
            else
                setPropValue@fxptds.AbstractResult(this, propName, propVal);
            end
        end
        
        updateResultData(this, data);
        clearProposalData(this);
        val = getPropValue(this, propName);  
        port = getPortForResult(this); 
        plotHistogramInFigure(this);
    end
    
    methods(Hidden)
        % The below methods have been added to improve performance of
        % updating the result with information during the autoscaling
        % stage.
        function setInitialValueData(this, minVal, maxVal)
            % Set the initial value min/max on the result
            this.InitialValueMin = SimulinkFixedPoint.extractMin(minVal);
            this.InitialValueMax = SimulinkFixedPoint.extractMax(maxVal);
        end
        
        function setModelRequiredData(this, minVal, maxVal)
            % Set the model required min/max value on the result
            this.ModelRequiredMin = SimulinkFixedPoint.extractMin(minVal);
            this.ModelRequiredMax = SimulinkFixedPoint.extractMax(maxVal);
        end
        
        function setActualSourceIDs(this, srcIds)
            % Set the Simulink source block on the result
            if isempty(this.ActualSourceIDs)
                this.ActualSourceIDs = srcIds;
            else
                this.ActualSourceIDs(end+(1:numel(srcIds))) = srcIds;
            end
        end
        
        function ovMode = getOverflowMode(this)
            ovMode = 'wrap';
            obj = this.UniqueIdentifier.getObject;
            if isa(obj,'Simulink.Block')
                try
                    % Some blocks may not have the
                    % SaturateOnIntegerOverflow parameter
                    ovMode = get_param(obj.getFullName,'SaturateOnIntegerOverflow');
                    if strcmp(ovMode, 'on')
                        ovMode = 'saturate';
                    else
                        ovMode = 'wrap';
                    end
                catch
                end
            end
        end
    end
    
    methods(Static)
        function obj = loadobj(this)
            obj = loadobj@fxptds.AbstractResult(this);
            if obj.UniqueIdentifier.isValid
                obj.Outport = obj.getPortForResult;
                obj.addSimulinkListeners;   

                % restore ActionHandler
                data = struct('Object',obj.getUniqueIdentifier.getObject);
                dataHandler = fxptds.SimulinkDataArrayHandler; 
                % need dataObj in the field of SLDataObject to call createActionHandlerForResult
                % but SimulinkDataArrayHandler.createDataObj is private
                % SimulinkDataArrayHandler.createActionHandler to create
                % dataObj may not be a good way
                [~, data.SLDataObject] = dataHandler.createActionHandler(data);
                obj.ActionHandler = obj.createActionHandlerForResult(data);
            end
        end 
    end
    methods
        function obj = saveobj(this)
            % return the savable copy of this
            obj = saveobj@fxptds.AbstractResult(this);
            
            obj.Outport = [];
            obj.SLListeners = [];
            
            % obj.ActualSourceID is handled by saveobj of ID classes
            
            % the following properites are cleaned and not to be restored
            % since they are not used before regeneration, e.g. by
            % autoscaler  
            obj.CompiledInputDT = []; % repopulated by FPA check 1.2 (update diagram) and used only in the following checks
            obj.CompiledOutputComplex = []; % repopulated by FPA check 1.2 (update diagram) and used only in the following checks
            obj.CompiledOutputDT = []; % repopulated by FPA check 1.2 (update diagram) and used only in the following checks
            obj.ParameterSaturation = [];
            obj.ReplacementOutDTName = [];
            obj.ReplaceOutDataType = [];
            obj.DataObject = [];
            obj.Figures = [];
            obj.DataObject = []; % do not copy and restore DataObject
        end 
    end
    
    methods(Access=protected)                
        function uniqueID = createUniqueIdentifierForData(this, data) 
            if isfield(data, 'SLDataObject')
                this.DataObject = data.SLDataObject;
            end
            if isempty(this.DataObject) || ~isa(this.DataObject, 'fxptds.AbstractSLData')
                dataHandler = fxptds.SimulinkDataArrayHandler;
                [uniqueID, this.DataObject] = dataHandler.getUniqueIdentifier(data);
            else
                uniqueID = this.DataObject.getUniqueIdentifier;
            end
        end
        
        function actionHandler = createActionHandlerForResult(this, data)
            if isfield(data, 'SLDataObject')
                this.DataObject = data.SLDataObject;
            end
            if isempty(this.DataObject) || ~isa(this.DataObject, 'fxptds.AbstractSLData')
                dataHandler = fxptds.SimulinkDataArrayHandler;
                [actionHandler, this.DataObject] = dataHandler.createActionHandler(data);
            else
                actionHandler = this.DataObject.createActionHandler(this);
            end
        end
           
    end
        
    methods (Abstract)
        icon = getDisplayIcon(this);
    end
    
    methods(Access=private)
        setLogSignal(this, value);
        
        function addSimulinkListeners(this)
            owner = [];
            if ~isempty(this.UniqueIdentifier)
                owner = this.UniqueIdentifier.getObject;
            end
            if isempty(owner) || ~isa(owner, 'Simulink.Block'); return; end
            
            % remove block deletion event but keep NameChangeEvent
            if isempty(this.SLListeners)
                this.SLListeners = handle.listener(owner, 'NameChangeEvent',@(s,e)firePropertyChange(this));
            else
                this.SLListeners(end+1) = handle.listener(owner, 'NameChangeEvent',@(s,e)firePropertyChange(this));
            end
        end

    end
end

% LocalWords:  proposedtinvalid
