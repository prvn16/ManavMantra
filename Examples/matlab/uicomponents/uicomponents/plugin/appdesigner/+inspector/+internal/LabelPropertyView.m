classdef LabelPropertyView < ...
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.HorizontalAlignmentMixin & ...
		inspector.internal.mixin.VerticalAlignmentMixin & ...
		inspector.internal.mixin.FontMixin
	% This class provides the property definition and groupings for Label
	
	properties(SetObservable = true)
		
        Text@matlab.graphics.datatype.NumericOrString                       
        
        Enable
        Visible            
     
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBAColor
    end    
    
    methods
        function obj = LabelPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TextGroup',...
                                                                                    'Text', 'HorizontalAlignment', 'VerticalAlignment');
                         
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            
            %  Start expanded

		end               			
		
	end		
end