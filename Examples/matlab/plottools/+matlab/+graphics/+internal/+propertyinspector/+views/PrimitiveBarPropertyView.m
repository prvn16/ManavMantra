classdef PrimitiveBarPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Bar property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation,
        BarLayout,
        BarWidth,
        BaseLine,
        BaseValue,
        BeingDeleted,
        BusyAction,
        ButtonDownFcn,
        CData,
        Children,
        Clipping,
        CreateFcn,
        DeleteFcn,
        DisplayName,
        EdgeAlpha,
        EdgeColor,
        FaceAlpha,
        FaceColor,
        HandleVisibility,
        HitTest,
        Horizontal,
        Interruptible,
        LineStyle,
        LineWidth,
        Parent,
        PickableParts,
        Selected,
        SelectionHighlight,
        ShowBaseLine,
        Tag,
        Type,
        UIContextMenu,
        UserData,
        Visible,
        XData,
        XDataMode,
        XDataSource,
        YData,
        YDataSource
    end
    
    methods
        function this = PrimitiveBarPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('FaceColor','EdgeColor','FaceAlpha');            
            g1.addSubGroup('EdgeAlpha','LineStyle','LineWidth');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:BarLayout')),'','');
            g2.addProperties('BarLayout','BarWidth','Horizontal');
            g2.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Baseline')),'','');
            g3.addProperties('BaseValue');
            g3.addSubGroup('ShowBaseLine','BaseLine');            
            g3.Expanded = 'true';
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g4.addProperties('CData','XData','XDataMode',...
                'YData','XDataSource','YDataSource');
          
            %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end