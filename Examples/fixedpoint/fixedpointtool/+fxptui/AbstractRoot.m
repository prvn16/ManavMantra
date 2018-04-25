classdef AbstractRoot < fxptds.AbstractObject & matlab.mixin.internal.TreeNode & matlab.mixin.Heterogeneous
    
    properties (SetAccess = protected, GetAccess = protected)
        Name;
        Children;
        TopChild;
        DAObject;
    end
    
    methods
        function b = isHierarchical(~)
            b = true;
        end
        
        function obj = getDAObject(this)
            obj = this.DAObject;
        end
        
        function icon = getDisplayIcon(~)
            icon = fullfile('toolbox','shared','dastudio','resources','SimulinkRoot.png');
        end
        
        function label = getDisplayLabel(~)
            label = fxptui.message('titleFPTRoot');
        end
        
        function children = getHierarchicalChildren(this)
            if isempty(this.Children)
                children = [];
            else
                children = [this.Children{:}];
            end
        end
        
        function fireHierarchyChanged(this)
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('HierarchyChangedEvent', this);
        end
        
        function firePropertyChanged(this)
            ed = DAStudio.EventDispatcher;
            ed.broadcastEvent('PropertyChangedEvent', this);
        end
    end
end
