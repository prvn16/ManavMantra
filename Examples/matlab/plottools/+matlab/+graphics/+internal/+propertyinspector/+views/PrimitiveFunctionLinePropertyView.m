classdef PrimitiveFunctionLinePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.FunctionLine  property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        Color
        CreateFcn
        DeleteFcn
        DisplayName
        HandleVisibility
        HitTest
        Interruptible
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
        Tag
        Type
        UIContextMenu
        UserData
        Value
        Visible
        XData
        YData
        ZData        
    end
    
    methods
        function this = PrimitiveFunctionLinePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('Color','LineStyle','LineWidth');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g2.addProperties('Marker','MarkerSize');
            g2.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g2.Expanded = true;
            
            %...............................................................
            g0 = this.createGroup(getString(message('MATLAB:propertyinspector:Value')),'','');
            g0.addProperties('Value');
            g0.Expanded = true;                                    
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g3.addProperties('XData','YData','ZData');
               
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end