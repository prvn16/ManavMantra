function UpdateOnDataChanged(clientDataChanged)
% UPDATEONDATACHANGED Updates the sever based on changes made to the client

% Copyright 2016 The MathWorks, Inc.

result = fxptui.ScopingTableUtil.getResultForClientResultID(clientDataChanged.id);
switch clientDataChanged.property
    case 'Run'
            h = fxptui.Web.RunNameChangeHandler;
            h.processChange(clientDataChanged)
    case 'ProposedDT'       
        h = fxptui.Web.ProposedDTChangeHandler(result);
        h.processChange(clientDataChanged)
    case 'Accept'
          h = fxptui.Web.ApplyChangeHandler(result);
          h.processChange(clientDataChanged)
end
end
