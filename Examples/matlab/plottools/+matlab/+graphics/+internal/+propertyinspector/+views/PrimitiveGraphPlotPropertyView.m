classdef PrimitiveGraphPlotPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews    
    % This class has the metadata information on the matlab.graphics.chart.primitive.GraphPlot property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        ArrowSize
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        CreateFcn
        DeleteFcn
        DisplayName
        EdgeAlpha
        EdgeCData
        EdgeColor
        EdgeLabel
        EdgeLabelMode
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Marker
        MarkerSize
        NodeCData
        NodeColor
        NodeLabel
        NodeLabelMode
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowArrows
        Tag
        Type
        UIContextMenu
        UserData
        Visible
        XData
        YData
        ZData        
    end
    
    methods
        function this = PrimitiveGraphPlotPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Nodes')),'','');
            g1.addProperties('NodeColor','Marker','MarkerSize');
            
            g1.addSubGroup('NodeCData',...
                'NodeLabel',...
                'NodeLabelMode');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Edges')),'','');
            g2.addProperties('EdgeColor','LineStyle','LineWidth');
            g2.addSubGroup('EdgeAlpha','ArrowSize','EdgeCData',...
                'EdgeLabel',...
                'EdgeLabelMode',...
                'ShowArrows');

            g2.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g3.addProperties('XData','YData','ZData');            
            
            %...............................................................
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end