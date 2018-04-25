function [DataRange, rawDataWithDatesAsNumbers] = convertSpreadsheetExcelDates(DataRange)
    % convertSpreadsheetDatetimes  Convert cells in a spreadsheet to MATLAB
    % datetime format
    %
    % convertSpreadsheetDatetimes converts cells in a Microsoft Excel
    % spreadsheet file containing date formatted values to MATLAB numeric
    % datetime format.
    %
    % To convert cells containing date formatted cells, pass a function
    % handle to convertSpreadsheetDatetimes to xlsread.  This call to
    % xlsread will generate a fourth output, which is a cell array
    % containing the raw data from the Excel spreadsheet with any values
    % stored as Excel dates converted to MATLAB datenums.
    %
    % convertSpreadsheetDatetimes can only be used as a custom function
    % input to xlsread.  It should not be called directly.
    %
    % Supported only on Windows systems with Excel software
    
    %   Copyright 2013-2015 The MathWorks, Inc.
        

    % Value and Value2 both store the underlying value of cells in an Excel
    % spreadsheet.
    rawDataWithDatesAsString = DataRange.Value;
    rawDataWithDatesAsNumbers = DataRange.Value2;
    
    % The COM client may return scalar cells as numeric rather than cell
    % arrays. In this case, convert to cell arrays.
    if ~iscell(rawDataWithDatesAsNumbers)
        rawDataWithDatesAsNumbers = {rawDataWithDatesAsNumbers};
    end
    if ~iscell(rawDataWithDatesAsString)
        rawDataWithDatesAsString = {rawDataWithDatesAsString};
    end
    
    is1904 = DataRange.Worksheet.Parent.Date1904;
    s = size(rawDataWithDatesAsString);
    for row = 1:s(1)
        for col = 1:s(2)
            strCell = rawDataWithDatesAsString{row,col};
            
            % Dates are stored differently in Value and Value2.  Use this
            % difference to find cells containing dates.
            isDate = ~isequaln(strCell, rawDataWithDatesAsNumbers{row,col});
            if ~isDate
                % Replace any values which are not dates with a string
                % which won't be recognized by the datetime constructor
                rawDataWithDatesAsNumbers{row,col} = 'NaN';
            end
            
            if isnumeric(strCell) && isnan(strCell)
                % Set nans to empty strings
                rawDataWithDatesAsNumbers{row,col} = '';
            end
            if isnumeric(rawDataWithDatesAsNumbers{row,col})
                if rawDataWithDatesAsNumbers{row,col} < 0
                    % Replace any negative numeric values with NaN.
                    % Negative date values are considered errors in Excel,
                    % and the datetime constructor does not support them.
                    rawDataWithDatesAsNumbers{row,col} = nan;
                elseif is1904
                    % Numeric representation of dates in Excel are based on
                    % a different pivot year from numeric representation of
                    % dates in MATLAB. Correct for this offset.
                    rawDataWithDatesAsNumbers{row,col} = ...
                        rawDataWithDatesAsNumbers{row,col} + 1462;
                end
            end
        end
    end
end
