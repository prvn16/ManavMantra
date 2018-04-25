classdef TreeNodePropertyView < inspector.internal.AppDesignerNoPositionPropertyView & ...
        inspector.internal.mixin.IconMixin
    
    % This class provides the property definition and groupings for Button
    
    properties(SetObservable = true)
        Text@char vector        
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
    end
    
    methods
        function obj = TreeNodePropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerNoPositionPropertyView(componentObject);
            %Common properties across all components
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TreeNodeGroup',...
                'Text', ...                
                'Icon'...
                );
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj, false);
        end        
    end
end
