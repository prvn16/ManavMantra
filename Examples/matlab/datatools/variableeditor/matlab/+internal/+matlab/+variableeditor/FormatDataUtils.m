classdef FormatDataUtils < handle
    %FORMATDATAUTILS
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Constant)
        MAX_DISPLAY_ELEMENTS = 11;
        MAX_DISPLAY_DIMENSIONS = 2;
        CHAR_WIDTH = 7;		% Width of each character in the string
        HEADER_BUFFER = 10;	% The amount of room(leading and trailing space) the header should have after resizing to fit the header name
        MAX_CATEGORICALS = 25001;
        MAX_TEXT_DISPLAY_LENGTH = 100000;
        TIMES_SYMBOL = matlab.internal.display.getDimensionSpecifier;
    end
    
    methods(Access='public')      
        
        % if the cell contents consist of more than a pre-defined number of
        % display elements, then the contents are rendered as a summary
        % value
        % Ex : c{1} = [1;2;3;4;5;6;7;8;9;1;2;3] is displayed as 1x12 double
        % in the variable editor
        function isSummary = isSummaryValue(this, data)
            isSummary = ~(numel(data) < this.MAX_DISPLAY_ELEMENTS && ndims(data) <= this.MAX_DISPLAY_DIMENSIONS);
        end
        
        function jsonData = getJSONforCell(~, data, longData, isMeta, editorValue, row, col)
            
            if isempty(data)
                data = '[]';
            end
            if isempty(longData)
                longData = '[]';
            end
            
            % case when value is not metadata
            % eg: c{1} = 10
            if ~isMeta
                if isempty(editorValue)
                    jsonData = ['{' '"value"' ':' '"' data '"' ',' '"editValue"' ':' '"' longData '"' ','... 
                        '"isMetaData"' ':' '"0"' ',' '"row"' ':' '"' row '"' ',' '"col"' ':' '"' col '"' '}'];
                else
                    % in case of char arrays, Ex: c = {'abc';'def'}, on double
                    % clicking the data should be opened in a new VE tab 
                    jsonData = ['{' '"value"' ':' '"' data '"' ',' '"editValue"' ':' '"' longData '"' ','... 
                        '"isMetaData"' ':' '"0"' ',' '"editor"' ':' '"variableeditor/views/editors/OpenvarEditor"'...
                        ',' '"editorValue"' ':' '"' editorValue '"' ',' '"row"' ':' '"' row '"' ',' '"col"' ':' '"' col '"' '}'];
                end
            % case when value is metadata
            % c{1} = 5x5 double
            else
                jsonData = ['{' '"value"' ':' '"' data '"' ',' '"editValue"' ':' '"' longData '"' ','... 
                        '"isMetaData"' ':' '"1"' ',' '"editor"' ':' '"variableeditor/views/editors/OpenvarEditor"'... 
                        ',' '"editorValue"' ':' '"' editorValue '"' ',' '"row"' ':' '"' row '"' ',' '"col"' ':' '"' col '"' '}'];
            end
        end
		
		% the behaviour of vector structure arrays in the variable editor
        % is similar to cell arrays.
        % if the value of a field in a vectot structure consists of 
        function structDataAsCell = convertStructToCell(~, structData)
            % case1 : mx1 structure array
            % case2 : 1xm structure array
            % case3 : mxn structure array
            structDataAsCell = structData;
            % if it is a not a non empty struct and an mxn struct 
            if ~(size(structData,1) == 0) && ~(size(structData,2) == 0) && ...
                    ~(size(structData,1) > 1 && size(structData,2) > 1)
                if size(structData,1) == 1 && size(structData,2) > 1        %case2
                    structData = structData';
                end
                structDataAsCell = (struct2cell(structData))';
            end
        end
        
        function [isUniform, className] = uniformTypeData(~, data)
            % ignore all the empty data entries
            nonEmptyData = data(~cellfun('isempty',data));

            % parse the data to see if all entries are of the same data type
            if ~isempty(nonEmptyData)
                isUniform = all(cellfun('isclass',nonEmptyData,class(nonEmptyData{1,1})));
                if isUniform && isnumeric(nonEmptyData{1,1})
                    isUniform = isUniform && all(cellfun('length',data) <= 1);
                end
                
                if isUniform
                    className = class(nonEmptyData{1,1});
                else
                    className = 'mixed';
                end
            else
                isUniform = true;
                className = class(data{1,1});
            end                                    
        end
        
        function szz = getSizeString(this, value)
            s = this.getVariableSize(value);
            if isa(value, 'tall')
                % Special handling for tall variables, because the size of
                % a tall variable may not be known.
                tallInfo = matlab.bigdata.internal.util.getArrayInfo(value);
                szz = internal.matlab.variableeditor.FormatDataUtils.getTallInfoSize(tallInfo);
            elseif length(s) == 1 && s == 0
                szz = '0';
            elseif isnumeric(s) 
                if isa(value, 'matlab.mixin.internal.CustomSizeString')
                    % This class creates a custom size string for whos, so we
                    % need to use the same value.
                    w = whos('value');
                    s = w.size;
                end
                if length(s) <=3                               
                    szz = regexprep(num2str(s), ' +', this.TIMES_SYMBOL);
                else            
                    szz = sprintf('%d-D', length(s));       
                end
            elseif isjava(s)
                szz = ['1' this.TIMES_SYMBOL '1'];
            else
                szz = char(s);
            end
        end
        
		% computes the width of the header given the header label
        function nameWidth = computeHeaderWidthUsingLabels(this, name)            
            nameWidth = size(name, 2) * this.CHAR_WIDTH + this.HEADER_BUFFER;
        end

        
        % Gets the formatted class name string
        function clazz = getClassString(~, value, useShortClassName, useParens)
            if nargin < 3 || isempty(useShortClassName)
                useShortClassName = true;
            end

            if nargin < 4 || isempty(useParens)
                useParens = false;
            end

            clazz = class(value);
            if ~isnumeric(value)
                if useShortClassName
                    n = regexp(clazz,'^(?<clazz>[^\.]*)$|^.*\.(?<clazz>.*)?','names');
                    if ~isempty(n.clazz)
                        clazz = n.clazz;
                    end
                end
            else
                %TODO: no easy to way to check for class 'global'
                if ~isreal(value)
                    if useParens
                        clazz = [clazz ' (complex)'];
                    else
                        clazz = ['complex ' clazz];
                    end
                end
                if issparse(value)
                    if useParens
                        if ~isreal(value)
                            clazz = [ class(value) ' (sparse complex)'];
                        else
                            clazz = [clazz ' (sparse)'];
                        end
                    else
                        clazz = ['sparse ' clazz];
                    end
                end
            end
        end
        
        % Convenience function to call formatDataBlockForMixedView with a single
        % value.
        function [renderedData, renderedDims, metaData] = formatSingleDataForMixedView(this, currentData)
            [renderedData, renderedDims, metaData] = ...
                this.formatDataBlockForMixedView(1, 1, 1, 1, {currentData});
        end

        % function is used for formatting data for rendering in the
        % variable editor.
        % This formatted data can be used by types like structure arrays
        % and cell arrays where each cell entry can be a different data type
        function [renderedData, renderedDims, metaData] = formatDataBlockForMixedView(this,startRow,endRow,startColumn,endColumn,currentData)
            sRow = max(1,startRow);
            eRow = min(size(currentData,1),endRow);
            sCol = max(startColumn,1);
            eCol = min(endColumn,size(currentData,2));
            metaData = false(eRow-sRow+1, eCol-sCol+1);
            renderedData = cell(eRow-sRow+1, eCol-sCol+1);
            
            % Loop through the cells
            if ~isempty(currentData) 
                colCount = 1;
                for column=sCol:eCol
                    rowCount = 1;
                    for row=sRow:eRow
                        currentVal = currentData{row,column};
                        
                        % empty data
                        % 0x0 struct data should be rendered as '0x0 struct'
                        if ~isa(currentVal, 'tall') && this.isVarEmpty(currentVal) && ...
                                isnumeric(currentVal)
                            renderedData{rowCount,colCount} = '[ ]';
                            metaData(rowCount,colCount) = false;
                            
                        elseif isa(currentVal, 'distributed') || isa(currentVal, 'codistributed') || isa(currentVal, 'gpuArray')
                            % Check for these types before others,
                            % because they can return true to some of the
                            % other checks (like isnumeric)
                            renderedData{rowCount,colCount} = strtrim([num2str(size(currentVal,1)) this.TIMES_SYMBOL num2str(size(currentVal,2)) ...
                                ' ' char(this.getClassString(currentVal)) ' ' classUnderlying(currentVal)]);
                            metaData(rowCount,colCount) = true;

                        elseif isa(currentVal, 'timeseries')
                            renderedData{rowCount,colCount} = strtrim([num2str(size(currentVal,1)) this.TIMES_SYMBOL num2str(size(currentVal,2)) ...
                                ' ' class(get(currentVal, 'Data')) ' ' char(this.getClassString(currentVal))]);
                            metaData(rowCount,colCount) = true;

                        % char data
                        elseif ischar(currentVal) && ...
                                size(currentVal, 1) <= 1 && ...
                                size(currentVal, 2) < internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH
                            cellVal = this.getCharCellVal(currentVal);                            
                            metaData(rowCount,colCount) = false;
                            renderedData{rowCount,colCount} = ['''' cellVal ''''];
                        % String data    
                        elseif this.checkIsString(currentVal) && ...
                                isscalar(currentVal) && ...
                                (ismissing(currentVal) || strlength(currentVal) < internal.matlab.variableeditor.FormatDataUtils.MAX_TEXT_DISPLAY_LENGTH)
                            cellVal = currentData{row,column};
                            if(ismissing(cellVal))
                                cellVal = strtrim(evalc('disp(cellVal)'));  
                            else
                                cellVal = char(cellVal);
                            end                                                                                   
                            if ~strcmp(currentData{row,column},'""')
                                cellVal = regexprep(cellVal,'(^"|"$)','');                                
                            end
                            metaData(rowCount,colCount) = false;
                            % If the scalar string is <missing>, set
                            % metaData to true
                            if ismissing(currentVal)
                                metaData(rowCount,colCount) = true;
                                renderedData{rowCount,colCount} = cellVal;
                            else
                                renderedData{rowCount,colCount} = ['"' cellVal '"'];
                            end                           
                        elseif islogical(currentVal)
                            if isscalar(currentVal)
                                cellVal = strtrim(evalc('disp(currentVal)'));
                            else
                                sz = size(currentVal);
                                className = class(currentVal);  
                                cellVal = [num2str(sz(1)) this.TIMES_SYMBOL num2str(sz(2)) ' ' className];
                                metaData(rowCount,colCount) = true;
                            end
                            renderedData{rowCount,colCount} = cellVal;		
                            
                        % numeric data
                        elseif isnumeric(currentVal) && ~issparse(currentVal)
                            if this.isSummaryValue(currentVal)
                                val = currentVal;
                                cellVal = [this.getSizeString(val) ' ' this.getClassString(val)];
                                metaData(rowCount,colCount) = true;
                            else
                                metaData(rowCount,colCount) = false;
                                % case where c{1} = 1;2;3;4;5
                                if ~isscalar(currentVal)
                                    currData = currentVal;
                                    cellVal = '';
                                    vals = cell(1,size(currentVal,2));
                                    for cellCol=1:size(currentVal,2)
                                        if ~isreal(currData)
                                            r=evalc('disp(complex(currData(:,cellCol)))');
                                        else
                                            r=evalc('disp(currData(:,cellCol))');
                                        end
                                        vals{cellCol} = this.parseNumericColumn(r, currData(:,cellCol));
                                    end
                                    
                                    for cellRow=1:size(currentVal,1)
                                        if cellRow>1
                                            cellVal = [cellVal ';']; %#ok<*AGROW>
                                        end
                                        for cellCol=1:size(currentVal,2)
                                            if cellCol>1
                                                cellVal = [cellVal ','];
                                            end
                                            
                                            colData = vals{cellCol};
                                            cellVal = [cellVal colData{1}{cellRow}];
                                        end
                                    end
									
                                    cellVal = ['[' cellVal ']'];
                                else
                                    cellVal = strtrim(evalc('disp(currentVal)'));
                                    cellVal = strtrim(regexprep(cellVal, '(^[)|(^{)|(}$)|(]$)',''));
                                end

                            end
                            renderedData{rowCount,colCount} = cellVal;						 
                        % if it is a value class (not a handle class) whose summary value has to
                        % be displayed in the variable editor
                        elseif isValueSummaryClass(char(class(currentVal))) && ~isa(currentVal,'handle')
                            % table, dataset, cell, struct, categorical, object, nominal, ordinal data    
                            renderedData{rowCount,colCount} = strtrim([num2str(size(currentVal,1)) this.TIMES_SYMBOL num2str(size(currentVal,2)) ...
                                ' ' char(this.getClassString(currentVal))]);
                            metaData(rowCount,colCount) = true;
                            
                        elseif isa(currentVal, 'tall')
                            % Special handling for tall variables.
                            renderedData{rowCount, colCount} = this.getTallCellVal(currentVal);
                            metaData(rowCount, colCount) = true;
                            
                        else
                            s = this.getVariableSize(currentVal);
                            
                            if ~this.isVarEmpty(s) && isnumeric(s) && ~isscalar(s)
                                if isa(currentVal, 'matlab.mixin.internal.CustomSizeString')
                                    % This class creates a custom size
                                    % string for whos, so we need to use
                                    % the same value.
                                    w = whos('currentVal');
                                    s = w.size;
                                end
                                s = [num2str(s(1)) this.TIMES_SYMBOL num2str(s(2))];
                            else
                                s = ['1' this.TIMES_SYMBOL '1'];
                            end
                            cellVal = [s ' ' this.getClassString(currentVal)];
                            % We used to trim cellVal like this: 
                            % strtrim(regexprep(cellVal, '(^[)|(^{)|(}$)|(]$)',''));
                            % But it cuts off 'Jlabel[' in workspace, so
                            % it's not removed.
                            renderedData{rowCount,colCount} = cellVal;
                            metaData(rowCount,colCount) = true;
                        end
                        rowCount = rowCount + 1;
                    end
                    colCount = colCount + 1;
                end
            end
            renderedDims = size(renderedData);  
        end    
        
        function cellVal = getCharCellVal(~, currentVal) %#ok<INUSD>
            cellVal = string(evalc('disp(currentVal)'));
            
            % ignore line feeds ,carriage returns, tab
            % escape '"' and '\' since the data will be
            % sent as json string to client
            cellVal = replace(replace(cellVal, {newline, sprintf('\r')}, ''), char(9), '\t');
            cellVal = char(cellVal);
        end        
        
        function cellVal = getTallCellVal(this, currentVal)
            % Special handling for tall variables, because the size of a
            % tall variable may not be known, and there may be additional
            % information available about the tall's underlying class.
            tallInfo = matlab.bigdata.internal.util.getArrayInfo(currentVal);
            if isempty(tallInfo.Size) || isnan(tallInfo.Ndims)
                szz = '';
            else
                szz = internal.matlab.variableeditor.FormatDataUtils.getTallInfoSize(tallInfo);
            end
            
            cellVal = strtrim([szz ' ' this.getClassString(currentVal)]);
            if ~isempty(tallInfo.Class)
                cellVal = [cellVal ' ' tallInfo.Class];
            end
            if ~tallInfo.Gathered
                cellVal = [cellVal ' (' ...
                    getString(message('MATLAB:codetools:variableeditor:Unevaluated')) ')'];
            end
        end
        
        function vals = parseNumericColumn(~, r, currentData)
            if isempty(regexp(r,'\s*[0-9]+\.[0-9e+-]*?\s\*', 'once'))
                textformat = ['%s', '%*[\n]'];
                vals = textscan(r,textformat,'Delimiter','');
            else
                % We need to parse row by row
                colVal = cell(size(currentData,1),1);
                for row=1:size(currentData,1)
                    colVal{row} = strtrim(evalc('disp(currentData(row))'));
                end
                vals = {colVal};
            end
        end    
    end
    
    methods(Static)
        function loadPerformance(es)
            if strcmp(es.eventType,'VELoadPerformance')
                % milliseconds to seconds
                time = es.loadTime/1000;
                rowCount = es.rows;
                columnCount = es.columns;
                [str,maxsize,endian] = computer;
                type = '';
                fileID = '';
                
                if strcmp(es.dataType,'variableeditor.views.NumericArrayView')
                    type = 'Numerics';
                    fileID = fopen('//mathworks/inside/files/dev/ltc/datatools_team/MOPerformance/LoadTimePerformanceNumerics.txt','wt');
                elseif strcmp(es.dataType,'variableeditor.views.TableArrayView')
                    type = 'Tables';
                    fileID = fopen('//mathworks/inside/files/dev/ltc/datatools_team/MOPerformance/LoadTimePerformanceTables.txt','wt');
                elseif strcmp(es.dataType,'variableeditor.views.CellArrayView')
                    type = 'Cell Arrays';
                    fileID = fopen('//mathworks/inside/files/dev/ltc/datatools_team/MOPerformance/LoadTimePerformanceCellArrays.txt','wt');
                end
                
                TIMES_SYMBOL = internal.matlab.variableeditor.FormatDataUtils.TIMES_SYMBOL;
                fprintf(fileID,'%d %s %d %s Load Time : %f seconds\n', rowCount, TIMES_SYMBOL, columnCount, type, time);
                fprintf(fileID,'Platform : %s\n Maximum Size : %d\n Endian : %s\n Operating System : %s\n',str, maxsize, endian, getenv('OS'));
                fprintf(fileID,'Last Updated on : %s\n', char(datetime('now')));
                
                % close the file
                if ~isempty(fileID)
                    fclose(fileID);
                end
            end
        end
        
        % Determines the underlying type and status for a given variable.
        % Some datatypes, like tall or distributed arrays, have an
        % underlying datatype which is different than their class name.
        % For example, you could have a distributed double array, or a tall
        % duration array.  This function will return the secondary type
        % (double or duration), as well as an associated status if
        % applicable.  (Tall may be unevaluated).
        function [secondaryType, secondaryStatus] = getVariableSecondaryInfo(vardata)
            secondaryType = '';
            secondaryStatus = '';
            if isa(vardata, 'tall')
                [secondaryType, secondaryStatus] = ...
                    internal.matlab.variableeditor.FormatDataUtils.getTallData(vardata);
            elseif isa(vardata, 'distributed') || isa(vardata, 'codistributed') ...
                    || isa(vardata, 'gpuArray')
                secondaryType = classUnderlying(vardata);
            elseif isa(vardata, 'timeseries')
                secondaryType = class(get(vardata, 'Data'));
            end
        end
        
        function [secondaryType, secondaryStatus] = getTallData(vardata)
            % Determine the secondary information for tall variables, using
            % the getArrayInfo information
            tallInfo = matlab.bigdata.internal.util.getArrayInfo(vardata);

            if isempty(tallInfo.Class)
                secondaryType = '';
            else
                secondaryType = tallInfo.Class;
            end

            if tallInfo.Gathered
                secondaryStatus = '';
            else
                secondaryStatus = getString(message(...
                    'MATLAB:codetools:variableeditor:Unevaluated'));
            end
        end
        
        function tallInfoSize = getTallInfoSize(tallInfo)
            % Calculate a MxNx... or similar size string.  This logic
            % matches similar logic for tall variable command line display.
            % Argument is a struct, which contains the fields returned from
            % the matlab.bigdata.internal.util.getArrayInfo function.
            if isempty(tallInfo.Size) || isnan(tallInfo.Ndims)
                % No size information at all, MxNx...
                % Use the unicode character for horizontal ellipses
                dimStrs = {'M', 'N', char(8230)};
            else
                % Create a string representation of the size, replacing any
                % NaN's with a replacement letter
                
                % unknownDimLetters are the placeholders we'll use in the
                % size specification
                unknownDimLetters = 'M':'Z';
                
                dimStrs = cell(1, tallInfo.Ndims);
                for idx = 1:tallInfo.Ndims
                    if isnan(tallInfo.Size(idx))
                        if idx > numel(unknownDimLetters)
                            % Array known to be 15-dimensional, but 15th
                            % (or higher) dimension is not known. Not sure
                            % how you'd ever hit this.
                            dimStrs{idx} = '?';
                        else
                            dimStrs{idx} = unknownDimLetters(idx);
                        end
                    else
                        dimStrs{idx} = num2str(tallInfo.Size(idx));
                    end
                end                
            end
            
            % Join together dimensions using the Times symbol.            
            tallInfoSize = strjoin(dimStrs, internal.matlab.variableeditor.FormatDataUtils.TIMES_SYMBOL);
        end
        
        function s = checkIsString(var)
            % Guard against objects which have their own isstring methods
            try
                s = isstring(var);
                if ~islogical(s) || isempty(s)
                    s = false;
                end
            catch
                s = false;
            end
        end
        
        function [startRow, endRow, startColumn, endColumn] = resolveRequestSizeWithObj(...
                startRow, endRow, startColumn, endColumn, sz)
            % Resolves a requested start/end row/column range with the size
            % of a data object.  Used to provide a standard response to
            % requests which may be out of range.
            startRow = min(max(1, startRow), sz(1));
            endRow = min(max(1, endRow), sz(1));
            startColumn = min(max(1, startColumn), sz(2));
            endColumn = min(max(1, endColumn), sz(2));
        end
        
        function varSize = getVariableSize(value, varargin)
            % Returns the size of the variable. Handles objects which may
            % have a scalar size (like Java collection objects), or objects
            % which may not have a numeric size.
            if isa(value, 'tall')
                w = whos('value');
                varSize = w.size;
            else
                try
                    varSize = size(value);
                catch
                    % Assume a size of 1x1 for objects which error on size
                    varSize = [1 1];
                end
                if numel(varSize) == 1
                    % Assume a size of 1,1
                    varSize = [1 1];
                end
            end
            
            if nargin == 2
                dimension = varargin{1};
                varSize = varSize(dimension);
            end
        end
        
        function b = isVarEmpty(var)
            b = builtin('isempty', var);
        end
    end
end
    

function result = isValueSummaryClass(className)
    valueSummaryClasses = {'table', 'categorical', 'dataset', 'cell', 'struct', 'object', 'nominal', 'ordinal', 'datetime', 'duration', 'calendarDuration'};
    result = ~isempty(find(ismember(valueSummaryClasses,className),1));
end

