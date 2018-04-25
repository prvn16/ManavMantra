function [DataRange, rawDataWithDatesAsNumbers] = convertSpreadsheetDates(DataRange)
% convertSpreadsheetDates  Convert cells in a spreadsheet to MATLAB datenum format
%
% convertSpreadsheetDates converts cells in a Microsoft Excel spreadsheet file
% containing date formatted values to MATLAB numeric datenum format.
%
% To convert cells containing date formatted cells, pass a function handle to
% convertSpreadsheetDates to xlsread.  This call to xlsread will generate a
% fourth output, which is a cell array containing the raw data from the
% Excel spreadsheet with any values stored as Excel dates converted to
% MATLAB datenums.
%
% convertSpreadsheetDates can only be used as a custom function input to
% xlsread.  It should not be called directly.
%
% Supported only on Windows systems with Excel software

%   Copyright 2011-2012 The MathWorks, Inc.



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

% Dates are stored differently in Value and Value2.  Use this difference to
% find cells containing dates.
isDate = ~cellfun(@isequaln,rawDataWithDatesAsString,rawDataWithDatesAsNumbers);

% Numeric representation of dates in Excel are based on a different pivot
% year from numeric representation of dates in MATLAB. Correct for this
% offset.
if DataRange.Worksheet.Parent.Date1904
    datenumOffset = 695422;
else  
    datenumOffset = 693960;
end
rawDataWithDatesAsNumbers(isDate) = cellfun( @(x) x + datenumOffset,...
    rawDataWithDatesAsNumbers(isDate),'UniformOutput',false);


