classdef UITableArrayViewModel < internal.matlab.variableeditor.ArrayViewModel ...
        & matlab.ui.internal.controller.uitable.NumericFormatUtil
    
    methods
        % constructor
        function this = UITableArrayViewModel(dataModel)

%   Copyright 2015-2017 The MathWorks, Inc.

            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end        
        
        % use the UITable-specific mathod - getRenderedDataWithFormat
        function [renderedData, renderedDims] = getRenderedData(~,~,~,~,~)
            assert(false);
        end
        
        % Get string-like rendering data from model
        % Format data if needed, given column-level MATLAB FORMAT command.
        function [renderedData, renderedDims] = getRenderedDataWithNumericFormat(this,startRow,endRow,startColumn,endColumn, formats)
            
            data = this.getData(startRow,endRow,startColumn,endColumn);
            vals = cell(size(data,2),1);
            
            if ~isempty(data)
                % get rendering data by column level
                rows = size(data, 1);
                columns = size(data, 2);            
                for column=1:columns
                    colIndex = startColumn+column-1;
                    if colIndex <= length(formats) && this.isValidNumericFormat(formats{colIndex})
                        % Given MATLAB formats, FORMAT numbers in MATLAB.
                        result = this.formatColumnNumbers(data(:,column), formats{colIndex});
                    else
                        % Without specific MATLAB formats, FORMAT numbers with
                        % current MATLAB numeric FORMAT
                        formatedData = this.formatColumnNumbers(data(:,column), '');

                        % convert numeric values to string.
                        result = cell(rows, 1); 
                        for row = 1:rows
                            if iscell(formatedData)
                                value = formatedData{row, 1};
                            else
                                value = formatedData(row, 1);
                            end

                            % convert to strings
                            result{row, 1} = num2str(value);
                        end
                    end

                    vals{column} = {result};
                end
            end
            
            renderedData=[vals{:}];
            if ~isempty(renderedData)
                renderedData=[renderedData{:}];
            end
            renderedDims = size(renderedData);
            
        end        
    end
end
