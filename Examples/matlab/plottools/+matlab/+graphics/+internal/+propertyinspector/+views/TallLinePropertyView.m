classdef TallLinePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.tall.Line property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AlignVertexCenters
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        Clipping
        Color
        CreateFcn
        DeleteFcn
        DisplayName
        HandleVisibility
        HitTest
        Interruptible
        LineJoin
        LineStyle
        LineWidth
        Marker
        MarkerEdgeColor
        MarkerFaceColor
        MarkerSize
        Parent
        PickableParts
        Selected
        SelectionHighlight
        SlowAxesLimitsChange
        Tag
        Type
        UIContextMenu
        UserData
        Visible
        XData
        YData        
    end
    
    methods
        function this = TallLinePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Color','LineStyle','LineWidth');
            g2.addSubGroup('LineJoin','AlignVertexCenters');
            g2.Expanded = true;
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g1.addProperties('Marker','MarkerSize');
            g1.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g1.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g3.addProperties('XData','YData');
            
            %...............................................................
                        
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();        
        end
    end
end