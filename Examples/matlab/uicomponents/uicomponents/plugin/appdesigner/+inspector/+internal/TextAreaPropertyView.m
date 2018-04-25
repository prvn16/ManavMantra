classdef TextAreaPropertyView < ...
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.HorizontalAlignmentMixin & ...
		inspector.internal.mixin.FontMixin
		
    % This class provides the property definition and groupings for
    % Textarea
    
    properties(SetObservable = true)              
        
        Value@matlab.graphics.datatype.NumericOrString
        
        Enable
        Editable
        Visible
     
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
                
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end
    
    methods
        function obj = TextAreaPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);

            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:TextGroup',...
                                                                                                'Value', 'HorizontalAlignment');
           
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj); 
            


        end               
    end
end