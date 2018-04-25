classdef PrimitiveLinePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Line property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Color
        LineStyle
        LineWidth
        AlignVertexCenters
        LineJoin
        Clipping
        Marker
        MarkerSize
        MarkerEdgeColor
        MarkerFaceColor
        MarkerIndices
        XData
        YData
        ZData
        RData
        ThetaData
        Annotation
        DisplayName
        Selected
        SelectionHighlight
        UIContextMenu
        Visible
        CreateFcn
        DeleteFcn
        ButtonDownFcn
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
        function this = PrimitiveLinePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Color','LineStyle','LineWidth');
            g2.addSubGroup('LineJoin','AlignVertexCenters');
            g2.Expanded = true;
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g1.addProperties('Marker','MarkerIndices','MarkerSize');
            g1.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g1.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g3.addProperties('XData','YData','ZData','RData', ...
                'ThetaData');
            
            %...............................................................
            
            this.createLegendGroup();            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end