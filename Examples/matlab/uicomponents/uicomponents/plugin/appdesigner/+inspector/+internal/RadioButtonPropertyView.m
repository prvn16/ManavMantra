classdef RadioButtonPropertyView < inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for Radio
    % button
    
    properties(SetObservable = true)              
        
        Text@matlab.graphics.datatype.NumericOrString
         
        Value
         
        Enable
        Visible
 
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
                
        FontColor@matlab.graphics.datatype.RGBColor        
    end
    
    methods
        function obj = RadioButtonPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:ButtonGroup',...
                                                                                    'Value', 'Text');
                                                                                            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end               
    end
end