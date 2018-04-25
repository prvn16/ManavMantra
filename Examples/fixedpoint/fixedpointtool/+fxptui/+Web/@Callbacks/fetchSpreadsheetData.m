function data = fetchSpreadsheetData(clientMessage)
% FETCHSPREADSHEETDATA Server call made from the JS client to fetch data based on the sort specification, tree selection and range of rows.
    
% Copyright 2017 The MathWorks, Inc.
    
fpt = fxptui.FixedPointTool.getExistingInstance;
if isempty(fpt)
    data = [];
    return;
end
dCtrl = fpt.getDataController;
data = dCtrl.getSpreadsheetData(clientMessage);
dCtrl.setClientMessage(clientMessage);
end
