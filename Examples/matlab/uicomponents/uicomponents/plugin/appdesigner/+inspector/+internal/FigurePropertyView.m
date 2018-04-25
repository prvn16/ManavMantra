
%   Copyright 2016-2017 The MathWorks, Inc.

classdef FigurePropertyView < inspector.internal.AppDesignerPropertyView
    % This class provides the property definition and groupings for
    % UIFigure
    
    properties(SetObservable = true)
        
        Visible@matlab.graphics.datatype.on_off
        
        Name@char vector
        Color@matlab.graphics.datatype.RGBColor
        
        Resize@matlab.graphics.datatype.on_off
        AutoResizeChildren@matlab.graphics.datatype.on_off
        IntegerHandle@matlab.graphics.datatype.on_off
        NumberTitle@matlab.graphics.datatype.on_off
        
        % Due to incompatibility with Colormap editor
        % mark the figure's colormap as using the ColorOrder editor
        %
        % This can be removed when there is a solution to use the
        % ColorOrder as well as any compatibility questions are answered.
        %
        % g1664372
        Colormap@matlab.graphics.datatype.ColorOrder
        NextPlot@matlab.graphics.datatype.NextPlot
    end
    
    methods
        function obj = FigurePropertyView(componentObject)
            obj = obj@inspector.internal.AppDesignerPropertyView(componentObject);
            
            % Window Apperance Group
            inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:WindowAppearanceGroup',...
                'Color'...
                );
            
            % Position Group
            positionGroup =  inspector.internal.CommonPropertyView.createPositionGroup(obj);
            
            % Add Resize & AutoResizeChildren to Position Group
            positionGroup.PropertyList = [positionGroup.PropertyList [{'Resize'} {'AutoResizeChildren'}]];
            
            % Expand Position Group
            positionGroup.Expanded = true;
            
            % Plotting Group
            plottingGroup = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:PlottingGroup',...
                'Colormap'...
                );
            
            % Collapse Plotting Group
            plottingGroup.Expanded = false;
            
            % Callback Execution Control Group
            inspector.internal.CommonPropertyView.createCallbackExecutionControlGroup(obj);
            
            % Identifiers Group
            identifiersGroup = inspector.internal.CommonPropertyView.createPropertyInspectorGroup(obj, 'MATLAB:ui:propertygroups:IdentifiersGroup',...
                'Name', ...
                'NumberTitle',...
                'IntegerHandle'...
                );
            
            % Collapse Identifiers Group
            identifiersGroup.Expanded = false;
        end
    end
end