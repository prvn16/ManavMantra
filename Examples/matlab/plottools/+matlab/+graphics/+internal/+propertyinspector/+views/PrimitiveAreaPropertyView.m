classdef PrimitiveAreaPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Area property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        EdgeColor
        FaceColor
        FaceAlpha
        AlignVertexCenters
        EdgeAlpha
        LineStyle
        LineWidth
        Clipping
        BaseLine
        ShowBaseLine
        BaseValue
        Annotation
        DisplayName
        XData
        XDataMode
        YData
        XDataSource
        YDataSource
        Selected
        SelectionHighlight
        UIContextMenu
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
        function this = PrimitiveAreaPropertyView(obj)
             this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g1.addProperties('FaceColor','EdgeColor','FaceAlpha');
            g1.addSubGroup('EdgeAlpha','LineStyle',...
                'LineWidth','AlignVertexCenters');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Baseline')),'','');
            g3.addProperties('BaseValue');
            g3.addSubGroup('ShowBaseLine','BaseLine');
            g3.Expanded = true;            
                        
            %...............................................................
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g7.addProperties('XData','XDataMode','YData','XDataSource','YDataSource');
            
            %............................................................... 
                     
             this.createLegendGroup();
                       
            this.createCommonInspectorGroup();
        end
    end
end