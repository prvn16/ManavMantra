classdef PrimitiveRectanglePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.primitive.Rectangle property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AlignVertexCenters
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        Clipping
        CreateFcn
        Curvature
        DeleteFcn
        EdgeColor
        FaceColor
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Parent
        PickableParts
        Position
        Selected
        SelectionHighlight
        Tag
        Type,
        UIContextMenu
        UserData
        Visible
    end
    
    methods
        function this = PrimitiveRectanglePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('FaceColor','EdgeColor','LineStyle','LineWidth',...
                'Curvature','AlignVertexCenters');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g2.addEditorGroup('Position');
            g2.Expanded = 'true';
                        
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end