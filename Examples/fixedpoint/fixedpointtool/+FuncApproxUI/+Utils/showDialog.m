function showDialog(msgType, varargin)
    % SHOWDIALOG collects the information for the dialog and notifies the
    % client to display it
    
    % Copyright 2017 The MathWorks, Inc.
    
    %define constants
    TYPE_ERROR = FuncApproxUI.Utils.Dialogs.Error;
    TYPE_WARNING = FuncApproxUI.Utils.Dialogs.Warning;
    msgObj = {};
    dlgType = TYPE_ERROR;
    [msgObj.Title, msgObj.Message] = FuncApproxUI.Utils.getDialogDetails(msgType);
    
    switch nargin
        % In this case, we get the dialog title and message from the
        % exception thrown by the CLI
        case 2
            e = varargin{1};
            msgObj.Message = e.message;
            % In this case, we get the dialog title and message from the
            % exception thrown by the CLI and the dialog type from the caller.
        case 3
            e = varargin{1};
            msgObj.Message = e.message;
            dlgType = varargin{2};                    
    end
    
    lutInstance = FuncApproxUI.Wizard.getExistingInstance;
    lutCtrl = lutInstance.getWizardController;
    msgServiceInterface = lutCtrl.getMsgServiceInterface();
    
    %if we're calling showdialog from MATLAB and not the UI make sure we show
    %the dialogs
    switch dlgType
        case TYPE_ERROR
            msgServiceInterface.publish('/FuncApproxUI/dialog/error', msgObj);
        case TYPE_WARNING
            msgServiceInterface.publish('/FuncApproxUI/dialog/warning', msgObj);
    end
end

% LocalWords:  Func
