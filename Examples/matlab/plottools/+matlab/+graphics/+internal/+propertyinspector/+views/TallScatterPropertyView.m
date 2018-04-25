classdef TallScatterPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.tall.Scatter property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        CData
        Children
        Clipping
        CreateFcn
        DeleteFcn
        DisplayName
        HandleVisibility
        HitTest
        Interruptible
        LineWidth
        Marker
        MarkerEdgeAlpha
        MarkerEdgeColor
        MarkerFaceAlpha
        MarkerFaceColor
        Parent
        PickableParts
        Selected
        SelectionHighlight
        SizeData
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
        function this = TallScatterPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g1.addProperties('Marker','LineWidth','MarkerEdgeColor');
            g1.addSubGroup('MarkerFaceColor','MarkerEdgeAlpha','MarkerFaceAlpha');
            g1.Expanded = true;
            
            %...............................................................
                       
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g3.addProperties('CData',...
                'SizeData',...
                'XData',...
                'YData');
            
            %...............................................................
            
           this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();   
        end
    end
end