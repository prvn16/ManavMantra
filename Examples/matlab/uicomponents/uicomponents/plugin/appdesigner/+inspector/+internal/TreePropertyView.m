classdef TreePropertyView < ...
		inspector.internal.AppDesignerPropertyView & ...
		inspector.internal.mixin.FontMixin

    % This class provides the property definition and groupings for Button

    properties(SetObservable = true)

        Multiselect
        Enable
        Editable
        Visible

        HandleVisibility@matlab.graphics.datatype.HandleVisibility

        FontColor@matlab.graphics.datatype.RGBColor
        BackgroundColor@matlab.graphics.datatype.RGBColor
    end

    methods
        function obj = TreePropertyView(componentObject)
           obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
           inspector.internal.CommonPropertyView.createCommonPropertyInspectorGroup(obj); 
        end
    end
end
