classdef ObjectArrayViewModel < ...
        internal.matlab.variableeditor.ArrayViewModel
    %OBJECTARRAYVIEWMODEL
    % Object Array View Model
    %
    % Copyright 2015 The MathWorks, Inc.
    
    methods(Access='public')
        % Constructor
        function this = ObjectArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        function [renderedData, renderedDims] = ...
                getRenderedData(this, startRow, endRow, ...
                startColumn, endColumn)
            % Return the renderedData for the object array, in the
            % specified range (startRow/endRow startColumn/endColumn)
            currentData = this.DataModel.Data;
            try
                currentDataCell = arrayfun(@(x) {x}, currentData);
            catch
                s = size(currentData);
                currentDataCell = cell(s);
                for row = 1:s(1)
                    for col = 1:s(2)
                        currentDataCell{row, col} = currentData(row, col);
                    end
                end
            end
            [renderedData, renderedDims, ~] = ...
                this.formatDataBlockForMixedView(startRow, endRow, ...
                startColumn, endColumn, currentDataCell);
        end
    end
end