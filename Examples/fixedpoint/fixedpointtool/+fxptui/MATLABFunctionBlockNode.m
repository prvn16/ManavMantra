classdef MATLABFunctionBlockNode < fxptui.StateflowChartNode
% MATLABFUNCTIONBLOCKNODE Class definition for the MATLAB function block tree node

% Copyright 2013-2016 The MathWorks, Inc.

    properties (GetAccess = private, SetAccess=private)
       FunctionListener; 
       Children;
       ContainsSpecializations = false;
       % Key to distinguish the UI dummy node for ML specializations and
       % actual function node with no specialization.  
       PureUIKeyAppendStr = '_dummy'; 
    end
    
    methods
        function this = MATLABFunctionBlockNode(blkObj)
            if nargin  == 0
                argList = {};
            else
                argList = {blkObj};
            end
            this@fxptui.StateflowChartNode(argList{:});
            this.Children = Simulink.sdi.Map(char('a'),?handle);
        end
        
        function children = getHierarchicalChildren(this)
            children = [];
            if ~this.isValid
                return;
            end
            if(isempty(this.Children) || this.Children.getCount == 0)
                return;
            end
            for i = 1:this.Children.getCount
                children = [children this.Children.getDataByIndex(i)]; %#ok<AGROW>
            end
        end        
      end
    
    methods(Hidden)
        function b = isNodeSupported(~)
        % Support actions
            b = true;
        end
    end
    
    methods(Access=protected)
        function addListeners(this)
            addListeners@fxptui.StateflowChartNode(this);
            ed = fxptui.FPTEventDispatcher.getInstance;
            this.FunctionListener = event.listener(ed, 'FunctionAddedEvent',@(s,e)updateMATLABBlockHierarchy(this, e));
        end
        
        function populate(this)
            if ~this.isUnderMaskedSubsystem
                % Reset the WasTreeUpdatedWithMLFunctions anytime a MLFB is
                % added to the hierarchy
                me = fxptui.getexplorer;
                if ~isempty(me)
                    me.WasTreeUpdatedWithMLFunctions = false;
                end
            end
        end
        
        function child = addChild(this, functionIdentifier, pureUINode)
            child = fxptui.createNode(functionIdentifier);
            if nargin < 3
                pureUINode = false;
            end
            if pureUINode
                key = sprintf('%s%s',functionIdentifier.getDisplayName,this.PureUIKeyAppendStr);
            else
                key = functionIdentifier.getDisplayName;
            end
            this.Children.insert(key, child);
        end
    end  
    
    methods(Access=private)
        function updateMATLABBlockHierarchy(this, eventData)
            % There are a few different scenarios when the MATLAB Function
            % block hierarchy gets updated:
            % Case A: 
            %  1) The first compilation produces specializations due to size/data
            %  type/complexity
            %  2) A subsequent compilation that produces no specializations
            %  for example: using DTO = double
            % Case B:
            %  1) The first compilation produces no specializations
            %  (either due to DTO or code does not use varying
            %  size/type/complexity)
            %  2) The subsequent compilation produces specializations
            % A dummy UI node for a given function is only created if the
            % function has specializations. In either of these cases, the
            % function hierarchy needs to be adjusted such that all
            % functions that get specialized are below the UI node for that
            % function (dummy node just for display). We might need to
            % alter the existing hierarchy depending on which scenario is
            % exercised. 
            
            % Updates the tree hierarchy of the MATLAB Function block node
            me = fxptui.getexplorer;
            if ~isempty(me)
                me.WasTreeUpdatedWithMLFunctions = true;
            end
                
            mlBlock = get_param(eventData.BlockName,'Object');
            if ~isequal(mlBlock, this.DAObject)
                return;
            end
            functionID = eventData.Data;
            if functionID.NumberOfInstances > 1
                % Create a dummy node that will parent the specialized
                % and unspecialized(if any) functions.
                % Create an identifier to represent this node.
                newFunctionIDWithoutInstances = fxptds.MATLABFunctionIdentifier.copyAndSetInstanceCountToOne(functionID);
                keyForUINode = sprintf('%s%s',newFunctionIDWithoutInstances.getDisplayName,this.PureUIKeyAppendStr);
                if ~this.Children.isKey(keyForUINode)
                    pureUINode = true;
                    child = this.addChild(newFunctionIDWithoutInstances, pureUINode);
                else
                    child = this.Children.getDataByKey(keyForUINode);
                end
                child.updateHierarchy(functionID);
                child.setHasSpecializations(true);
                % Check to see if an unspecialized function was in the
                % hierarchy before. If it was, then we need to move
                % that unspecialized node from the MATLAB Function
                % Block hierarchy to under the dummy UI node. (Case 2)
                if this.Children.isKey(newFunctionIDWithoutInstances.getDisplayName)
                    unSpecializedChild = this.Children.getDataByKey(newFunctionIDWithoutInstances.getDisplayName);
                    % Add it to the dummy child node
                    child.updateHierarchy(unSpecializedChild.getUniqueIdentifier);
                    % Delete it from the previous parent.
                    this.Children.deleteDataByKey(newFunctionIDWithoutInstances.getDisplayName)
                end            
            else
                % Check to see if there is a dummy node with the same
                % function name. If there is, we need to add this
                % function as a child of that dummy node. If not found,
                % add a new child to represent this function. (Case 1)
                keyForUINode = sprintf('%s%s',functionID.getDisplayName,this.PureUIKeyAppendStr);
                if this.Children.isKey(keyForUINode)
                    child = this.Children.getDataByKey(keyForUINode);
                    child.updateHierarchy(functionID);  
                elseif ~this.Children.isKey(functionID.getDisplayName)
                    this.addChild(functionID);
                end
            end
        end
    end
    
    methods(Hidden)
        function unpopulate(this)
            for idx = 1:this.Children.getCount
                fxpblk = this.Children.getDataByIndex(idx);
                if ~isempty(fxpblk) && isvalid(fxpblk)
                    disconnect(fxpblk);
                    unpopulate(fxpblk);
                    delete(fxpblk);
                end
            end
            this.Children.Clear;
            this.PropertyBag.clear;
            deleteListeners(this);
        end
        
        function deleteListeners(this)
            for lIdx = 1:numel(this.SLListeners)
                delete(this.SLListeners(lIdx));
            end
            delete(this.FunctionListener);
            this.FunctionListener = [];
            this.SLListeners = [];
        end
    end
end
