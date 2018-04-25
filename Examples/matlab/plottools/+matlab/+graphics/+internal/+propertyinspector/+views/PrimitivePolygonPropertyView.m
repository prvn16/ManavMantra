classdef PrimitivePolygonPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Polygon property
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
        CreateFcn
        DeleteFcn
        DisplayName
        EdgeAlpha
        EdgeColor
        FaceAlpha
        FaceColor
        HandleVisibility
        HitTest
        HoleEdgeAlpha
        HoleEdgeColor
        Interruptible
        LineStyle
        LineWidth
        Parent
        PickableParts
        Selected
        SelectionHighlight
        Shape
        Tag
        Type
        UIContextMenu
        UserData
        Visible
    end
    
    methods
        function this = PrimitivePolygonPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
                       
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('FaceColor','EdgeColor','FaceAlpha');
            g1.addSubGroup('EdgeAlpha',...
                'HoleEdgeAlpha',...
                'HoleEdgeColor',...
                'LineStyle',...
                'LineWidth',...
                'AlignVertexCenters');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Shape')),'','');
            g2.addProperties('Shape');
            g2.Expanded = true;
            
            %...............................................................
            
           this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end