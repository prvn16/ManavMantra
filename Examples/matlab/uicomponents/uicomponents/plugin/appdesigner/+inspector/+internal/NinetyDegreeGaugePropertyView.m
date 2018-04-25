classdef NinetyDegreeGaugePropertyView < ...
        inspector.internal.AppDesignerPropertyView & ...
        inspector.internal.mixin.NinetyDegreeOrientationMixin	& ...
        inspector.internal.mixin.ScaleDirectionMixin & ...
        inspector.internal.mixin.FontMixin
    % This class provides the property definition and groupings for 90*
    % Gauge

    properties(SetObservable = true)

        Value@double scalar
        Limits@matlab.graphics.datatype.LimitsWithInfs

        ScaleColorLimits@internal.matlab.variableeditor.datatype.ScaleColorLimits
        ScaleColors@internal.matlab.variableeditor.datatype.ScaleColors

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
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end

    methods
        function obj = NinetyDegreeGaugePropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);

            group = obj.createGroup( ...
                'MATLAB:ui:propertygroups:GaugeGroup', ...
                'MATLAB:ui:propertygroups:GaugeGroup', ...
                '');

            group.addProperties('Value')
            group.addEditorGroup('Limits')
            group.addProperties('Orientation')
            group.addProperties('ScaleDirection')
            group.addEditorGroup('ScaleColors','ScaleColorLimits')

            group.Expanded = true;

            inspector.internal.CommonPropertyView.createTicksGroup(obj);

            %Common properties across all components
            inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj);

        end
        function val = get.ScaleColorLimits(obj)
            val = obj.OriginalObjects.ScaleColorLimits;
        end

        function set.ScaleColorLimits(obj, val)
            obj.OriginalObject.ScaleColorLimits = val;
        end

         function val = get.ScaleColors(obj)
            val = obj.OriginalObjects.ScaleColors;
        end

        function set.ScaleColors(obj, val)
            obj.OriginalObject.ScaleColors = val;
        end
    end
end
