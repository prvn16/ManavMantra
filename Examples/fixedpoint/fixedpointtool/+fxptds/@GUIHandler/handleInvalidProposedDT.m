function handleInvalidProposedDT(~, proposedDT)
%% HANDLEINVALIDPROPOSEDDT function throws a GUI dialog indicating the proposedDT is invalid

%   Copyright 2016 The MathWorks, Inc.

    % if proposedDT is not a string, error out 
    if ~ischar(proposedDT)
        [msg, id] = fxptui.message('incorrectInputType','char',class(proposedDT));
        throw(MException(id, msg));
    end
    % if proposed dt is empty, show "empty proposeddt" error dialog
    if isempty(proposedDT)
        fxptui.showdialog('emptyProposedDTError');
    else
        % else show "invalid proposed dt" dialog
        fxptui.showdialog('proposedtinvalid', proposedDT);
    end
end
