classdef FunctionLinePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.function.FunctionLine property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
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
        Function
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Marker
        MarkerEdgeColor
        MarkerFaceColor
        MarkerSize
        MeshDensity
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowPoles
        Tag
        Type
        UIContextMenu
        UserData
        Visible
        XData
        XRange
        XRangeMode
        YData
        ZData
    end
    
    methods
        function this = FunctionLinePropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g3.addProperties('Color','LineStyle','LineWidth');
            g3.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g2.addProperties('Marker','MarkerSize');
            g2.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g2.Expanded = true;
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Function')),'','');
            g1.addProperties('Function','MeshDensity');
            g1.addSubGroup('ShowPoles',...
                'XRange',...
                'XRangeMode');
            g1.Expanded = true;
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g4.addProperties('XData','YData','ZData');
            
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end