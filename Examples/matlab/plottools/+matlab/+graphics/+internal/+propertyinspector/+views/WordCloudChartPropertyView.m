classdef WordCloudChartPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the  matlab.graphics.chart.WorldCloud property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        ActivePositionProperty
        Box
        Color
        FontName
        HandleVisibility
        HighlightColor
        InnerPosition
        LayoutNum
        MaxDisplayWords
        OuterPosition
        Parent
        Position
        Shape
        SizeData
        SizePower
        SizeVariable
        SourceTable
        Title
        TitleFontName
        Units
        Visible
        WordData
        WordVariable        
    end
    
    methods
        function this = WordCloudChartPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Title')),'','');
            g3.addProperties('Title',...
                'TitleFontName');
            
            g3.Expanded = true;
            %...............................................................
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Color',...
                'HighlightColor',...
                'FontName');
            g2.addSubGroup('MaxDisplayWords','Box',...
                'Shape',...
                'LayoutNum',...
                'SizePower');
            
            g2.Expanded = true;
                        
            %...............................................................
            g21 = this.createGroup(getString(message('MATLAB:propertyinspector:Data')),'','');
            g21.addProperties('WordData','SizeData','WordVariable');
            g21.addSubGroup('SizeVariable','SourceTable');
            
            g21.Expanded = true;
            
            %...............................................................
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g7.addEditorGroup('OuterPosition');
            g7.addEditorGroup('InnerPosition');
            g7.addEditorGroup('Position');
            g7.addProperties('ActivePositionProperty','Units',...
                'Visible');
                                                    
            %...............................................................
            
            g9 = this.createGroup(getString(message('MATLAB:propertyinspector:ParentChild')),'','');
            g9.addProperties('Parent','HandleVisibility');     
            
        end
    end
end