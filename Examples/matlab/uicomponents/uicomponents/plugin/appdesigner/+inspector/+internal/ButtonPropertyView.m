classdef ButtonPropertyView < ...
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.HorizontalAlignmentMixin & ...
		inspector.internal.mixin.VerticalAlignmentMixin & ...
		inspector.internal.mixin.IconMixin & ...        
        inspector.internal.mixin.IconAlignmentMixin & ...        
		inspector.internal.mixin.FontMixin
	
    % This class provides the property definition and groupings for Button
    
    properties(SetObservable = true)              
        
        Text@matlab.graphics.datatype.NumericOrString                  		
         
        Enable
        Visible        
		
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
                
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor  
    end
    
    methods
        function obj = ButtonPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:ButtonGroup',...
                                                                                    'Text', 'HorizontalAlignment', 'VerticalAlignment', 'Icon', 'IconAlignment');
                                                                                                       
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);            
        end                                
    end
end