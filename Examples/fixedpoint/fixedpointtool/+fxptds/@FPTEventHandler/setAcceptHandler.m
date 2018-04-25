function setAcceptHandler(this, eventSrc, eventData)
%% SETACCEPTHANDLER   function changes accept value of a result
% Function prompts "ProposedDT Edit Warning" dialog if a result belongs to
% a group, prompting user to change all or none.
%  
% eventSrc is an instance of fxptds.AbstractResult
%
% eventData is an instance of events.EventData

    %   Copyright 2016 The MathWorks, Inc.
    
    acceptDTValue = eventData.AcceptDTValue;
    
    if eventSrc.hasDTGroup 
        % Invoke UI Handler
        changeGroup = this.GUIHandler.promptChangeGroupDialog();
        if(changeGroup)
            this.ResultHandler.setAcceptForGroup(eventSrc, acceptDTValue);
        end
    else
        % If its an Individual MLVarResult (w/o a DT Group), we will have
        % to uncheck / check other results within the MLFB that this result
        % belongs to, so, pop up "Change All / None" dialog.
        if this.isMLFBHandler
            % Invoke UI Handler
            changeGroup = this.GUIHandler.promptChangeGroupDialog();
            % if "Change All" is chosen, set accept for this result and all
            % other results within the MLFB.
            if (changeGroup)
                this.ResultHandler.setAccept(eventSrc, acceptDTValue);
            end
        else
            % If the result object associated with this FPTEventHandler
            % instance is not a MLVarResult, just set Accept flag to the
            % user given value.
            this.ResultHandler.setAccept(eventSrc, acceptDTValue);
        end       
    end
    this.GUIHandler.updateUI(eventSrc);
    
end