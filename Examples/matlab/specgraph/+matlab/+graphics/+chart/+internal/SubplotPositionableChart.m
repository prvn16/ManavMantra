
%   Copyright 2017 The MathWorks, Inc.

% Interface for charts that support full control by subplot

classdef (AllowedSubclasses = {...
        ?matlab.graphics.chart.internal.SubplotPositionableChartWithAxes,...
        ?matlab.graphics.chart.internal.UndecoratedTitledChart}) ...
        SubplotPositionableChart ...
        < matlab.graphics.chart.Chart
    
    properties(Abstract)
        % These properties are needed to pass object_is_axeslike in subplot
        % c++ code:
        Position_I@matlab.graphics.datatype.Position        
    end
    properties(Abstract, SetAccess = private)
        % These properties are needed to pass object_is_axeslike in subplot
        % c++ code:
        LooseInset@matlab.graphics.datatype.Inset        
    end
    
    properties(Abstract, SetAccess = private)        
        OuterPosition_I@matlab.graphics.datatype.Position %read-only    
        InnerPosition_I@matlab.graphics.datatype.Position %read-only            
        TightInset@matlab.graphics.datatype.Inset %read-only
    end
    
    
    properties(Abstract)
        OuterPosition@matlab.graphics.datatype.Position
        InnerPosition@matlab.graphics.datatype.Position
        Position@matlab.graphics.datatype.Position
        ActivePositionProperty matlab.graphics.chart.datatype.ChartActivePositionType
        Units@matlab.graphics.datatype.Units
    end
    
    properties(Abstract, Hidden) % subplot auto-layout interface
        
        % Extra space needed by chart to leave room for e.g.
        % colorbar/legend and still fit inside the SubplotCellOuterPosition.
        % Stored in same units & format as TightInset
        % (container units)
        ChartDecorationInset@matlab.graphics.datatype.Inset;
                
        % Maximum Inset space (as provided by subplot.m setup) for chart
        % decorations before subplot will start squashing the innerposition
        % of a chart. Stored in same units & format as TightInset
        % (container units)
        % subplot stores maximum tightInsets for an axes in axes'
        % looseInset property. For charts, subplot stores the maximum
        % tightInset in this property instead:      
        MaxInsetForSubplotCell@matlab.graphics.datatype.Inset;
        
        % Position of grid cell allocated for chart by subplot.
        SubplotCellOuterPosition@matlab.graphics.datatype.Position;
        
    end
    
    methods(Hidden)
        function resetSubplotLayoutInfo(~)            
        end
    end
end

