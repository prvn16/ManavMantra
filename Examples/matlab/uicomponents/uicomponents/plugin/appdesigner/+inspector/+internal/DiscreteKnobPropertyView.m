classdef DiscreteKnobPropertyView < inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for
    % Discrete Knob
    
    properties(SetObservable = true)              

        Value@internal.matlab.variableeditor.datatype.ItemsValue
         
        Items@internal.matlab.variableeditor.datatype.MoreThanTwoStates
        ItemsData@internal.matlab.variableeditor.datatype.ItemsValue
        
        Enable
        Visible                                      
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
                
        FontColor@matlab.graphics.datatype.RGBColor      
    end
    
    methods
        function obj = DiscreteKnobPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);

            titleCatalogId = 'MATLAB:ui:propertygroups:KnobGroup';
            inspector.internal.CommonPropertyView.createOptionsGroup(obj, titleCatalogId);
            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
                        


        end               
    end
end