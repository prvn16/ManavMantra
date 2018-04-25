classdef MATLABFunctionNode < fxptui.SubsystemNode
    % MATLABFUNCTIONNODE Class definition for the MATLAB function tree node
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties (GetAccess = private, SetAccess=private)
       Children;
       ContainsSpecializations = false;
    end
    
    methods
        function this = MATLABFunctionNode(Identifier)
            this@fxptui.SubsystemNode;
            this.Children = Simulink.sdi.Map(char('a'),?handle);
            if nargin > 0 && isa(Identifier,'fxptds.MATLABFunctionIdentifier')
                this.Identifier = Identifier;
            end
        end
        
        function children = getHierarchicalChildren(this)
            children = [];
            if(isempty(this.Children) || this.Children.getCount == 0)
                return;
            end
            for i = 1:this.Children.getCount
                children = [children this.Children.getDataByIndex(i)]; %#ok<AGROW>
            end
        end
        
        function label = getDisplayLabel(this)
            % For function nodes, the uniqueID can be an array.
            uniqueID = this.Identifier;
            label = uniqueID(1).getDisplayName;
        end
        
        function b = isValid(this)
            uniqueID = this.Identifier;
            b = uniqueID(1).isValid;
        end
        
        function hilite(this)
            % Hilite the system in editor
            uniqueID = this.Identifier;
            for i = 1:numel(uniqueID)
                uniqueID(i).hiliteInEditor;
            end
        end
        
        function openSystem(this)
            % Open the system in editor
            uniqueID = this.Identifier;
            for i = 1:numel(uniqueID)
                uniqueID(i).openInEditor;
            end
        end
        
        function parent = getHighestLevelParent(this)
            uniqueID = this.Identifier;
            parent = uniqueID(1).getHighestLevelParent;
        end
        
        function icon = getDisplayIcon(~)
           icon =  fullfile('toolbox','fixedpoint','fixedpointtool','resources','Functions2.png');
        end
        
        function children = getChildren(this)
            children = [];
            me = fxptui.getexplorer;
            if(~this.isValid) || isempty(me); return; end            
            results = this.getRootResults;
            if(isempty(results)); return; end            
            me.updateResultsVisibility(results);            
            logicVec = false(1,numel(results));
            functionID = this.Identifier;

            for i = 1:numel(results)
                child = results(i);
                if isa(child,'fxptds.MATLABExpressionResult')
                    wasCleared = this.clearMATLABResultIfNotValid(child);
                    if wasCleared
                        continue;
                    end
                end
                isChild = false;
                for m = 1:numel(functionID)
                    isChild = child.isWithinProvidedScope(functionID(m));
                    if isChild
                        break;
                    end
                end
                logicVec(i) = child.isVisible && isChild;
            end
            % Set the flag to true after processing the results - all function
            % nodes for which data has been collected should be added at this
            % point.
            me.WasTreeUpdatedWithMLFunctions = true;
            children = results(logicVec);
            
            if ~this.ContainsSpecializations
                idx = [];
                for i = 1:numel(children)
                    if isa(children(i),'fxptds.MATLABVariableResult')
                        wasCleared = this.clearMATLABResultIfNotValid(children(i));
                        if wasCleared
                            continue;
                        end
                    end
                    if isa(children(i),'fxptds.MATLABVariableResult')
                        childFunctionID = children(i).getUniqueIdentifier.MATLABFunctionIdentifier;
                        for k = 1:numel(functionID)
                            if isequal(childFunctionID.NumberOfInstances, functionID(k).NumberOfInstances)
                                idx = [idx i]; %#ok<AGROW>
                            end
                        end
                    else
                        % This could be a Bus or Signal object result that has
                        % already been filtered to be part of the function
                        idx = [idx i]; %#ok<AGROW>
                    end
                end
                children = children(idx);
            end
        end
        
        function view(this)
            % Required callback for "Contents Of" hyperlink in FPT
            uniqueID = this.getUniqueIdentifier;
            if ~isempty(uniqueID)
                for k = 1:numel(uniqueID)
                    uniqueID(k).hiliteInEditor;
                end
            end
        end
    end
    
    
    methods(Hidden)
        function updateHierarchy(this, functionID)
            if ~this.Children.isKey(functionID.getDisplayName)
                this.addChild(functionID);
            else
                child = this.Children.getDataByKey(functionID.getDisplayName);
                if ~isequal(child.getUniqueIdentifier, functionID)
                    child.updateIdentifier(functionID);
                end
            end
        end
        
        function updateIdentifier(this, ID)
            % Updates the identifiers of the UI node if it has changes
            % between recompiles, but has the same name & hierachical
            % relation.
            this.Identifier = [this.Identifier ID];
        end
        
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
        end
        
        function b = isNodeSupported(~)
            b = false;
        end
        
        function treenode = getSupportedParentTreeNode(this)
            % Return the MATLAB Function Block instance this function is
            % contained within.
            treenode = [];
            me = fxptui.getexplorer;
            if ~isempty(me);
                mlFunctionID = this.getUniqueIdentifier;
                parent = mlFunctionID(1).BlockIdentifier.getObject;
                treenode = me.getFPTRoot.findNodeInCompleteHierarchy(parent);
                me.imme.selectTreeViewNode(treenode);
            end
        end
        
        function setHasSpecializations(this,flag)
            % Set the property to indicate it contains specializations
            if ~islogical(flag)
                [msg, id] = fxptui.message('incorrectInputType','logical',class(flag));
                throw(MException(id, msg));
            end
            this.ContainsSpecializations = flag;
        end
        
        function b = hasSpecializations(this)
            b = this.ContainsSpecializations;
        end
        
        function [selection, list] = getDTO(~)
            selection = fxptui.message('labelDisabledDatatypeOverride');
            list = {selection};
        end
        
        function [selection,  list] = getDTOAppliesTo(~)
            %get the list of valid settings from the underlying object
            list = { ...
                fxptui.message('labelAllNumericTypes'), ...
                fxptui.message('labelFloatingPoint'), ...
                fxptui.message('labelFixedPoint')};
            selection = list{1};
        end
        
        function [selection, list] = getMMO(~)
            %GETMMO   Get the mmo.
            selection = fxptui.message('labelNoControl');
            list = {selection};
        end
    end
    
    methods(Access=protected)
        function actionHandler = createActionHandler(this)
            actionHandler = [];          
        end
        
        function addChild(this, functionID)
            child = fxptui.createNode(functionID);
            this.Children.insert(functionID.getDisplayName, child);
        end
    end
end
