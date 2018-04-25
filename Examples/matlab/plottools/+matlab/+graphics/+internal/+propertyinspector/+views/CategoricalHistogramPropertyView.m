classdef CategoricalHistogramPropertyView < matlab.graphics.internal.propertyinspector.views.CommonPropertyViews
    % This class has the metadata information on the matlab.graphics.chart.primitive.categorical.Histogram property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        Annotation
        BarWidth
        BeingDeleted
        BinCounts
        BinCountsMode
        BusyAction
        ButtonDownFcn
        Categories
        Children
        CreateFcn
        Data
        DeleteFcn
        DisplayName
        DisplayOrder
        DisplayStyle
        EdgeAlpha
        EdgeColor
        FaceAlpha
        FaceColor
        HandleVisibility
        HitTest
        Interruptible
        LineStyle
        LineWidth
        Normalization
        NumDisplayBins
        Orientation
        OthersValue
        Parent
        PickableParts
        Selected
        SelectionHighlight
        ShowOthers
        Tag
        Type
        UIContextMenu
        UserData
        Values
        Visible
    end
    
    methods
        function this = CategoricalHistogramPropertyView(obj)
            this@matlab.graphics.internal.propertyinspector.views.CommonPropertyViews(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Categories')),'','');
            g1.addProperties('Categories',...
                'DisplayOrder','NumDisplayBins','ShowOthers');
            
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g2.addProperties('Data','Values','OthersValue');
            g2.addSubGroup('Normalization','BinCounts',...
                'BinCountsMode');
            g2.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('DisplayStyle',...
                'Orientation',...
                'BarWidth');
            
            g2.addSubGroup('FaceColor','EdgeColor','FaceAlpha',... 
                'EdgeAlpha',...
                'LineStyle',...
                'LineWidth');
            g2.Expanded = true;
            
               %...............................................................
            
            this.createLegendGroup();
            
            %...............................................................
            
            this.createCommonInspectorGroup();
        end
    end
end