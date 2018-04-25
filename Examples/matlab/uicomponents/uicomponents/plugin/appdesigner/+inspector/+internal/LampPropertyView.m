classdef LampPropertyView < ...		
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.PositionMixin
    % This class provides the property definition and groupings for Lamp
    
    properties(SetObservable = true)              
        
        Color@matlab.graphics.datatype.RGBColor
        
        Enable
        Visible                 			
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
	end
	
	
    
    methods
        function obj = LampPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);      
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:ColorGroup', ...
                                                    'Color'...
                                                    );

            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end               
    end
end