classdef SpinnerPropertyView < ...
        inspector.internal.AppDesignerPropertyView & ...
        inspector.internal.mixin.HorizontalAlignmentMixin & ...
        inspector.internal.mixin.ValueDisplayFormatMixin & ...
        inspector.internal.mixin.FontMixin    
    % This class provides the property definition and groupings for Spinner
    
    properties(SetObservable = true)
        
        Value@double scalar
        Limits@matlab.graphics.datatype.LimitsWithInfs
        LowerLimitInclusive
        UpperLimitInclusive
        RoundFractionalValues
        
        Step           
        
        Enable
        Editable
        Visible
        
        HandleVisibility@matlab.graphics.datatype.HandleVisibility
        
        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end
    
    methods
        function obj = SpinnerPropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            
            group = obj.createGroup( ...
                'MATLAB:ui:propertygroups:ValueGroup', ...
                'MATLAB:ui:propertygroups:ValueGroup', ...
                '');
            
            group.addProperties('Value');
            group.addEditorGroup('Limits');
            group.addProperties('Step');
            group.addProperties('RoundFractionalValues');
            group.addEditorGroup('ValueDisplayFormat');
            group.addProperties('HorizontalAlignment');
            group.addSubGroup('LowerLimitInclusive', 'UpperLimitInclusive');
            
            group.Expanded = true;
            
            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);
            
        end
    end
end