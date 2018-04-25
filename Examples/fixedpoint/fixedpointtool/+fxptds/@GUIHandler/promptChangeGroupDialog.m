function retValue = promptChangeGroupDialog(~)
%% PROMPTCHANGEGROUPDIALOG function shows "ProposedDT edit warning" dialog 
% prompting user to change all or none of the results that share the same
% data type

%   Copyright 2016 The MathWorks, Inc.

    persistent BTN_CHANGE_ALL
    BTN_CHANGE_ALL = fxptui.message('btnProposedDTsharedChangeAll');

    % invoke ChangeAll dialog
    btn = fxptui.showdialog('proposedtsharedwarning', '');

    % Set retValue depending upon whether user chose "ChangeAll" or "None"
    retValue = false;
    if ~isempty(btn)
        % Set retValue to true if ChangeAll is chosen
        % otherwise set to false
        switch btn
          case BTN_CHANGE_ALL
            retValue = true;
          otherwise
              
            retValue = false;
        end
    end
end