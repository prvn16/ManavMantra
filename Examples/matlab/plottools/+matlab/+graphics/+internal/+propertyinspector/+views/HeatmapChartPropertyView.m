classdef HeatmapChartPropertyView < internal.matlab.inspector.InspectorProxyMixin
    % This class has the metadata information on the matlab.graphics.chart.HeatmapChart property
    % groupings as reflected in the property inspector
    % Copyright 2017 The MathWorks, Inc.
    
    properties
        ActivePositionProperty
        CellLabelColor
        CellLabelFormat
        ColorData
        ColorDisplayData
        ColorLimits
        ColorMethod
        ColorScaling
        ColorVariable
        ColorbarVisible
        Colormap
        FontColor
        FontName
        FontSize
        GridVisible
        HandleVisibility
        InnerPosition
        MissingDataColor
        MissingDataLabel
        OuterPosition
        Parent
        Position
        SourceTable
        Title
        Units
        Visible
        XData
        XDisplayData
        XDisplayLabels
        XLabel
        XLimits@internal.matlab.variableeditor.datatype.HeatMapLimits
        XVariable
        YData
        YDisplayData
        YDisplayLabels
        YLabel
        YLimits@internal.matlab.variableeditor.datatype.HeatMapLimits
        YVariable        
    end
    
    methods
        function this = HeatmapChartPropertyView(obj)
            this@internal.matlab.inspector.InspectorProxyMixin(obj);
            
            %...............................................................
            
            g1 = this.createGroup(getString(message('MATLAB:propertyinspector:Labels')),'','');
            g1.addProperties('Title','XLabel',...
                'YLabel',...
                'MissingDataLabel');
            g1.Expanded = true;
            
            %...............................................................
            
            g2 = this.createGroup(getString(message('MATLAB:propertyinspector:ColorandStyling')),'','');
            g2.addProperties('Colormap',...
                'ColorMethod','ColorScaling');                
            
            g22 = g2.addSubGroup('');
            g22.addEditorGroup('ColorLimits');
            g22.addProperties('MissingDataColor',...
                'ColorbarVisible',...
                'GridVisible',...
                'CellLabelColor',...
                'CellLabelFormat','FontColor');
            
            g2.Expanded = true;
            
            %...............................................................
            
            g6 = this.createGroup(getString(message('MATLAB:propertyinspector:Font')),'','');
            g6.addProperties('FontName','FontSize');
            
            %...............................................................
            
            g3 = this.createGroup(getString(message('MATLAB:propertyinspector:TableData')),'','');
            g3.addProperties('SourceTable',...
                'XVariable',...
                'YVariable',...
                'ColorVariable');
            
            %...............................................................
            
            g4 = this.createGroup(getString(message('MATLAB:propertyinspector:MatrixData')),'','');
            g4.addProperties('ColorData',...
                'XData',...
                'YData');
            
            %...............................................................
            g5 = this.createGroup(getString(message('MATLAB:propertyinspector:DisplayedData')),'','');
            g5.addProperties('ColorDisplayData',...
                'XDisplayData',...
                'XDisplayLabels');
            g5.addEditorGroup('XLimits');
            g5.addProperties('YDisplayData',...                
                'YDisplayLabels');            
            g5.addEditorGroup('YLimits');                
            
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
            
            %...............................................................
            
        end
        
        
         function value = get.XLimits(this)
            value = this.OriginalObjects.XLimits;
        end
        
        function value = get.YLimits(this)
            value = this.OriginalObjects.YLimits;
        end
        
        
        function set.XLimits(this, value)
            
            for idx = 1:length(this.OriginalObjects)
                if ~isequal(this.OriginalObjects(idx).XLimits,value.getLimits)
                    this.OriginalObjects(idx).XLimits = value.getLimits;
                end
            end
            
        end
        
        function set.YLimits(this, value)
            
            for idx = 1:length(this.OriginalObjects)
                if ~isequal(this.OriginalObjects(idx).YLimits,value.getLimits)
                    this.OriginalObjects(idx).YLimits = value.getLimits;
                end
            end
            
        end
        
    end
end