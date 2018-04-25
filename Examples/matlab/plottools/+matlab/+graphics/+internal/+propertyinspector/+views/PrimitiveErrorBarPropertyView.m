classdef PrimitiveErrorBarPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the animatedline property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        AlignVertexCenters
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        CapSize
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
        Parent
        PickableParts
        Selected
        SelectionHighlight
        Tag
        Type
        UIContextMenu
        UserData
        Visible
        XData
        XDataMode
        XDataSource
        XNegativeDelta
        XNegativeDeltaSource
        XPositiveDelta
        XPositiveDeltaSource
        YData
        YDataSource
        YNegativeDelta
        YNegativeDeltaSource
        YPositiveDelta
        YPositiveDeltaSource
    end
    
    methods
        function this = PrimitiveErrorBarPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('Color','LineStyle','LineWidth','CapSize');
            g1.addSubGroup('AlignVertexCenters');
            
            g1.Expanded = true;
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Markers')),'','');
            g2.addProperties('Marker','MarkerSize');
            g2.addSubGroup('MarkerEdgeColor','MarkerFaceColor');
            g2.Expanded = true;
            
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:LineData')),'','');
            g3.addProperties(   'XData',...
                'XDataMode',...
                'XDataSource',...
                'YData',...
                'YDataSource');
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:ErrorbarData')),'','');
            g3.addProperties('YNegativeDelta',...
                'YNegativeDeltaSource',...
                'YPositiveDelta',...
                'YPositiveDeltaSource',...
                'XNegativeDelta',...
                'XNegativeDeltaSource',...
                'XPositiveDelta',...
                'XPositiveDeltaSource');
            
            %...............................................................            
            this.createLegendGroup();
            %...............................................................
            this.createCommonInspectorGroup();
        end
    end
end