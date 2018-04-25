function [theMessage, description, format] = xlsfinfoCOM(Excel, filename)
    % xlsfinfoCOM is the COM implementation of xlsfinfo.
    %   [theMessage, description, format] = xlsfinfoCOM(Excel, filename)
    %   gets the format from the specified Excel object.
    %
    %   See also XLSREAD, XLSWRITE, XLSFINFO.
    
    %   Copyright 1984-2015 The MathWorks, Inc.
    
    % Open Excel workbook.
    readOnly = true;
    [format, workbookHandle, workbookState] = openExcelWorkbook(Excel, filename, readOnly);
    c = onCleanup(@()xlsCleanup(Excel,filename,workbookState));
    
    % Walk through sheets in workbook and pick out worksheets (not Charts e.g.).
    theMessage = 'Microsoft Excel Spreadsheet';
    % Initialise worksheets object.
    workSheets = workbookHandle.Worksheets;
    description = cell(1,workSheets.Count);
    for idx = 1:workSheets.Count
        sheet = get(workSheets,'item',idx);
        description{idx} = sheet.Name;
    end
end