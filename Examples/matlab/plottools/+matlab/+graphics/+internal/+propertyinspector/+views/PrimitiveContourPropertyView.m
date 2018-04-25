classdef PrimitiveContourPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.Contour property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        Clipping
        ContourMatrix
        CreateFcn
        DeleteFcn
        DisplayName
        Fill
        HandleVisibility
        HitTest
        Interruptible
        LabelSpacing
        LevelList
        LevelListMode
        LevelStep
        LevelStepMode
        LineColor
        LineStyle
        LineWidth
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowText
        Tag
        TextList
        TextListMode
        TextStep
        TextStepMode
        Type
        UIContextMenu
        UserData
        Visible
        XData
        XDataMode
        XDataSource
        YData
        YDataMode
        YDataSource
        ZData
        ZDataSource        
    end
    
    methods
        function this = PrimitiveContourPropertyView(obj)
             this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Levels')),'','');
            g1.addProperties('LevelList','LevelStep');
            g1.addSubGroup('LevelListMode','LevelStepMode');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Fill','LineColor','LineStyle','LineWidth');
            g2.Expanded = true;
                                    
            %...............................................................
            
            g21 = this.createGroup(getString(message('MATLAB:propertyinspector:Labels')),'','');
            g21.addProperties('ShowText',...
                'LabelSpacing',...
                'TextStep',...
                'TextStepMode',...
                'TextList',...
                'TextListMode');
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g3.addProperties('ContourMatrix',...
                'XData',...
                'XDataMode',...
                'XDataSource',...
                'YData',...
                'YDataMode',...
                'YDataSource',...
                'ZData',...
                'ZDataSource');
                 
            %...............................................................
            this.createLegendGroup();
            
            %...............................................................
           this.createCommonInspectorGroup();
        end
    end
end