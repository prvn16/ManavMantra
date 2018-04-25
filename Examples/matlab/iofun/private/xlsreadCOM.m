function [numericData, textData, rawData, customOutput] = xlsreadCOM(file, sheet, range, Excel, customFun)
    % xlsreadCOM is the COM implementation of xlsread.
    %   [NUM,TXT,RAW,CUSTOM]=xlsreadCOM(FILE,SHEET,RANGE,EXCELS,CUSTOM) reads
    %   from the specified SHEET and RANGE.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.

    %   Copyright 1984-2016 The MathWorks, Inc.
    
    % OpenExcelWorkbook may throw an exception if, for example, an invalid
    % file format is specified.
    readOnly = true;
    [~, workbookHandle,workbookState] = openExcelWorkbook(Excel, file, readOnly);
    c = onCleanup(@()xlsCleanup(Excel,file,workbookState));
    
    if isequal(sheet,-1)
        % User requests interactive range selection.
        % Set focus to first sheet in Excel workbook.
        activate_sheet(Excel, 1);
        
        % Make Excel interface the active window.
        set(Excel,'Visible',true);
        
        % Bring up message box to prompt user.
        uiwait(warndlg({getString(message('MATLAB:xlsread:DlgSelectDataRegion'));...
            getString(message('MATLAB:xlsread:DlgClickOKToContinueInMATLAB'))},...
            getString(message('MATLAB:xlsread:DialgoDataSelectionDialogue')),'modal'));
        DataRange = get(Excel,'Selection');
        
        if isempty(DataRange)
            error(message('MATLAB:xlsread:NoRangeSelected'));
        end
        
        % remove Excel interface from desktop
        set(Excel,'Visible',false); 
        
        % Apply a custom function to the data if the function
        % exists
        [DataRange, customOutput] = applyCustomFun(nargin, customFun, DataRange);
             
        % get the values in the used regions on the worksheet.
        rawData = DataRange.Value;
    else
        % Activate indicated worksheet.
        activate_sheet(workbookHandle,sheet);
        
        try
            if ~isempty(range)
                % They specified the range
                rangeObject = Range(Excel, range);
            else
                % The range was not specified.
                rangeObject = Excel.Application.ActiveSheet.UsedRange;
            end
        catch exception
            if strcmp(exception.identifier, 'MATLAB:COM:E2148140012')
                % Invalid range argument
                error(message('MATLAB:xlsread:RangeSelection', range));
            else
                % Throw any exceptions we don't expect
                throw(exception);
            end
        end
        
        if isempty(customFun)
            customOutput = [];
            try % Read the sheet in segments
                rawData = segmentedRead(Excel, rangeObject, 5000);
            catch exception
                if strcmp(exception.identifier, 'MATLAB:xlsread:SpreadsheetTooLarge')
                    % We still couldn't fit all the data into memory.  Try
                    % reading again, this time with smaller segments.
                    rawData = segmentedRead(Excel, rangeObject, 1000);
                else
                    % Throw any exceptions we don't expect
                    throw(exception);
                end
            end
        else
            % Because we can't predict the type of output a custom
            % function returns, we can't do a segmented read.  Do a
            % straight read instead.
            [rawData, customOutput] = read(Excel, rangeObject, customFun, nargin);
        end
    end

    % parse data into numeric and string arrays
    [numericData, textData] = xlsreadSplitNumericAndText(rawData);
    
end
%--------------------------------------------------------------------------
function activate_sheet(Workbook,Sheet)
    % Activate specified worksheet in workbook.
    
    % Initialize worksheet object
    WorkSheets = Workbook.Worksheets;
    
    % Get name of specified worksheet from workbook
    try
        TargetSheet = get(WorkSheets,'item',Sheet);
    catch  %#ok<CTCH>
        error(message('MATLAB:xlsread:WorksheetNotFound', Sheet));
    end
    
    % Activate silently fails if the sheet is hidden
    set(TargetSheet, 'Visible','xlSheetVisible');
    % activate worksheet
    Activate(TargetSheet);
end
%--------------------------------------------------------------------------
function a1 = rowCol2A1(row1, col1, row2, col2)
    % Converts row-column notation to Excel A1 notation.
    import matlab.io.spreadsheet.internal.columnLetter;
    a1 = [columnLetter(col1) num2str(row1) ':' columnLetter(col2) num2str(row2)];
end
%--------------------------------------------------------------------------
function rawData = segmentedRead(Excel, rangeObject, numberOfRows)
    % Select the range in Excel so we can see how big it is.
    selectData(Excel, rangeObject);
    selectedRange = Excel.Selection;

    % Get the dimensions of the range
    firstRow = selectedRange.Row;
    firstColumn = selectedRange.Column;
    rowCount = selectedRange.Rows.Count;
    columnCount = selectedRange.Columns.Count;
    lastRow = rowCount + firstRow - 1;
    lastColumn = columnCount + firstColumn - 1;

    rawData = cell(rowCount, columnCount);
    
    % We update these values every iteration
    startRow = firstRow;
    endRow = startRow + numberOfRows - 1;
    
    if endRow > lastRow
        endRow = lastRow;
    end
    
    while startRow <= endRow
        segment = rowCol2A1(startRow, firstColumn, endRow, lastColumn); 
        Select(Range(Excel, segment));
        DataRange = Excel.Selection;
        
        % This code is here to serve the case when we get more rows than we
        % expected when reading a segment.  This happens when the segment
        % ends on merged cells. We add the extra rows to this segment.
        if DataRange.Rows.Count ~= rowCount && DataRange.Rows.Count > numberOfRows
            endRow = DataRange.Rows.Count - numberOfRows + endRow;
            segment = rowCol2A1(startRow, firstColumn, endRow, lastColumn);
            Select(Range(Excel, segment));
            DataRange = Excel.Selection;
        end

        try
            % Subtracting firstRow + 1 normalizes data that doesn't start
            % in the first cell of the spreadsheet.
            rawData((startRow:endRow) - firstRow + 1, :) = ensureIsCell(DataRange.Value);
        catch exception
            if strcmp(exception.identifier, 'MATLAB:COM:E0') || ...
                strcmp(exception.identifier, 'MATLAB:COM:E2147942414')
                % Throw our own exception instead of the COM exception
                error(message('MATLAB:xlsread:SpreadsheetTooLarge'));
            else
                throw(exception);
            end
        end
        
        % Update row and column values for next iteration
        startRow = endRow + 1;
        endRow = startRow + numberOfRows - 1;
        
        if endRow > lastRow
            endRow = lastRow;
        end
    end
end
%--------------------------------------------------------------------------
function [rawData, customOutput] = read(Excel, rangeObject, customFun, numargsin)
    % Select the data in Excel.
    selectData(Excel, rangeObject);
    DataRange = Excel.Selection;
    
    [DataRange, customOutput] = applyCustomFun(numargsin, customFun, DataRange);  
    rawData = ensureIsCell(DataRange.Value);
end
%--------------------------------------------------------------------------
function selectData(Excel, rangeObject)
    % Try using the select method to select the data in Excel. If this
    % fails it is likely because of a scoped named range, so try Goto which
    % handles all named ranges well. We use the Select method first because
    % it is always able to select data in a protected sheet, unlike Goto.
    try
        Select(rangeObject);
    catch exception
        if strcmp(exception.identifier, 'MATLAB:COM:E2148140012')
            % This may be a named range, try Goto
            Excel.Goto(rangeObject);
        else
            % Throw any exceptions we don't expect
            throw(exception);
        end
    end
end
%--------------------------------------------------------------------------
function [DataRange, output] = applyCustomFun(numargsin, customFun, DataRange)
    % Call the custom function if it was given.  Provide customOutput if it
    % is possible.
    output = {};
    if numargsin == 5 && ~isempty(customFun)
        if nargout(customFun) < 2
            DataRange = customFun(DataRange);
        else
            [DataRange, output] = customFun(DataRange);
        end
    end
end
%--------------------------------------------------------------------------
function rawData = ensureIsCell(rawData)
    % Ensure that the rawData is always a cell array.  When DataRange.Value
    % returns only a single value it is returned as a primitive type.
    if ~iscell(rawData)
        rawData = {rawData};
    end
end
