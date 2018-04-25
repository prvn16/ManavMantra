function ValidateProposedDT(clientData)
% VALIDATEPROPOSEDDT Validates the data type inputted by the user.

% Copyright 2016 The MathWorks, Inc.

serverData = clientData;
[b, ~] = fxptds.Utils.validateProposedDT(clientData.newValue);

serverData.isValid = b;
fpt = fxptui.FixedPointTool.getExistingInstance;
fpt.getSpreadsheetController.publishProposedDTValidity(serverData);
if ~b
    if isempty(clientData.newValue)
        fxptui.showdialog('emptyProposedDTError');
    else
        % else show "invalid proposed dt" dialog
        fxptui.showdialog('proposedtinvalid',clientData.newValue);
    end
end

end