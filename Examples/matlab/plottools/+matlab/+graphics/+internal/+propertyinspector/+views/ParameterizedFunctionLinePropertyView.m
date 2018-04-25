classdef ParameterizedFunctionLinePropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the ParameterizedFunctionLine property
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
        TRange
        TRangeMode
        Tag
        Type
        UIContextMenu
        UserData
        Visible
        XData
        XFunction
        YData
        YFunction
        ZData
        ZFunction        
    end
    
    methods
        function this = ParameterizedFunctionLinePropertyView(obj)
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
            g1.addProperties('XFunction',...
                'YFunction',...
                'ZFunction');
            
            g1.addSubGroup('MeshDensity','TRange',...
                'TRangeMode');
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