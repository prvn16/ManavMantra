classdef PanelPropertyView < ... 
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.TitlePositionMixin & ...
		inspector.internal.mixin.BorderTypeMixin & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for Panel
    
    properties(SetObservable = true)                               
        
        Visible
        
        Title@char vector                		
        
		HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        ForegroundColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor				
    end
    
    methods
        function obj = PanelPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TitleGroup',...
                                                                                    'Title', ...
                                                                                    'TitlePosition' ...                                                                                    
                                                                                    );
            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createPanelPropertyGroups(obj);
            


        end               
    end
end