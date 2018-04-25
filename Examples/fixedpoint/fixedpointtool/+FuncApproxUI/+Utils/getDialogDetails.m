function [title, msg] = getDialogDetails(id)
    % GETMESSAGE retrieves the title and display message from the resource
    % catalog for a given id
    
    % Copyright 2017 The MathWorks, Inc.
    
    titleID = strcat(id,'Title');
    title = FuncApproxUI.Utils.lookuptableMessage(titleID);
    msgID = strcat(id,'Msg');
    msg = FuncApproxUI.Utils.lookuptableMessage(msgID);
end

