classdef CalendarDurationArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %CALENDARDURATIONARRAYVIEWMODEL
    %   Calendar Duration Array View Model

    % Copyright 2015 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = CalendarDurationArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        % Returns the format for the calendar duration variable.
        function format = getFormat(this)
            format = this.DataModel.getData().Format;
        end
        
        % isEditable
        function editable = isEditable(varargin)
            editable = false;
        end
        
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getData(startRow,endRow,startColumn,endColumn);
            renderedData = cellstr(data);
            renderedDims = size(renderedData);
        end
    end
end
