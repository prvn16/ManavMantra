classdef GeographicBubbleChartPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the  matlab.graphics.chart.GeographicBubbleChart property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        ActivePositionProperty
        Basemap
        BubbleColorList
        BubbleWidthRange
        ColorData
        ColorLegendTitle
        ColorVariable
        FontName
        FontSize
        GridVisible
        HandleVisibility
        InnerPosition
        LatitudeData
        LatitudeLimits
        LatitudeVariable
        LegendVisible
        LongitudeData
        LongitudeLimits
        LongitudeVariable
        MapCenter
        MapLayout
        OuterPosition
        Parent
        Position
        SizeData
        SizeLegendTitle
        SizeLimits
        SizeVariable
        ScalebarVisible
        SourceTable
        Title
        Units
        Visible
        ZoomLevel
    end
    
    methods
        function this = GeographicBubbleChartPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:BubbleLocation')),'','');
            g1.addProperties('LatitudeVariable','LatitudeData',...
                'LongitudeVariable','LongitudeData');
            
            g1.Expanded = true;
            
            
            %...............................................................
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:BubbleSize')),'','');
            g3.addProperties('BubbleWidthRange',...                
                'SizeLimits',...
                'SizeVariable','SizeData');
            g3.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:BubbleColor')),'','');
            g2.addProperties('BubbleColorList','ColorVariable','ColorData');
            
            g2.Expanded = true;
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:Labels')),'','');
            g4.addProperties('Title',...
                'ColorLegendTitle',...
                'SizeLegendTitle',...
                'LegendVisible');            
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g3.addProperties('FontName',...
                'FontSize');
                        
            %...............................................................            
            
            g7 = this.createGroup(getString(message('MATLAB:propertyinspector:Map')),'','');
            g7.addProperties('GridVisible',...
                'Basemap',...
                'MapLayout',...
                'MapCenter',...
                'ZoomLevel',...
                'LatitudeLimits',...
                'LongitudeLimits','ScalebarVisible',...
                'SourceTable');
            
            %...............................................................
            
            g10 = this.createGroup(getString(message('MATLAB:propertyinspector:Position')),'','');
            g10.addEditorGroup('OuterPosition');
            g10.addEditorGroup('InnerPosition');
            g10.addEditorGroup('Position');
            g10.addProperties('ActivePositionProperty','Units',...
                'Visible');
            
            %...............................................................
            
            g9 = this.createGroup(getString(message('MATLAB:propertyinspector:ParentChild')),'','');
            g9.addProperties('Parent','HandleVisibility');            

        end
    end
end