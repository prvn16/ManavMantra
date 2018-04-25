classdef AxesPropertyView <  internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the axes's property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Toolbar,
        CameraPosition,
        CameraPositionMode,
        CameraTarget,
        CameraTargetMode,
        CameraUpVector,
        CameraUpVectorMode,
        CameraViewAngle,
        CameraViewAngleMode,
        View,
        Projection,
        LabelFontSizeMultiplier,
        AmbientLightColor,
        DataAspectRatio,
        DataAspectRatioMode,
        PlotBoxAspectRatio,
        PlotBoxAspectRatioMode,
        FontName,
        FontAngle,
        FontWeight,
        FontSmoothing,
        TickLabelInterpreter,
        XLim,
        XLimMode,
        YLim,
        YLimMode,
        ZLim,
        ZLimMode,
        XDir,
        YDir,
        ZDir,
        CLim,
        CLimMode,
        ALim,
        ALimMode,
        Layer,
        TickLength,
        GridLineStyle,
        MinorGridLineStyle,
        XAxisLocation,
        XColor,
        XColorMode,
        XTick,
        XTickMode,
        XTickLabelRotation,
        XLabel,
        XScale,
        XTickLabel@internal.matlab.variableeditor.datatype.TicksLabelType,
        XTickLabelMode,
        XMinorTick,
        YAxisLocation,
        YColor,
        YColorMode,
        YTick,
        YTickMode,
        YTickLabelRotation,
        YLabel,
        YScale,
        YTickLabel@internal.matlab.variableeditor.datatype.TicksLabelType,
        YTickLabelMode,
        YMinorTick,
        ZColor,
        ZColorMode,
        ZTick,
        ZTickMode,
        ZTickLabelRotation,
        ZLabel,
        ZScale,
        ZTickLabel@internal.matlab.variableeditor.datatype.TicksLabelType,
        ZTickLabelMode,
        ZMinorTick,
        BoxStyle,
        LineWidth,
        Color,
        ClippingStyle,
        CurrentPoint,
        Title,
        XAxis,
        ZAxis,
        XGrid,
        XMinorGrid,
        YGrid,
        YMinorGrid,
        ZGrid,
        ZMinorGrid,
        YAxis,
        UIContextMenu,
        ButtonDownFcn,
        BusyAction,
        BeingDeleted,
        Interruptible,
        CreateFcn,
        DeleteFcn,
        Type,
        Tag,
        UserData,
        Selected,
        SelectionHighlight,
        HitTest,
        PickableParts,
        Legend,
        Units,
        Position,
        OuterPosition,
        ActivePositionProperty,
        TightInset,
        ColorOrder,
        ColorOrderIndex,
        LineStyleOrder,
        LineStyleOrderIndex,
        FontUnits,
        FontSize,
        FontSizeMode,
        TitleFontWeight,
        TitleFontSizeMultiplier,
        SortMethod,
        TickDir,
        TickDirMode,
        GridColor,
        GridColorMode,
        MinorGridColor,
        MinorGridColorMode,
        GridAlpha,
        GridAlphaMode,
        MinorGridAlpha,
        MinorGridAlphaMode,
        Clipping,
        NextPlot,
        Box,
        Children,
        Parent,
        Visible,
        HandleVisibility,
        ColorScale,
        AlphaScale,
        Alphamap,
        Colormap
    end
    
    % Handles to groups
    properties(Hidden)
        IdentifiersGroup
        LabelsGroup
        PositionGroup
        InteractivityGroup
        ColorAndStylingGroup
    end
    
    methods
        function this = AxesPropertyView(obj)
            this = this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup('MATLAB:propertyinspector:Font','','');
            % Moving FontWeight up as per IDR feedback
            g1.addProperties('FontName','FontWeight','FontSize');
            g1.addSubGroup('FontSizeMode','FontAngle',...
                'LabelFontSizeMultiplier','TitleFontSizeMultiplier',...
                'TitleFontWeight','FontUnits','FontSmoothing');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup('MATLAB:propertyinspector:Ticks','','');
            g2.addEditorGroup('XTick','XTickLabel');
            g2.addEditorGroup('YTick','YTickLabel');
            g2.Expanded = true;
            
            g21 = g2.addSubGroup('');
            g21.addProperties('XTickMode','YTickMode','XTickLabelMode','YTickLabelMode');
            g21.addEditorGroup('ZTick','ZTickLabel');
            g21.addProperties('ZTickMode',...
                'ZTickLabelMode',...
                'TickLabelInterpreter',...
                'XTickLabelRotation',...
                'YTickLabelRotation',...
                'ZTickLabelRotation',...
                'XMinorTick',...
                'YMinorTick',...
                'ZMinorTick',...
                'TickDir',...
                'TickDirMode',...
                'TickLength');
            
            
            %...............................................................
            
            g5 = this.createGroup('MATLAB:propertyinspector:Rulers','','');
            g5.addEditorGroup('XLim');
            g5.addProperties('XLimMode');
            g5.addEditorGroup('YLim');
            g5.addProperties('YLimMode');
            g5.addEditorGroup('ZLim');
            g5.addProperties('ZLimMode');
            g5.addProperties('XAxis','YAxis','ZAxis','XAxisLocation','YAxisLocation',...
                'XColor','XColorMode','YColor','YColorMode','ZColor','ZColorMode',...
                'XDir','YDir','ZDir','XScale','YScale','ZScale');
            
            %...............................................................
            
            g4 = this.createGroup('MATLAB:propertyinspector:Grids','','');
            
            g4.addProperties('XGrid',...
                'YGrid',...
                'ZGrid',...
                'Layer',...
                'GridLineStyle',...
                'GridColor',...
                'GridColorMode',...
                'GridAlpha',...
                'GridAlphaMode',...
                'XMinorGrid',...
                'YMinorGrid',...
                'ZMinorGrid',...
                'MinorGridLineStyle',...
                'MinorGridColor',...
                'MinorGridColorMode',...
                'MinorGridAlpha',...
                'MinorGridAlphaMode');
                                    
            %...............................................................
            
            g5 = this.createGroup('MATLAB:propertyinspector:Labels','','');
            g5.addProperties('Title', 'XLabel', 'YLabel', 'ZLabel', 'Legend');
            
            %...............................................................
            
            g8 = this.createGroup('MATLAB:propertyinspector:MultiplePlots','','');
            
            g8.addProperties('ColorOrder',...
                'ColorOrderIndex',...
                'LineStyleOrder',...
                'LineStyleOrderIndex',...
                'NextPlot',...
                'SortMethod');
            
            %...............................................................
            
            g6 = this.createGroup('MATLAB:propertyinspector:ColorandTransparencyMaps','','');
            g6.addProperties('Colormap',...
                'ColorScale');
            g6.addEditorGroup('CLim');
            g6.addProperties('CLimMode',...
                'Alphamap',...
                'AlphaScale');
            g6.addEditorGroup('ALim');
            g6.addProperties('ALimMode');
            
            g61 = this.createGroup('MATLAB:propertyinspector:BoxStyling','','');
            g61.addProperties('Color',...
                'LineWidth',...
                'Box',...
                'BoxStyle',...
                'Clipping',...
                'ClippingStyle',...
                'AmbientLightColor');
            %...............................................................
            
            g9 = this.createGroup('MATLAB:propertyinspector:Position','','');
            g9.addEditorGroup('OuterPosition');
            g9.addEditorGroup('Position');
            g9.addProperties('TightInset',...
                'ActivePositionProperty','Units');
            g9.addEditorGroup('DataAspectRatio');
            g9.addProperties('DataAspectRatioMode');
            g9.addEditorGroup('PlotBoxAspectRatio');
            g9.addProperties('PlotBoxAspectRatioMode');
            
            %...............................................................
            
            g7 = this.createGroup('MATLAB:propertyinspector:ViewingAngle','','');
            
            g7.addProperties('View','Projection');
            g7.addEditorGroup('CameraPosition');
            g7.addProperties('CameraPositionMode');
            g7.addEditorGroup('CameraTarget');
            g7.addProperties('CameraTargetMode');
            g7.addEditorGroup('CameraUpVector');
            g7.addProperties('CameraUpVectorMode',...
                'CameraViewAngle',...
                'CameraViewAngleMode');
            %...............................................................
            
            g10 = this.createGroup('MATLAB:propertyinspector:Interactivity','','');
            g10.addProperties('Toolbar','Visible','CurrentPoint',...
                'UIContextMenu','Selected','SelectionHighlight');
            
            %...............................................................
            
            g11 = this.createGroup('MATLAB:propertyinspector:Callbacks','','');
            g11.addProperties('ButtonDownFcn','CreateFcn','DeleteFcn');
            
            %...............................................................
            
            g12 = this.createGroup('MATLAB:propertyinspector:CallbackExecutionControl','','');
            g12.addProperties('Interruptible','BusyAction','PickableParts','HitTest','BeingDeleted');
            
            %...............................................................
            
            g13 = this.createGroup('MATLAB:propertyinspector:ParentChild','','');
            g13.addProperties('Parent','Children','HandleVisibility');
            
            %...............................................................
            
            g14 = this.createGroup('MATLAB:propertyinspector:Identifiers','','');
            g14.addProperties('Type','Tag','UserData');
            
            %...............................................................
            % save groups as prooperties so that they can be modified by
            % App Designer.  App Designer needs a handle to the group.
            %
            % Only the groups that need to be either removed or have
            % properties removed from them need to be saved as properties.
            
            this.IdentifiersGroup = g14;
            this.LabelsGroup = g5;
            this.PositionGroup = g9;
            this.InteractivityGroup = g10;
            this.ColorAndStylingGroup = g6;
            
        end
        
        function value = get.XTickLabel(this)
            value = this.OriginalObjects.XTickLabel;
        end
        
        function value = get.YTickLabel(this)
            value = this.OriginalObjects.YTickLabel;
        end
        
        function value = get.ZTickLabel(this)
            value = this.OriginalObjects.ZTickLabel;
        end
        
        function set.XTickLabel(this, value)
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).XTickLabel,value.getText)
                        this.OriginalObjects(idx).XTickLabel = value.getText;
                    end
                end
            end
        end
        
        function set.YTickLabel(this, value)
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).YTickLabel,value.getText)
                        this.OriginalObjects(idx).YTickLabel = value.getText;
                    end
                end
            end
        end
        
        function set.ZTickLabel(this, value)
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).ZTickLabel,value.getText)
                        this.OriginalObjects(idx).ZTickLabel = value.getText;
                    end
                end
            end
        end
        
    end
end