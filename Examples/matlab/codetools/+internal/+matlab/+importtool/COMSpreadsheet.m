% Copyright 2011-2015 The MathWorks, Inc.

%   This class is unsupported and might change or be removed without
%   notice in a future version. 

classdef COMSpreadsheet < internal.matlab.importtool.AbstractSpreadsheet
 
    properties (Hidden=true, SetAccess = protected)
        Application;
        % Conversion factor from Excel serial date numbers to
        % MATLAB 1900/1904 datenums
        DateOffset;
    end

    properties (Hidden=true)
        Workbook;
    end
    
    
    
    methods
              
        function obj = COMSpreadsheet(application)
            % When Excel is opened from the Current Folder or Windows 
            % Explorer it hijacks the first Excel COM client that was added
            % to the class factory. If that is the COM client being used by 
            % the Import Tool, the result is that Excel may flash, and fail
            % to open the requested spreadsheet when invoked this way, or it
            % may work and the Import Tool may lose its COM client when the
            % user closes the file in Excel. Either way, we must protect
            % against this by setting IgnoreRemoteRequests to true.
            % However, doing this sets also the default value of the IgnoreRemoteRequest
            % to true, so that when Excel tries to create a new instance 
            % (via DDE) it inherits a true value of IgnoreRemoteRequest, and
            % the resulting Excel is inoperable. This is prevented by 
            % creating a second Excel COM client, setting its IgnoreRemoteRequest
            % to false to force the default IgnoreRemoteRequest to false,
            % and then destroying it.
            appCount = internal.matlab.importtool.COMSpreadsheet.updateApplicationCount;
            obj.Application = application;
            % If this is the first instance of an Excel COM client, cache
            % the IgnoreRemoteRequests so that it can be restored.
            if appCount==0
                internal.matlab.importtool.COMSpreadsheet.updateDefaultIgnoreRemoteRequests(application.IgnoreRemoteRequests);
            end
            application.IgnoreRemoteRequests = true; 
            obj.Application.DisplayAlerts = 0;    
            obj.Workbook = [];
            
            % Force the default IgnoreRemoteRequest to be false if that was
            % its default value (when the first COM client was created)
            if ~internal.matlab.importtool.COMSpreadsheet.updateDefaultIgnoreRemoteRequests
                application2 = actxserver('excel.application');
                application2.IgnoreRemoteRequest = false;
                application2.Quit
                application2 = []; %#ok<NASGU>
            end
            
            % Increment the instance count.
            internal.matlab.importtool.COMSpreadsheet.updateApplicationCount(appCount+1);
        end
        function delete(obj)
            if ~isempty(obj.Workbook)
                obj.Close();
            end
            if ~isempty(obj.Application)
                % Decrement the instance count
                appCount = internal.matlab.importtool.COMSpreadsheet.updateApplicationCount-1;
                internal.matlab.importtool.COMSpreadsheet.updateApplicationCount(appCount);
                
                % Force the default IgnoreRemoteRequest to be false if
                % the default value of IgnoreRemoteRequest is false or it
                % will be set to true when obj.Application is disconnected
                % (since its IgnoreRemoteRequest is true). See g738006
                if ~internal.matlab.importtool.COMSpreadsheet.updateDefaultIgnoreRemoteRequests
                    obj.Application.IgnoreRemoteRequest = false;
                end
                obj.Application.Quit;
            end
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
       
            if ~isempty(obj.Workbook)
                obj.Close();
            end
            obj.Workbook = obj.Application.Workbooks.Open(filename, 0,true); 
            
            if GetDateOffset(obj.Workbook)
                obj.DateOffset = 'excel1904';
            else  
                obj.DateOffset = 'excel';
            end
                               
            obj.FileName = filename;
            obj.HasFile = true;
        end
 
        function columnNames = getDefaultColumnNames(this,sheetname,row,avoidShadow)
            activate_sheet(this.Application,sheetname);
            dataPos = this.GetSheetDimensions(sheetname);
            range = char(com.mathworks.mlwidgets.importtool.ImportToolUtils.toExcelRange(row,row,1,dataPos(4)-1+dataPos(3)));
            
            [~,data] = this.Read(sheetname, range);
            data = data(:)';
            columnNames = internal.matlab.importtool.ImportUtils.getDefaultColumnNames(evalin('caller','who'),data,-1,avoidShadow);
            % Convert to cellstr for JMI
            columnNames = cellstr(columnNames);
        end
        
        
        function [aMessage, description, format] = GetInfo(obj)

            if (~obj.HasFile)
                error(message('MATLAB:codetools:NoFileOpen'));
            end

            if get(obj.Workbook,'FileFormat')
                format =  get(obj.Workbook,'FileFormat');
            else
                format = 'xlWorkbookDefault';
            end
            if strcmpi(format, 'xlCurrentPlatformText') == 1
                aMessage = '';
                description = getString(message('MATLAB:codetools:UnreadableExcelFile'));
            else
                % Walk through sheets in workbook and pick out worksheets (not Charts e.g.).
                aMessage = 'Microsoft Excel Spreadsheet';
                indexes = logical([]);
                % Initialize worksheets object.
                workSheets = get(obj.Application,'Sheets');
                
                description = cell(1,workSheets.Count);
                for i = 1:workSheets.Count
                    sheet = get(workSheets,'item',i);
                    if isprop(sheet,'Type') && isprop(sheet,'UsedRange')                        
                        description{i} = sheet.Name;
                        indexes(i) = ~isempty(strfind(class(sheet), 'Worksheet')) || ...
                             ~isempty(strfind(sheet.Type, 'Worksheet'));
                        % A sheet is empty if it has no cells, or only 1 numeric cell
                        % with NaN content.
                        if indexes(i) 
                            if sheet.UsedRange.Count==1
                               try
                                  indexes(i) = (isnumeric(sheet.UsedRange.Value) && ...
                                     ~isnan(sheet.UsedRange.Value)) || ischar(sheet.UsedRange.Value);
                               catch me
                                   % If accessing the Value property of 
                                   % sheet.UsedRange caused a COM client
                                   % error treat the sheet as being empty 
                                   % (c.f. 807249)
                                   if strncmp(me.identifier,'MATLAB:COM',10)
                                       indexes(i) = false;
                                   else
                                       rethrow(me);
                                   end
                               end 
                            elseif sheet.UsedRange.Count==0
                               indexes(i) = false;
                            end
                        end
                    end
                end
                description = description(indexes);
            end            
        end
        
        % Returns a 4-tuple [startRow, rowCount, startColumn, columnCount]
        function dims = GetSheetDimensions(obj,sheetname)            
            activate_sheet(obj.Application,sheetname);
            startRow = obj.Application.ActiveSheet.UsedRange.Row;
            startColumn = obj.Application.ActiveSheet.UsedRange.Column; 
            dims = [startRow ...
                obj.Application.ActiveSheet.UsedRange.Rows.Count+startRow-1 ...
                startColumn ...
                obj.Application.ActiveSheet.UsedRange.Columns.Count+startColumn-1];
        end   

        % Initialize the WorksheetStructure cache
        function init(obj,sheetname)
            if ~isempty(obj.WorksheetStructure) && isfield(obj.WorksheetStructure,obj.generateVariableName(sheetname))
                return
            end
                
            activate_sheet(obj.Application,sheetname);
            dataPos = GetSheetDimensions(obj,sheetname);
            dims = [dataPos(2) dataPos(4)];
            
            % Get the data from a test region which is used to find the
            % row/column coordinates of the first data block
            testDims(1) = min(dims(1),com.mathworks.mlwidgets.importtool.WorksheetTableModel.DEFAULT_TEST_ROW_COUNT);
            testDims(2) = min(dims(2),com.mathworks.mlwidgets.importtool.WorksheetTableModel.DEFAULT_TEST_COLUMN_COUNT);
            range = char(com.mathworks.mlwidgets.importtool.ImportToolUtils.toExcelRange(...
                1,testDims(1),1,testDims(2)));
            [data,raw,dateData] = obj.ReadSheet(sheetname,range,false);
            nm = obj.generateVariableName(sheetname);
            
            % Find the cells in the test region which contain numeric data 
            % or cells.       
            if isempty(data) && isempty(dateData)
                obj.WorksheetStructure.(nm).initialSelection = [];
                obj.WorksheetStructure.(nm).HeaderRow = 1;
                obj.WorksheetStructure.(nm).NumericContainerColumns = true(1,dataPos(4));
                obj.WorksheetStructure.(nm).MixedContainerColumns = false(1, dataPos(4));
                obj.WorksheetStructure.(nm).CategoricalContainerColumns = false(1, dataPos(4));
                return
            elseif isempty(data) && ~isempty(dateData)
                numericOrDateCells = ~isnan(dateData);
            elseif ~isempty(data) && isempty(dateData)
                numericOrDateCells = ~isnan(data);
            elseif isequal(size(data),size(dateData))
                % dateData is a cell array
                numericOrDateCells = ~isnan(data) | ~cellfun(@isempty, dateData);
            else
                numericOrDateCells = ~isnan(data);
            end
            dataRows = find(any(numericOrDateCells,2));
            % dataColumns determines the preselection area, by default we
            % should select every column as long as it has valid data , numeric or cell (g1094403)
            cellDataColumns = find(any(cellfun(@(x) (ischar(x) && ~isempty(deblank(x))) || (~ischar(x) && ~isempty(x)) , raw), 1)); 
            
            if isempty(cellDataColumns)
                dataColumns = [];
            else
                dataColumns = unique([cellDataColumns(1), find(any(numericOrDateCells,1))]);
            end
             
            if isempty(dataColumns)
                dataColumns(1) = 1;
            end
             
            if isempty(dataRows) || isempty(dataColumns)
                % In this case, we have only cell data in the imported
                % spreadsheet so the NumericContainerColumns field should be
                % false for all columns. (g1094403)
                obj.WorksheetStructure.(nm).InitialSelection = [1 dataColumns(1) dims];
                obj.WorksheetStructure.(nm).HeaderRow = 1;
                obj.WorksheetStructure.(nm).NumericContainerColumns = false(1,dataPos(4));
                obj.WorksheetStructure.(nm).MixedContainerColumns = false(1,dataPos(4));

                % But still check for categoricals in the text columns
                categoricalCols = ...
                    internal.matlab.importtool.AbstractSpreadsheet.getCategoricalContainerColumnsFromData(raw);
                categoricalCols(1, size(categoricalCols, 2) + 1:dims(2)) = true;
                obj.WorksheetStructure.(nm).CategoricalContainerColumns = categoricalCols;
                return
            end
            
            try
                % Use the CurrentRegion property to determine bottom right
                % row/column coordinates for the contiguous block of cells
                % which contain the top left cell of the first data block 
                dataStartString = sprintf('%s%d',...
                    char(com.mathworks.mlwidgets.importtool.ImportToolUtils.intToColumnString(dataColumns(1))),...
                    dataRows(1));
                DataRange =  Range(obj.Application,dataStartString);
                
                % If there is no CurrentRegion property, just select to
                % the end of the sheet
                if ~isprop(DataRange,'CurrentRegion') 
                    initialSelection = [dataRows(1) dataColumns(1) dims];
                    obj.WorksheetStructure.(nm).InitialSelection = initialSelection;
                    obj.WorksheetStructure.(nm).HeaderRow = ...
                        internal.matlab.importtool.AbstractSpreadsheet.getHeaderRowFromData(...
                            raw(1:min(20,size(raw,1)),1:min(size(raw,2),20)),...
                            data(1:min(20,size(data,1)),1:min(size(data,2),20)));
                else
                    lastRow = DataRange.CurrentRegion.Rows.Count+DataRange.CurrentRegion.Rows.Row-1;
                    lastColumn = DataRange.CurrentRegion.Columns.Count+DataRange.CurrentRegion.Columns.Column-1;
                    initialSelection = [dataRows(1) dataColumns(1) lastRow lastColumn];
                    obj.WorksheetStructure.(nm).InitialSelection = initialSelection;
                    obj.WorksheetStructure.(nm).HeaderRow = ...
                         internal.matlab.importtool.AbstractSpreadsheet.getHeaderRowFromData(...
                              raw(1:min(20,size(raw,1)),...
                              dataColumns(1):min(size(raw,2),dataColumns(1)+20)),...
                              data(1:min(20,size(data,1)),...
                              dataColumns(1):min(size(data,2),20+dataColumns(1))));
                end
                [numericContainerColumns, mixedContainerColumns] = ...
                    internal.matlab.importtool.AbstractSpreadsheet.getNumericContainerColumnsFromData(raw, data);
                % If the number of columns is > the number of columns in
                % the sample data, the additional columns are assumed
                % numeric (i.e. not cell array columns)
                numericContainerColumns(1,size(numericContainerColumns,2)+1:dims(2)) = true;
                obj.WorksheetStructure.(nm).NumericContainerColumns = numericContainerColumns;
                
                mixedContainerColumns(1,size(mixedContainerColumns,2)+1:dims(2)) = true;
                obj.WorksheetStructure.(nm).MixedContainerColumns = mixedContainerColumns;
                
                categoricalCols = ...
                    internal.matlab.importtool.AbstractSpreadsheet.getCategoricalContainerColumnsFromData(raw);
                categoricalCols(1,size(categoricalCols,2)+1:dims(2)) = true;
                obj.WorksheetStructure.(nm).CategoricalContainerColumns = categoricalCols;

            catch me %#ok<NASGU>
                % If something went wrong with the Excel COM client
                % interaction, just select to
                % the end of the sheet
                initialSelection = [dataRows(1) dataColumns(1) dims];
                obj.WorksheetStructure.(nm).InitialSelection = initialSelection;
                obj.WorksheetStructure.(nm).HeaderRow = 1;
                obj.WorksheetStructure.(nm).NumericContainerColumns = true(1,dims(2));
                obj.WorksheetStructure.(nm).MixedContainerColumns = false(1, dims(2));
                obj.WorksheetStructure.(nm).CategoricalContainerColumns = false(1, dims(2));
            end
        end
                
        function Close(obj)
            try
                obj.Workbook.Close(false);
                obj.HasFile = false;
                obj.Workbook = [];
            catch exception
               warning(exception.identifier, '%s', exception.message);
            end
        end
        
        function [data,raw,dateData] = Read(obj, sheetname, range, useValue2, asDatetime)
            if nargin<=3
                useValue2 = true;
                
                % Unless explicitly set as an argument, read dates as
                % datetimes and return as text, rather than datetime
                % objects.
                asDatetime = false;
            end
            defaultRange = '';
            if (~obj.HasFile)
                error(message('MATLAB:codetools:NoFileOpen'));
            end
            if nargin < 3
                range = defaultRange;
            end
          
            validateattributes(range, {'char'},{}, 'spreadsheet', 'Range');
          
            [data,raw,dateData] = ReadSheet(obj, sheetname, range, useValue2, asDatetime);              
            raw = raw(:);
        end
        
        function [data,raw,dateData] = ReadSheet(obj, sheetname, range, useValue2, asDatetime)
            if nargin<5
                % Unless explicitly set as an argument, read dates as
                % datetimes and return as text, rather than datetime
                % objects.
                asDatetime = false;
            end
            activate_sheet(obj.Application,sheetname);
            if ~isempty(range)
                DataRange = Range(obj.Application,sprintf('%s',range));
            else
                DataRange = obj.Application.ActiveSheet.UsedRange;
            end

            % Get the values in the used regions on the worksheet.
            try
                raw = DataRange.Value;
            catch
                if (DataRange.Count == 1)
                    raw = 'ActiveX VT_ERROR: ';
                end
            end
            if ~iscell(raw)
                raw = {raw};
            end

            % If the Value2 and Value properties differ, it is because 
            % the cell is formatted as a date. This is based on the fact
            % that Excel converts cells formatted as Dates to a variant
            % containing a VBA date type in the Range.Value. This is
            % represented as a string in MATLAB. The Value2 property
            % contains the Excel serial date number.
            nrows = size(raw,1);
            ncols = size(raw,2);
            
            if length(useValue2) ~= ncols
                useValue2 = true(1, ncols);
            end
            
            % dateData will be stored as a cell array of text or datetimes.
            % The cell arrays of datetimes is done to accomodate datetime
            % columns with different formats
            if asDatetime
                dateData = cell(1, ncols);
            else
                dateData = cell(nrows, ncols);
            end

            if any(useValue2)
                try
                    cellValues2 = DataRange.Cells.Value2;
                catch
                    if (DataRange.Count == 1)
                        cellValues2 = 'ActiveX VT_ERROR: ';
                    end
                end
                if ~iscell(cellValues2)
                    cellValues2 = {cellValues2};
                end
            
                for col=1:ncols
                    if ~useValue2(col)
                        continue;
                    end
                    
                    % Future Excel COM clients could also encode other formats
                    % so that the Value property is a string and the Value2
                    % property is a number. To protect against assuming that
                    % these calls are dates we check the NumberFormat below.
                    % Note that we only do this test for the first cell in each
                    % column where the Value and Value2 are different to avoid
                    % a performance hit due to multiple calls to NumberFormat 
                    % (this is very slow). There is a very small probability
                    % that this test will be invalid for other cells in the
                    % same column if the spreadsheet were to mix dates and
                    % other special formats in the same column and the
                    % Value/Value2 behavior were to change.
                    testedDateFormatForColumn = false;
                    columnContainsDates = false;
                    
                    % Initialize column of spreadsheet dates to nan
                    dateColNums = NaN(nrows, 1);
                    formatStr = [];
                    
                    for row=1:nrows
                       if ~isequaln(raw{row,col},cellValues2{row,col}) && ...
                               ischar(raw{row,col}) 
                           if ~testedDateFormatForColumn
                               columnContainsDates = ...
                                  ~isempty(regexp(DataRange.Item(col).NumberFormat, '[^0#?.%,Ee+-]', 'once'));
                               testedDateFormatForColumn = true;
                               
                               if columnContainsDates
                                   % Determine the format of the date
                                   % column based on the content in the
                                   % first date.
                                   formatStr = ...
                                       internal.matlab.importtool.ImportUtils.getDateFormat(...
                                       raw{row,col});
                                   if ~isempty(formatStr)                                      
                                       obj.WorksheetStructure.(obj.generateVariableName(sheetname)).dateFormats{1, col} = formatStr;
                                   else
                                       obj.WorksheetStructure.(obj.generateVariableName(sheetname)).dateFormats{1, col} = 'default';
                                   end
                               end
                           end

                           if columnContainsDates
                               % Use the Excel serial date number for the
                               % conversion to datetime later on.
                               dateColNums(row) = cellValues2{row,col};
                           end
                       end
                       
                       % Replace with something more like what spreadsheet show (g718226) 
                       if ischar(raw{row,col}) && strcmp(deblank(raw{row,col}),'ActiveX VT_ERROR:')
%                         if ischar(raw{row,col}) && strncmp(raw{row,col},'ActiveX VT_ERROR:',17)
                           raw{row,col} = '#Error?';
                       end
                    end
                    
                    % Guard against negative dates (Excel spreadsheet dates
                    % cannot be negative, or else they are invalid).
                    dateColNums(dateColNums<0) = NaN;
                    
                    % Convert the spreadsheet dates to datetime all at once
                    if ~isempty(formatStr)
                        dateCol = datetime(dateColNums, 'ConvertFrom', ...
                            obj.DateOffset, 'Format', formatStr);
                    else
                        dateCol = datetime(dateColNums, 'ConvertFrom', ...
                            obj.DateOffset);
                    end
                    
                    % Assign the datecol column into the dateData
                    if asDatetime
                        dateData{col} = dateCol;
                    else
                        if all(isnan(dateColNums))
                            [dateData{:,col}] = deal('');
                        else
                            dateData(:,col) = cellstr(dateCol);
                            nanDates = isnat(dateCol);
                            if any(nanDates)
                                [dateData{nanDates,col}] = deal('');
                            end
                        end
                    end
                end
            end

            % Parse data into numeric and string arrays
            data = internal.matlab.importtool.AbstractSpreadsheet.parse_data(raw);
            
            % Cast numeric non-doubles to double 
            nanDataInd = isnan(data(:));
            doubleRawInd = cellfun('isclass',raw(:),'double');         
            INumericNonDouble = ~nanDataInd & ~doubleRawInd;
            if any(INumericNonDouble)
                raw(INumericNonDouble) = num2cell(double(data(INumericNonDouble)));
            end

            % Replace NaNs in the raw array, since NaN is used in raw
            % arrays by WorksheetRules as a numeric replacement value and
            % NonNumericReplacementRule uses NaN raw array values to
            % identify cells whose contents have been replaced by NaN and 
            % do not require further modification by a subsequent rule
            % (g716691)
            raw(nanDataInd & doubleRawInd) = {''};
        end   

    end
    
    methods (Static)
        % Set or get the simulated static property ApplicationCount
        function appCount = updateApplicationCount(count)
            persistent applicationCount;
            if nargin>=1
                applicationCount = count;
            elseif isempty(applicationCount)
                applicationCount = 0;
            end
            appCount = applicationCount;
        end  
        
        % Set or get the simulated static property DefaultIgnoreRemoteRequests
        function ignoreRemoteRequests = updateDefaultIgnoreRemoteRequests(state)
            persistent defaultIgnoreRemoteRequests;
            if nargin>=1
                defaultIgnoreRemoteRequests = state;
            elseif isempty(defaultIgnoreRemoteRequests)
                defaultIgnoreRemoteRequests = false;
            end
            ignoreRemoteRequests = defaultIgnoreRemoteRequests;
        end 
    end
end

function aMessage = activate_sheet(Application,Sheet)
    % Activate specified worksheet in workbook.

    % Initialize worksheet object
    WorkSheets = GetApplicationSheets(Application);
    aMessage = struct('message',{''},'identifier',{''});

    % Get name of specified worksheet from workbook
    try
        TargetSheet = get(WorkSheets,'item',Sheet);
    catch  %#ok<CTCH>
        error(message('MATLAB:codetools:WorksheetNotFound'));        
    end

    % Activate silently fails if the sheet is hidden
    set(TargetSheet, 'Visible','xlSheetVisible');
    % Activate worksheet
    Activate(TargetSheet);
end

function sheets = GetApplicationSheets(appl)
    % Sometimes it takes some time for Excel to be ready and will error
    % will occur when getting the value of any propeties such as
    % Application.Sheets. Thus the try/catch and pause.
    for i=1:500
        try
            sheets = get(appl,'Sheets');
            break;
        catch
            pause(0.01);
        end
    end
end

function dateOffset = GetDateOffset(book)
    % Sometimes it takes some time for Excel to be ready and will error
    % will occur when getting the value of any propeties such as
    % Workbook.Date1904. Thus the try/catch and pause.
    for i=1:500
        try
            dateOffset = get(book, 'Date1904');
            break;
        catch
            pause(0.01);
        end
    end
end

function v = isnat(t) 
    % Temporary local function to be replaced when datetime version is
    % available
    v = isnan(datenum(t));
end
