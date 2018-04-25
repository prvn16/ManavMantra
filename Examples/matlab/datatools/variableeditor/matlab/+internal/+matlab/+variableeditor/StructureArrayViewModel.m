classdef StructureArrayViewModel < internal.matlab.variableeditor.ArrayViewModel
    %STRUCTUREARRAYVIEWMODEL
    %   Structure Array View Model

    % Copyright 2015 The MathWorks, Inc.
    
    properties
        MetaData = [];
        UniformDataTypeColumn = [];
    end
    
    % Public Abstract Methods
    methods(Access='public')
        % Constructor
        function this = StructureArrayViewModel(dataModel)
            this@internal.matlab.variableeditor.ArrayViewModel(dataModel);
        end
        
        function [renderedData, renderedDims] = getRenderedData(this,startRow,endRow,startColumn,endColumn)
            currentData = this.DataModel.getData();
            if ~isempty(currentData)
                currentDataAsCell = this.convertStructToCell(currentData);
                [renderedData, renderedDims, metaData] = this.formatDataBlockForMixedView(startRow,endRow,startColumn,endColumn,currentDataAsCell);
            else
                renderedDims = size(currentData);
                renderedData = cell(renderedDims);
                metaData = false(renderedDims);
            end
            this.MetaData = metaData;
        end                
        
        % The view model's getSize should always return the size of the 
        % structure array when converted to a cell array 
        % TOREMOVE : called from gridEditorHandler
        function s = getSize(this)
            data = this.DataModel.getData;
            % mx1 struct array
            if (size(data,2) == 1)
                s = [size(data,1) length(fields(data))];
            % 1xm struct array, 0x0 struct array
            else
                s = [size(data,2) length(fields(data))];
            end
        end
        
        % The view model's getData should return the data  
        % converted to a cell array 
        % TOREMOVE :  called from handleClientSetData
        function varargout = getData(this,varargin)
            % the input arguments consist of startRow, startCol, endRow,
            % endCol
            structData = this.DataModel.getData(varargin{:});
            dataAsCell = struct2cell(structData);
            % when the data is converted to a cell, it is a row vector. We
            % need to index into this using the column number.
            varargout{1} = dataAsCell{varargin{3}};
        end
        
        function varargout = getFormattedSelection(this, varargin)
            data = this.DataModel.getData;
            structDataAsCell = this.convertStructToCell(data);
            fields = fieldnames(data);
            
            selectedColumns = this.SelectedColumnIntervals;
            selectedRows = this.SelectedRowIntervals;
            dataModelName = this.DataModel.Name;

            if isempty(selectedRows) || isempty(selectedColumns)
                varargout{1} = '';
            else
                varargout{1} = internal.matlab.variableeditor.StructureArrayViewModel.getFormattedSelectionString(selectedRows, ...
                    selectedColumns, fields, dataModelName, data, structDataAsCell);
            end
        end
                        
    end    
    
    methods(Static=true)
        function selectionString = getFormattedSelectionString(selectedRows, selectedColumns, fields, dataModelName, data, structDataAsCell)
            selectionRowString = '';
            selectionColString = '';
            selectionString = '';
            rowCount = size(data,2);
            
            % this variable evaluates the selected data before returning 
            % the constructed selection string. If the selected
            % data is not valid (.i.e. throws an error at the command window 
            % on evaluation) then the selection string is returned as
            % empty.
            validateSelectionColString = '';
            if ~isempty(selectedRows) || ~isempty(selectedColumns)
                
                % check if all the selected data is numeric
                % This is required in order to construct the selection
                % string and enclose it in 
                % 1. [] if all the data is numeric
                % 2. {} if data is mixed
                allNumericSelection = isSelectionNumeric(selectedRows, selectedColumns, structDataAsCell);
                
                % selectedRows
                for i=1:size(selectedRows,1)
                    if i > 1
                        selectionRowString = [selectionRowString ',']; %#ok<AGROW>
                    end
                    
                    if (selectedRows(i,1) == selectedRows(i,2))                       
                        selectionRowString = [selectionRowString num2str(selectedRows(i,1))]; %#ok<AGROW>
                    else
                        % case when a range of subsequent fields are selected
                        selectionRowString = [selectionRowString internal.matlab.variableeditor.StructureArrayViewModel.localCreateSubindex([selectedRows(i,1) selectedRows(i,2)],rowCount)];%#ok<AGROW>
                    end
                end
                % If we have more than one set of selctions, we need to
                % enclose the selection string in '[' and ']'
                if size(selectedRows, 1) > 1 
                    selectionRowString = ['([' selectionRowString '])'];
                elseif ~(selectedRows(1)==1 && selectedRows(2)==rowCount)
                    selectionRowString = ['(' selectionRowString ')'];
                end
                
                % selected Columns
                for i=1:size(selectedColumns,1)
                    if i > 1
                        selectionColString = [selectionColString ';']; %#ok<AGROW>
                        validateSelectionColString = [validateSelectionColString ',']; %#ok<AGROW>
                    end
                    % case when individual disjoint fields are selected
                    if (selectedColumns(i,1) == selectedColumns(i,2))
                        % display string format in case of grouped column
                        if ~allNumericSelection    
                            validateSelectionColString = [validateSelectionColString '{' 'data' selectionRowString '.' char(fields(selectedColumns(i,1))) '}']; %#ok<AGROW>
                            selectionColString = [selectionColString '{' dataModelName selectionRowString '.' char(fields(selectedColumns(i,1))) '}']; %#ok<AGROW>
                        else
                            validateSelectionColString = [validateSelectionColString '[' 'data' selectionRowString '.' char(fields(selectedColumns(i,1))) ']']; %#ok<AGROW>
                            selectionColString = [selectionColString '[' dataModelName selectionRowString '.' char(fields(selectedColumns(i,1))) ']']; %#ok<AGROW>
                        end
                    else
                        % case when a range of subsequent fields are selected
                        for j=(selectedColumns(i,1)):(selectedColumns(i,2))
                            if j > selectedColumns(i,1)
                                selectionColString = [selectionColString ';']; %#ok<AGROW>
                                validateSelectionColString = [validateSelectionColString ',']; %#ok<AGROW>
                            end
                            % display string format in case of grouped column
                            if ~allNumericSelection
                                validateSelectionColString = [validateSelectionColString '{' 'data' selectionRowString '.' char(fields(j)) '}'];  %#ok<AGROW>
                                selectionColString = [selectionColString '{' dataModelName selectionRowString '.' char(fields(j)) '}']; %#ok<AGROW>
                            else
                                validateSelectionColString = [validateSelectionColString '[' 'data' selectionRowString '.' char(fields(j)) ']']; %#ok<AGROW>
                                selectionColString = [selectionColString '[' dataModelName selectionRowString '.' char(fields(j)) ']']; %#ok<AGROW>
                            end
                        end
                    end
                end
                try
                   % check if the string is a valid commands
                   validateSelectionColString = ['{' validateSelectionColString '};'];
                   eval(validateSelectionColString);
                   selectionString = selectionColString;
                catch
                end
            end                  
        end
        
        % for testing purpose only
        function result = testIsSelectionNumeric(selectedRows, selectedColumns, data)
            result = isSelectionNumeric(selectedRows, selectedColumns, data);
        end
        
        function subindexString = localCreateSubindex(selectedInterval,count)
            subindexString = internal.matlab.variableeditor.BlockSelectionModel.localCreateSubindex(selectedInterval,count);
            if selectedInterval(1)==1 && selectedInterval(2)==count % All rows/columns
                subindexString = '';
            end    
        end
                            
     end
    
end

%method returns if the data selected is numeric or not
% it checks only for scalars. If the selection consists of non-scalar
% entires or value summaries, it returns false
function allNums = isSelectionNumeric(selectedRows, selectedColumns, data)
allNums = false;
% if the first entry is numeric then check the rest
if isnumeric(data{selectedRows(1,1),selectedColumns(1,1)})
    allNums = true;
    for i=1:size(selectedRows,1)
        for j=1:size(selectedColumns,1)
            selectedData = data(selectedRows(i,1):selectedRows(i,2),selectedColumns(j,1):selectedColumns(j,2));
            % check that all entires are scalar
            if all(cellfun('length',selectedData) <= 1)
                % check that all entires have the same class type
                if ~all(cellfun('isclass',selectedData,class(data{selectedRows(1,1),selectedColumns(1,1)})))
                    allNums = false;
                    break;
                end
            else
                allNums = false;
                break;
            end
        end
        if ~allNums
            break;
        end
    end
end
end

