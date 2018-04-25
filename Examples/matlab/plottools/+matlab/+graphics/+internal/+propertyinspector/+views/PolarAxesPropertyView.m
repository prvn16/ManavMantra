classdef PolarAxesPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the polar axes's property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        ALim
        ALimMode
        ActivePositionProperty
        AlphaScale
        Alphamap
        BeingDeleted
        Box
        BusyAction
        ButtonDownFcn
        CLim
        CLimMode
        Children
        Clipping
        Color
        ColorOrder
        ColorOrderIndex
        ColorScale
        Colormap
        CreateFcn
        DeleteFcn
        FontAngle
        FontName
        FontSize
        FontSizeMode
        FontSmoothing
        FontUnits
        FontWeight
        GridAlpha
        GridAlphaMode
        GridColor
        GridColorMode
        GridLineStyle
        HandleVisibility
        HitTest
        Interruptible
        Layer
        Legend
        LineStyleOrder
        LineStyleOrderIndex
        LineWidth
        MinorGridAlpha
        MinorGridAlphaMode
        MinorGridColor
        MinorGridColorMode
        MinorGridLineStyle
        NextPlot
        OuterPosition
        Parent
        PickableParts
        Position
        RAxis
        RAxisLocation
        RAxisLocationMode
        RColor
        RColorMode
        RDir
        RGrid
        RLim
        RLimMode
        RMinorGrid
        RMinorTick
        RTick
        RTickLabel@internal.matlab.variableeditor.datatype.TicksLabelType
        RTickLabelMode
        RTickLabelRotation
        RTickMode
        Selected
        SelectionHighlight
        SortMethod
        Tag
        ThetaAxis
        ThetaAxisUnits
        ThetaColor
        ThetaColorMode
        ThetaDir
        ThetaGrid
        ThetaLim
        ThetaLimMode
        ThetaMinorGrid
        ThetaMinorTick
        ThetaTick
        ThetaTickLabel@internal.matlab.variableeditor.datatype.TicksLabelType
        ThetaTickLabelMode
        ThetaTickMode
        ThetaZeroLocation
        TickDir
        TickDirMode
        TickLabelInterpreter
        TickLength
        TightInset
        Title
        TitleFontSizeMultiplier
        TitleFontWeight
        Toolbar
        Type
        UIContextMenu
        Units
        UserData
        Visible
        
    end
    
    methods
        function this = PolarAxesPropertyView(obj)
            this = this@internal.matlab.inspector.InspectorProxyMixin(obj);
                                    
            %...............................................................            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            % Moving FontWeight up as per IDR feedback
            g1.addProperties('FontName','FontSize','FontWeight');
            g1.addSubGroup('FontSizeMode','FontAngle', 'TitleFontSizeMultiplier',...
                'TitleFontWeight','FontUnits','FontSmoothing');
            g1.Expanded = true;            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Ticks')),'','');
            g2.addEditorGroup('RTick','RTickLabel');
            g2.addEditorGroup('ThetaTick','ThetaTickLabel');
            g2.Expanded = true;
            
            
            g2.addSubGroup('RTickMode',...
                'RTickLabelMode',...
                'ThetaTickMode',...
                'RTickLabelRotation',...
                'ThetaTickLabelMode',...
                'RMinorTick',...
                'ThetaMinorTick',...
                'ThetaZeroLocation',...
                'TickDir',...
                'TickDirMode',...
                'TickLabelInterpreter',...
                'TickLength');
                            
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Rulers')),'','');
           g4.addEditorGroup('RLim');
           g4.addEditorGroup('ThetaLim');
           g4.addProperties('RLimMode',...
            'ThetaLimMode',...
            'RAxis',...
            'ThetaAxis',...
            'RAxisLocation',...
            'RAxisLocationMode',...
            'RColor',...
            'ThetaColor',...
            'RColorMode',...
            'ThetaColorMode',...
            'RDir',...
            'ThetaDir',...
            'ThetaAxisUnits');
           
            %...............................................................
            
            g5 = this.createGroup(getString(message('MATLAB:propertyinspector:Grids')),'','');
                                  
            g5.addProperties('RGrid',...
                'ThetaGrid',...
                'Layer',...
                'GridLineStyle',...
                'GridColor',...
                'GridColorMode',...
                'GridAlpha',...
                'GridAlphaMode',...
                'RMinorGrid',...
                'ThetaMinorGrid',...
                'MinorGridLineStyle',...
                'MinorGridColor',...
                'MinorGridColorMode',...
                'MinorGridAlpha',...
                'MinorGridAlphaMode');
            
            
            
            %...............................................................
            
            % Moving this group down as all its properties are read-only
            g31 = this.createGroup(getString(message('MATLAB:propertyinspector:Labels')),'','');
            g31.addProperties('Title','Legend');
            
            
            %...............................................................
            
            g8 = this.createGroup(getString(message('MATLAB:propertyinspector:MultiplePlots')),'','');
            g8.addProperties('ColorOrder','ColorOrderIndex',...
                'LineStyleOrder','LineStyleOrderIndex','NextPlot','SortMethod');
           
            %...............................................................
            
            g6 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandTransparencyMaps')),'','');
            g6.addProperties('Colormap',...
                'ColorScale');
            g6.addEditorGroup('CLim');
            g6.addProperties('CLimMode',...
                'Alphamap',...
                'AlphaScale');
            g6.addEditorGroup('ALim');
            g6.addProperties('ALimMode');
            
            %...............................................................
            
            
            g61 = this.createGroup(getString(message('MATLAB:propertyinspector:BoxStyling')),'','');
            g61.addProperties('Color',...
                'LineWidth',...
                'Box',...
                'Clipping');
            %...............................................................
            
                        
            g9 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');            
            g9.addEditorGroup('OuterPosition');
            g9.addEditorGroup('Position');
            
            g9.addProperties('TightInset',...
            'ActivePositionProperty',...
            'Units');
           
            %...............................................................
            
            g10 = this.createGroup(getString(message('MATLAB:propertyinspector:Interactivity')),'','');
            g10.addProperties('Toolbar',...
                'Visible',...
                'UIContextMenu',...
                'Selected',...
                'SelectionHighlight');

            
            %...............................................................
            
            g11 = this.createGroup(getString(message('MATLAB:propertyinspector:Callbacks')),'','');
            g11.addProperties('ButtonDownFcn','CreateFcn','DeleteFcn');
            
            %...............................................................
            
            g12 = this.createGroup(getString(message('MATLAB:propertyinspector:CallbackExecutionControl')),'','');
            g12.addProperties('Interruptible','BusyAction','PickableParts','HitTest','BeingDeleted');
            
            %...............................................................
            
            g13 = this.createGroup(getString(message('MATLAB:propertyinspector:ParentChild')),'','');
            g13.addProperties('Parent','Children','HandleVisibility');
                        
            
            %...............................................................
            
            g14 = this.createGroup(getString(message('MATLAB:propertyinspector:Identifiers')),'','');
            g14.addProperties('Type','Tag','UserData');
            
            
            
        end
        
        function value = get.RTickLabel(this)
            value = this.OriginalObjects.RTickLabel;
        end
        
        function value = get.ThetaTickLabel(this)
            value = this.OriginalObjects.ThetaTickLabel;
        end
        

        
        function set.RTickLabel(this, value)           
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).RTickLabel,value.getText)
                        this.OriginalObjects(idx).RTickLabel = value.getText;
                    end
                end
            end

        end
        
        function set.ThetaTickLabel(this, value)
            if ~this.InternalPropertySet
                for idx = 1:length(this.OriginalObjects)
                    if ~isequal(this.OriginalObjects(idx).ThetaTickLabel,value.getText)
                        this.OriginalObjects(idx).ThetaTickLabel = value.getText;
                    end
                end
            end

        end
        

    end
end
