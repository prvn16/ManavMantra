classdef PrimitiveStairPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Stair property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color
        LineStyle
        LineWidth
        Marker
        MarkerSize
        MarkerEdgeColor
        MarkerFaceColor
        XData
        XDataMode
        YData
        XDataSource
        YDataSource
        Annotation
        DisplayName
        Selected
        SelectionHighlight
        UIContextMenu
        Clipping
        Visible
        ButtonDownFcn
        CreateFcn
        DeleteFcn
        BeingDeleted
        BusyAction
        HitTest
        PickableParts
        Interruptible
        Children
        HandleVisibility
        Parent
        Tag
        Type
        UserData
    end
    
    methods
        function this = PrimitiveStairPropertyView(obj)
             this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('Color','LineStyle','LineWidth');
            g1.Expanded = 'true';
                       
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g3.addProperties('Marker','MarkerSize');
            g3.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g3.Expanded = true;         
            
            %...............................................................
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g7.addProperties('XData','XDataMode','XDataSource','YData','YDataSource');
                       
            %...............................................................
            
            this.createLegendGroup();
            
             %...............................................................
            this.createCommonInspectorGroup();
            
           
        end
    end
end