classdef ModelReferenceNode < fxptui.SubsystemNode
% MODELREFERENCENODE Class definition for a tree node representing a model reference block.

% Copyright 2013 - 2016 The MathWorks, Inc.
    
    properties(SetAccess = private, GetAccess = private)
        PreviousModelName
    end
    
    methods
        function this = ModelReferenceNode(blkObj)
            if nargin  == 0
                argList = {};
            else
                argList = {blkObj};
            end
            this@fxptui.SubsystemNode(argList{:});
            if nargin > 0
                this.PreviousModelName = this.DAObject.ModelName;
            end
        end
        
        function parent = getHighestLevelParent(this)
            parent = '';
            if this.isValid
                parent = this.Identifier.getHighestLevelParent;
            end
        end
        
        children = getChildren(this);
        node = getSupportedParentTreeNode(this);
        
        function b = isValid(this)
            b = this.Identifier.isValid;
            if b
                % with protected model, this node is no longer valid
                b = strcmpi(this.DAObject.ProtectedModel, 'off');
            end
        end

    end
    
    methods(Hidden)
        function setLogging(this, state, scope, ~)
            if(strcmp('OUTPORT', scope))
                this.setLoggingOnOutports(state);
                return;
            end
            this.DAObject.DefaultDataLogging = state;
        end
        
        function b = isNodeSupported(this)
            b = false;
            if ~this.isValid
                % Not valid either due to identifier or protected model
                return;
            end
            sys = find_system('type','block_diagram','Name',this.DAObject.ModelName);
            if ~isempty(sys)
                b = true;
            end
        end
        
        function b = hasLoggableSignals(this)
            b = false;
            try
                set_param(this.DAObject.getFullName, 'UpdateSigLoggingInfo', 'On');
                propAvaiSigsInstance = this.DAObject.AvailSigsInstanceProps;
            catch closedMdlException %#ok<NASGU>
                % silent return without rethrow
                return;
            end
            
            if ~isempty(propAvaiSigsInstance) && (numel(propAvaiSigsInstance.Signals) > 0)
                b = true;
            end
        end
        
        function val = getParameterValue(this, param)
            [dSys, ~] = getDominantSystem(this, param);
            val = get_param(dSys.getFullName, param);
        end
        
        function [dSys, dParam] = getDominantSystem(this, param)
            dSys = [];
            dParam = '';
            if ~this.isValid
                return;
            end
            dSys = get_param(this.DAObject.ModelName,'Object');
            dParam = dSys.(param);
        end
        
        b = isDominantSystem(this, prop);
    end
    
    methods(Access=private)
        localPropertyChanged(this, ev);
    end
    
    methods(Access=protected)
        function name = getPreviousName(this)
            name = this.PreviousModelName;
        end
        
        function addListeners(this)
            try
                % protected model block cannot load its sub-model
                isProtectedModel = strcmpi(this.DAObject.ProtectedModel, 'on'); 
                
                if ~isProtectedModel
                    load_system(this.DAObject.ModelName);
                end
                % Add listener to react to changes in name of the Model block.
                if numel(this.SLListeners) == 0
                    this.SLListeners = handle.listener(this.DAObject, 'NameChangeEvent', @(s,e)firePropertyChanged(this));
                else
                    this.SLListeners(end+1) = handle.listener(this.DAObject, 'NameChangeEvent', @(s,e)firePropertyChanged(this));
                end
                this.SLListeners(end+1) = handle.listener(this.DAObject, findprop(this.DAObject, 'DefaultDataLogging'),...
                                                          'PropertyPostSet', @(s,e)loggingChange(this, e));
                % Add a listener to react to changes in the ModelName
                % parameter. By default, when a model is loaded for the
                % first time, Simulink triggers Hierarchy changed events and
                % the UI gets updated correctly. But if you change the
                % ModelName to a model that is already in memory, simulink
                % will not fire any events. The client is responsible for
                % triggering the correct events.
                ed = DAStudio.EventDispatcher;
                this.SLListeners(end+1) = handle.listener(ed,'PropertyChangedEvent', @(s,e)localPropertyChanged(this, e));
            catch e %#ok<NASGU>
                return;
            end
        end
        
        function createActionHandler(this)
            this.ActionHandler = fxptui.ModelReferenceNodeActions(this);
        end
    end
    
    methods(Hidden)
        function setParameterValue(this, param, paramVal)
            [dSys, ~] = this.getDominantSystem(param);
            strVal = fxptui.convertEnumToParamValue(param, paramVal);
            set_param(dSys.getFullName, param, strVal);
            this.firePropertyChanged;
        end  
    end
    
    methods(Access=private)
        function loggingChange(this, e)
            if(~strcmpi(e.NewValue, this.DAObject.DefaultDataLogging))
                this.setLogging(e.NewValue);
            end
        end
    end
end

