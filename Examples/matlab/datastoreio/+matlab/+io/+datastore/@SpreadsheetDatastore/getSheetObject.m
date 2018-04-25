function sheetObj = getSheetObject(bookObj, sheets)
%GETSHEETOBJECT Returns a sheet object given a book object and the Sheets
%property. The first sheet in sheets is used to make a sheet object

%   Copyright 2015-2016 The MathWorks, Inc.

    % imports
    import matlab.io.internal.validators.isString;    

    % sheets can be a numeric vector, '', string, cellstr
    if isnumeric(sheets)        
        sheetObj = bookObj.getSheet(sheets(1));
    elseif isString(sheets)
        if isempty(sheets)
            sheetObj = bookObj.getSheet(1);
        else
            sheetObj = bookObj.getSheet(sheets);
        end
    else
        sheetObj = bookObj.getSheet(sheets{1});
    end
end
