classdef DurationArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %DURATIONARRAYVIEWMODEL
    %   Duration Array View Model

    % Copyright 2015 The MathWorks, Inc.

    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = DurationArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        % Returns the format for the duration variable.
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
            % There is a leading whitespace if the format is dd:hh:mm:ss,
            % need to get rid of that to match what is displayed.
            if ~isempty(strfind('dd:hh:mm:ss', data.Format))
                renderedData = cellfun(@strtrim, renderedData, ...
                    'UniformOutput', false);
            end
        end
    end
end
