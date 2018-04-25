classdef TextScatterPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the textanalytics.chart.TextScatter property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BackgroundColor
        BeingDeleted
        BusyAction
        ButtonDownFcn
        Children
        ColorData
        Colors
        CreateFcn
        DeleteFcn
        DisplayName
        EdgeColor
        FontAngle
        FontName
        FontSize
        FontSmoothing
        FontWeight
        HandleVisibility
        HitTest
        Interruptible
        Margin
        MarkerColor
        MarkerSize
        MaxTextLength
        Parent
        PickableParts
        Selected
        SelectionHighlight
        Tag
        TextData
        TextDensityPercentage
        Type
        UIContextMenu
        UserData
        Visible
        XData
        XDataSource
        YData
        YDataSource
        ZData
        ZDataSource        
    end
    
    methods
        function this = TextScatterPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Text')),'','');
            g1.addProperties('TextData','TextDensityPercentage','MaxTextLength');
            g1.addSubGroup('ColorData','Colors');
            g1.Expanded = 'true';
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g2.addProperties('FontName',...
                'FontSize',...
                'FontWeight');
            g2.addSubGroup('FontAngle',...
                'FontSmoothing');
            g2.Expanded = true;
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:TextBox')),'','');
            g3.addProperties('Margin','BackgroundColor','EdgeColor');
            g3.addSubGroup('MarkerColor',...
                'MarkerSize');
            g3.Expanded = true;
            
            %...............................................................  
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g4.addProperties(...
                'XData','XDataSource',...
                'YData','YDataSource',...
                'ZData','ZDataSource');                   

            %...............................................................
             this.createLegendGroup();                                   
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end