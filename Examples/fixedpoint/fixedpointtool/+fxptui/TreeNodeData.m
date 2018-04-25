classdef TreeNodeData < handle & matlab.mixin.internal.TreeNode
% TREENODEDATA Class that holds information about a particular tree node
    
% Copyright 2016-2017 The MathWorks, Inc.
    
    
    properties (Hidden)
        Object = [];
        Name = '';
        DisplayPath = '';
        Path = '';
        Identifier = '';
        ParentIdentifier = '';
        HasChildren = false;
        Class = '';
        IconClass = '';
        Model = '';
        ItemFullyLoaded = false;
        IsWithinStateflow = false;
        ChartIdentifier = '';
        IsUnderMask = false;
        MaskedParent = [];
        MATLABIDForHighlight = '';
    end
    
    methods
        function set.Object(this, obj)
            this.Object = obj;
        end
        function set.Name(this, nameString)
            this.Name = nameString;
        end
        
        function set.Path(this, blkPath)
            this.Path = blkPath;
        end
        
        function set.Identifier(this, ID)
            this.Identifier = ID;
        end
        
        function set.MATLABIDForHighlight(this, ID)
            this.MATLABIDForHighlight = ID;
        end
        
        function set.ParentIdentifier(this, parentID)
            this.ParentIdentifier = parentID;
        end
        
        function set.HasChildren(this, hasChildren)
            this.HasChildren = hasChildren;
        end
        
        function set.Class(this, objClass)
            this.Class = objClass;
        end
        
        function set.IconClass(this, iconClass)
            this.IconClass = iconClass;
        end
        
        function set.Model(this, modelName)
            this.Model = modelName;
        end
        
        function set.ItemFullyLoaded(this, isLoaded)
            this.ItemFullyLoaded = isLoaded;
        end
        
        function set.IsWithinStateflow(this, isWithinStateflow)
            this.IsWithinStateflow = isWithinStateflow;
        end
        
        function b = isWithinStateflowParent(this)
            if ~isempty(this.Class) && strcmpi(this.Class,'MATLABFunction')
                b = true;
                return;
            end  
            b = false;
            if isa(this.Object, 'Simulink.BlockDiagram')
                return;
            end
            chartParent = this.getParentChart(this.Object);
            if ~isempty(chartParent)
                b = true;
                chId = fxptds.StateflowIdentifier(chartParent);
                this.ChartIdentifier = chId.UniqueKey;                    
            end
        end
        
        function set.IsUnderMask(this, isUnderMask)
            this.IsUnderMask = isUnderMask;
        end
                        
        function dataStruct = convertToStruct(this)
            dataStruct.name = this.Name;
            dataStruct.displayPath = this.DisplayPath;
            if isa(this.Object, 'fxptds.MATLABFunctionIdentifier')
                dataStruct.path = [this.Object.BlockIdentifier.getObject.getFullName ...
                    '/' this.Object.getDisplayName];
                infoObj = this.Object.BlockIdentifier.getObject; 
            else
                dataStruct.path = this.Path;
                infoObj = this.Object; 
            end
            dataStruct.identifier = this.Identifier;
            dataStruct.hasChildren = this.HasChildren;
            dataStruct.class = this.Class;
            dataStruct.iconClass = this.IconClass;
            dataStruct.model = this.Model;
            dataStruct.itemFullyLoaded = this.ItemFullyLoaded;
            dataStruct.isWithinStateflow = this.IsWithinStateflow;
            dataStruct.chartID = this.ChartIdentifier;
            dataStruct.isUnderMaskSubsystem = this.IsUnderMask;
            dataStruct.parent = this.ParentIdentifier;
            if (this.IsUnderMask && ~isequal(infoObj, this.MaskedParent))
                ah = fxptds.SimulinkDataArrayHandler;
                parentID = ah.getUniqueIdentifier(struct('Object',this.MaskedParent));
                dataStruct.parent = parentID.UniqueKey;
            end
            dataStruct.MATLABIDForHighlight = this.MATLABIDForHighlight;

        end
        
        function newCopy = createDeepCopy(this)
           newCopy = fxptui.TreeNodeData;
           newCopy.Object = this.Object;
           newCopy.Name = this.Name;
           newCopy.Path = this.Path;
           newCopy.Identifier = this.Identifier;
           newCopy.ParentIdentifier = this.ParentIdentifier;
           newCopy.HasChildren = this.HasChildren;
           newCopy.Class = this.Class;
           newCopy.IconClass = this.IconClass;
           newCopy.Model = this.Model;
           newCopy.ItemFullyLoaded = this.ItemFullyLoaded;
           newCopy.IsWithinStateflow = this.IsWithinStateflow;
           newCopy.ChartIdentifier = this.ChartIdentifier;
           newCopy.IsUnderMask = this.IsUnderMask;
           newCopy.MaskedParent = this.MaskedParent;
           newCopy.MATLABIDForHighlight = this.MATLABIDForHighlight;
        end                
        
        function isStale = isNodeStale(this)
            isStale = true; 
            if isa(this.Object, 'DAStudio.Object') && ...
                ~strncmp(this.Object.getFullName,'built-in/',9) && ...       
                ~strncmp(this.Object.getFullName,'Delete/',6)
                isStale = false;
            end
        end
    end
    
    methods (Access = private)
        function chartObj = getParentChart(~, sysObj)
            chartObj = [];
            parent = sysObj.getParent;
            while ~isa(parent,'Simulink.BlockDiagram')
                if  fxptds.isStateflowChartObject(parent)
                    chartObj = parent;
                end
                parent = parent.getParent;
            end
        end
    end
            
end
