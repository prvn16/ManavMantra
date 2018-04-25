% Copyright 2011-2015 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version.

classdef InMemSpreadsheet < internal.matlab.importtool.AbstractSpreadsheet
    properties(SetAccess = protected)
        BasicSheetData;
        IsCSV = false;
    end
    
    
    methods

        function [data, dateData, raw] = ImportDataBlock(obj, sheetname, range, ~,  ~)
            import com.mathworks.mlwidgets.importtool.*;
            [data, raw, dateData] = Read(obj, sheetname, range); 
        end

        
        function Open(obj, filename)
            if nargin < 2 || isempty(filename)
                error(message('MATLAB:codetools:FilenameMustBeSpecified'));
            end
            if ~ischar(filename)
                error(message('MATLAB:codetools:FilenameMustBeAString'));
            end
            if any(strfind('*', filename))
                error(message('MATLAB:codetools:FilenameMustNotContainAsterisk'));
            end
            
            % Build an empty BasicSheetData struct array. Data will be
            % added to it via xlsread when it is accessed using Read.
            [~,bookName,ext] = fileparts(filename);
            if strcmp('.csv',ext)
                obj.IsCSV = true;
                sheets = {bookName};
            else
                obj.IsCSV = false;
                [~,sheets] = xlsfinfo(filename);
            end
            if ischar(sheets) % If there was an error, throw it...
                % Because this error is caught by Java, we need to
                % fix it so that content doesn't get lost in the
                % conversion to java strings
                err = strrep(sheets, '\', '\\');
                throw(MException('importtool:AbstractSpreadsheet', err));
            end
            basicSheetData = struct('SheetNames',sheets,'Data',repmat({[]},size(sheets)),...
                'Raw',repmat({{}},size(sheets)));
            obj.BasicSheetData = basicSheetData;
            
            
            
            obj.FileName = filename;
            obj.HasFile = true;
            
            obj.loadsheet(sheets{1});
        end
        
        function [aMessage, description, format] = GetInfo(obj)
            % The upper row limit on linux is only Integer.MAX_VALUE 
            if (~obj.HasFile)
                error(message('MATLAB:codetools:NoFileOpen'));
            end
            
            if obj.IsCSV
                format = 'csv';
            else
                format = '';
            end
            
            if obj.IsCSV && isempty(obj.BasicSheetData(1).Raw)
                aMessage = '';
                description = getString(message('MATLAB:codetools:UnreadableOrEmptyCSVFile'));
                return
            end
            aMessage = 'Microsoft Excel Spreadsheet';
            
            % In basic mode the sheet names are derived from the BasicSheetData
            % which was created when the spreadsheet object was opened.
            description = {obj.BasicSheetData.SheetNames};

            
        end
        
        function Close(obj)
            obj.BasicSheetData = [];
            obj.HasFile = false;
        end
 
        function columnNames = getDefaultColumnNames(this,sheetname,row,avoidShadow)
            dims = this.GetSheetDimensions(sheetname);
            range = char(com.mathworks.mlwidgets.importtool.ImportToolUtils.toExcelRange(row,row,1,dims(4)));
            
            [~,data] = this.Read(sheetname, range);
            data = data(:)';
            columnNames = internal.matlab.importtool.ImportUtils.getDefaultColumnNames(evalin('caller','who'),data,-1,avoidShadow);
            % Convert to cellstr for JMI
            columnNames = cellstr(columnNames);
        end
        
        % Returns a 4-tuple [startRow, rowCount, startColumn, columnCount]
        % For non-COM client cases the startRow and startColumn values are
        % always 1.
        function dims = GetSheetDimensions(obj,sheetname)           
            sheetI = obj.loadsheet(sheetname);
            sizeArray = size(obj.BasicSheetData(sheetI).Raw);
            dims = [1 sizeArray(1) 1 sizeArray(2)];
        end 
 
        % Initialize the WorksheetStructure cache
        function init(obj,sheetname)
            if ~isempty(obj.WorksheetStructure) && isfield(obj.WorksheetStructure,obj.generateVariableName(sheetname))
                return
            end
            
            sheetI = obj.loadsheet(sheetname);
            raw = obj.BasicSheetData(sheetI).Raw;
            
            % Get the data from a test region which is used to find the
            % row/column coordinates of the first data block
            dims = size(raw);
            testDims(1) = min(dims(1),com.mathworks.mlwidgets.importtool.WorksheetTableModel.DEFAULT_TEST_ROW_COUNT);
            testDims(2) = min(dims(2),com.mathworks.mlwidgets.importtool.WorksheetTableModel.DEFAULT_TEST_COLUMN_COUNT);  
            raw = raw(1:testDims(1),1:testDims(2));
            
            % Find the cells in the test region which contain numeric data 
            % or cells.
            numericOrDateCells = cellfun(@(x) ~isempty(x) && isnumeric(x) && ~isnan(x),raw); 
             % should select every column as long as it has valid data, numeric or cell (g1094403)
            cellDataColumns = find(any(cellfun(@(x) (ischar(x) && ~isempty(deblank(x))) || (~ischar(x) && ~isempty(x) && ~isnan(x)) , raw), 1)); 
             
            dataRows = find(any(numericOrDateCells,2));
            
            if isempty(cellDataColumns)
                dataColumns = [];
            else
                dataColumns = unique([cellDataColumns(1), find(any(numericOrDateCells,1))]);
            end
                        
            if isempty(dataColumns)
                dataColumns(1) = 1;
            end

            nm = obj.generateVariableName(sheetname);
            if isempty(dataRows) || isempty(dataColumns)
                % In this case, we have only cell data in the imported
                % spreadsheet so the NumericContainerColumns field should be
                % false for all columns. (g1094403)
                obj.WorksheetStructure.(nm).InitialSelection = [1 dataColumns(1) dims];
                obj.WorksheetStructure.(nm).HeaderRow = 1;
                obj.WorksheetStructure.(nm).NumericContainerColumns = false(1,dims(2));
                obj.WorksheetStructure.(nm).MixedContainerColumns = false(1,dims(2));
                
                % But still check for categorical columns
                categoricalCols = ...
                    internal.matlab.importtool.AbstractSpreadsheet.getCategoricalContainerColumnsFromData(raw);
                categoricalCols(1,size(categoricalCols,2)+1:dims(2)) = true;
                obj.WorksheetStructure.(nm).CategoricalContainerColumns = categoricalCols;
%                 obj.WorksheetStructure.(nm).CategoricalContainerColumns = false(1, dims(2));
                return
            end
            initialSelection = [dataRows(1) dataColumns(1) dims];  
            obj.WorksheetStructure.(nm).InitialSelection = initialSelection;
            obj.WorksheetStructure.(nm).HeaderRow = ...
                       internal.matlab.importtool.AbstractSpreadsheet.getHeaderRowFromData(raw);
                   
            % Create a data arra, which is a numeric array (with anything
            % non-numeric converted to NaN), and a raw cell array with any
            % NaN's converted to empty strings.  This is done to match the
            % behavior of the COM client implementation of spreadsheets,
            % and the input of the getNumericContainerColumnsFromData
            % method, so the initial selection will better match the COM
            % client on a PC.
            [data, raw] = obj.updateDataAndRawLikeCOMClient(raw);
            
            % If the number of columns is > the number of columns in
            % the sample data, the additional columns are assumed
            % numeric (i.e. not cell array columns)
            [numericContainerColumns, mixedContainerColumns] = ...
                internal.matlab.importtool.AbstractSpreadsheet.getNumericContainerColumnsFromData(raw, data);
            numericContainerColumns(1,size(numericContainerColumns,2)+1:dims(2)) = true;
            obj.WorksheetStructure.(nm).NumericContainerColumns  = numericContainerColumns;
            
            mixedContainerColumns(1,size(mixedContainerColumns,2)+1:dims(2)) = true;
            obj.WorksheetStructure.(nm).MixedContainerColumns = mixedContainerColumns;
            
            categoricalCols = ...
                internal.matlab.importtool.AbstractSpreadsheet.getCategoricalContainerColumnsFromData(raw);
            categoricalCols(1,size(categoricalCols,2)+1:dims(2)) = true;
            obj.WorksheetStructure.(nm).CategoricalContainerColumns = categoricalCols;
        end
        
        function [data,raw,dateData,dims] = Read(obj, sheetname, range, ~)
            defaultRange = '';
            if (~obj.HasFile)
                error(message('MATLAB:codetools:NoFileOpen'));
            end
            if nargin < 3
                range = defaultRange;
            end
            
            validateattributes(range, {'char'},{}, 'spreadsheet', 'Range');
               
            sheetI = obj.loadsheet(sheetname);
            
            % Take the intersection between the cached BasicSheetData
            % raw array and the rows and columns defined by the
            % range.
            [rows,cols] = internal.matlab.importtool.AbstractSpreadsheet.excelRangeToMatlab(range);
            raw = repmat({''},[length(rows) length(cols)]);
            raw_ = obj.BasicSheetData(sheetI).Raw;        
            rows1 = rows(rows<=size(raw_,1));
            cols1 = cols(cols<=size(raw_,2));
            if isempty(rows1) || isempty(cols1)
                raw = {};
            else
                raw(rows1-rows1(1)+1,cols1-cols1(1)+1) = raw_(rows1,cols1);
            end
            raw(cellfun(@(x) isempty(x) || (isnumeric(x) && isnan(x)),raw)) = {''};
            
            % Create the data array from the raw array. Note that the
            % value for "data" returned from xlsread cannot be used
            % since it may exclude an unknown number of header
            % rows/columns.
            data = NaN(size(raw));
            I = cellfun('isclass',raw,'double') & ~cellfun('isempty',raw);
            data(I) = cell2mat(raw(I));
            dateData = cell(1, size(raw, 2));
            dims = size(raw_);
            
            raw = raw(:);
        end        
        
    end
    
    methods (Access = private)
        function sheetI = loadsheet(obj,sheetname)
            sheetI = strcmp({obj.BasicSheetData.SheetNames},sheetname);
            if ~any(sheetI)
                error(message('MATLAB:codetools:NoSheet'));
            end
            if isempty(obj.BasicSheetData(sheetI).Raw)
                if obj.IsCSV
                    % Create a cell array to contain all data and a numeric
                    % array to contain only numeric data. The numeric data
                    % will not contain data from row headers or column
                    % headers.
                    [importDataOut,~,header] = importdata(obj.FileName,',');
                    if isstruct(importDataOut) && isfield(importDataOut,'textdata') && ...
                          isfield(importDataOut,'data')  
                        numericData = importDataOut.data;
                        fid = fopen(obj.FileName);
                        colCount = sum(fgetl(fid)==char(','))+1;
                        fclose(fid);
                        rowCount = header+size(numericData,1);
                        rawData = cell(rowCount,colCount);
                        rawData(1:size(importDataOut.textdata,1),1:size(importDataOut.textdata,2)) = importDataOut.textdata;
                    elseif iscell(importDataOut)
                        % If importdata returns a cell array of header
                        % strings, parse them into a cell array, converting
                        % number strings to numbers.
                        for k=1:length(importDataOut)
                            textLine = textscan(importDataOut{k},'%s','CollectOutput', true, 'delimiter',',');
                            textLine = textLine{1};
                            textLine = textLine(:)';
                            for pos=1:length(textLine)
                                [num,count,err] = sscanf(textLine{pos},'%f');
                                if isempty(err) && count==1
                                    textLine{pos} = num;
                                end
                            end
                            out(k,:) = textLine; %#ok<AGROW>
                        end
                        rawData = out;
                        numericData = [];
                    elseif isnumeric(importDataOut)
                        numericData = importDataOut;
                        rawData = num2cell(numericData);
                    end
                    
                    % Convert strings in the row headers and columns headers
                    % of the cell array to numbers.
                    colHeaders = size(rawData,2)-size(numericData,2);
                    for row=1:header
                        for col=1:size(rawData,2)
                            cellData = rawData{row,col};
                            if ~isempty(cellData) && ischar(cellData)
                                [out,count,err] = sscanf(cellData,'%f');
                                if isempty(err) && count==1
                                    rawData{row,col} = out;
                                end
                            end
                        end
                    end
                    for col=1:colHeaders
                        for row=1:size(rawData,1)
                            cellData = rawData{row,col};
                            if ~isempty(cellData) && ischar(cellData)
                                [out,count,err] = sscanf(cellData,'%f');
                                if isempty(err) && count==1
                                    rawData{row,col} = out;
                                end
                            end
                        end
                    end
                    
                    % Populate non-header cells with numeric content (these
                    % cells are empty otherwise).
                    if ~isempty(numericData)
                        rawData(header+1:end,colHeaders+1:end) = num2cell(numericData);  
                    end
                    obj.BasicSheetData(sheetI).Raw = rawData;
                else
                    [~,~,obj.BasicSheetData(sheetI).Raw] = ...
                      xlsread(obj.FileName,sheetname);
                end
            end
        end
    end
    
    methods (Static = true)
        function [data, raw] = updateDataAndRawLikeCOMClient(raw)
            % Create a data arra, which is a numeric array (with anything
            % non-numeric converted to NaN), and a raw cell array with any
            % NaN's converted to empty strings.  This is done to match the
            % behavior of the COM client implementation of spreadsheets,
            % and the input of the getNumericContainerColumnsFromData
            % method. (This way PC and non-PC behavior will be more
            % consistent).
            data = raw;
            data(~cellfun(@isnumeric, data)) = {NaN};
            raw (cellfun(@(x) isnumeric(x) && isnan(x), raw)) = {''};
            data = cell2mat(data);
        end
    end
end
