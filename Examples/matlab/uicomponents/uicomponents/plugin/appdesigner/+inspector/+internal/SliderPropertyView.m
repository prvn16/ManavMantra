classdef SliderPropertyView < ...
        inspector.internal.AppDesignerPropertyView & ...
        inspector.internal.mixin.LinearOrientationMixin & ...
        inspector.internal.mixin.FontMixin
    
    % This class provides the property definition and groupings for Slider
    
    properties(SetObservable = true)
        
        Value@double scalar
        Limits@matlab.graphics.datatype.LimitsWithInfs
        
        MajorTicks@matlab.graphics.datatype.Tick
        MajorTicksMode@matlab.graphics.datatype.AutoManual
        MajorTickLabels@matlab.graphics.datatype.NumericOrString
        MajorTickLabelsMode@matlab.graphics.datatype.AutoManual
        MinorTicks@matlab.graphics.datatype.Tick
        MinorTicksMode@matlab.graphics.datatype.AutoManual
        
        Enable
        Visible
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        FontColor@matlab.graphics.datatype.RGBColor
    end
    
    methods
        function obj = SliderPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            group = obj.createGroup( ...
                'MATLAB:ui:propertygroups:SliderGroup', ...
                'MATLAB:ui:propertygroups:SliderGroup', ...
                '');
            
            group.addProperties('Value')
            group.addEditorGroup('Limits')
            group.addProperties('Orientation')
            
            group.Expanded = true;
            
            inspector.internal.CommonPropertyView.createTicksGroup(obj);
            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            


        end
    end
end