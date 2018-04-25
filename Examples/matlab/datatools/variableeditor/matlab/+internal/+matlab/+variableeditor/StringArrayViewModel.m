classdef StringArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %STRINGARRAYVIEWMODEL
    %   String Array View Model
    
    % Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Access='public', Constant=true)
        % NO need to escape new lines and tabs, They will show up as unicode symbols
        ESCAPES = {'\n', '\t', '"', '''',}; % Characters to escape
        ESCAPED = {newline, char(9), '"', ''''}; % Escaped versions of characters
    end
    
    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = StringArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        % getRenderedData
        % returns a cell array of strings for the desired range of values
        function [renderedData, renderedDims, shortenedValues, metaData] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            data = this.getData(startRow,endRow,startColumn,endColumn);
            
            escapes = internal.matlab.variableeditor.StringArrayViewModel.ESCAPES;
            escaped = internal.matlab.variableeditor.StringArrayViewModel.ESCAPED;

            vals = cell(size(data,2),1);
            metaData = false(size(data));
            shortenedValues = cell(size(data,2),1);
            for column=1:size(data,2)
                colData = data(:, column);
                
                % Fill in missing strings with '<missing>', like is displayed at the 
                % command line.  (Note that <missing> is not translated, like
                % <undefined> for categorical).
                missingStr = ismissing(colData);
                metaDataCol = false(size(missingStr));
                
                % If any string contain new lines or tabs,we have to parse the strings individually
                if any(cellfun(@(x)any(colData.contains(sprintf(x))), escapes)) || ...
                        any(strlength(colData) > internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH)
                    v = cell(size(data,1),1);
                    sv = cell(size(data,1),1);
                    for row=1:size(data,1)
                        if ~missingStr(row)
                            r = data{row,column};
                            if ~isempty(r)
                                for ei=1:length(escapes)
                                    r = regexprep(r,escapes(ei), escaped(ei));
                                end
                                if strlength(r) > internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH
                                    v{row} = '1x1 string';
                                    sv{row} = '1x1 string';
                                    metaDataCol(row) = true;
                                else
                                    v{row} = r;
                                    sv{row} = r;
                                end
                            elseif size(data,1) > 0
                                v{row}='';
                                sv{row}='';
                            end
                        end
                    end
                    v(missingStr) = {'<missing>'};
                    vals{column} = {v};
                    sv(missingStr) = {'<missing>'};
                    shortenedValues{column} = {sv};
                    missingStr = missingStr | metaDataCol;
                else
                    %
                    % no special processing of the data, just return a cell
                    % array of strings for each column
                    %
                    colData(missingStr) = {'<missing>'};
                    cellData = cellstr(colData);
                    vals{column} = { cellData };
                    shortenedValues{column} = vals{column};
                end
                metaData(:,column) = missingStr;
            end
            renderedData=[vals{:}];
            shortenedValues=[shortenedValues{:}];
            
            if ~isempty(renderedData)
                renderedData=[renderedData{:}];
            end
            
            if ~isempty(shortenedValues)
                shortenedValues=[shortenedValues{:}];
            end
            
            renderedDims = size(renderedData);
        end
    end
end


