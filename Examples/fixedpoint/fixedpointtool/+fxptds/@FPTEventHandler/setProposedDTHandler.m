function setProposedDTHandler(this, eventSrc, eventData)
%% SETPROPOSEDDTHANDLER function changes proposedDT of a result
% Function prompts "ProposedDT Edit Warning" dialog if a result belongs to
% a group, prompting user to change all or none.
% On user choosing "change all" , applies the edited proposed dt to all
% results in the dtgroup if result belongs to one.
%
% eventSrc is an instance of fxptds.AbstractResult
%
% eventData is an instance of events.EventData

%   Copyright 2016 The MathWorks, Inc.

    % get proposedDT string from eventData
    proposedDTValue = eventData.ProposedDTValue;

    % check if proposedDT string is in valid format
    isValid = fxptds.Utils.validateProposedDT(proposedDTValue);

    % if proposedDTString is valid or maps to either n/a or locked
    if isValid || strcmpi(proposedDTValue, fxptds.DataTypeStrings.notApplicable) || strcmpi(proposedDTValue, fxptds.DataTypeStrings.locked)
        % NOTE: isReadOnly is a hack to identify results in top model
        % context dataset vs. model block dataset
        % All results in top model context have isReadOnly as false
        % All results in model block's (sub model) dataset have isReadOnly
        % property set to true.
        % By design, one can change proposed DT for results in top model
        % datasets only (model reference datasets).
        % For every proposedD change in the UI,
        % backend logic is to additionally reflect on the changed proposed
        % dt and regenerate alerts and update proposed dt for the result
        % across all model reference datasets.
        % When a result is readOnly and user changes the proposed DT from
        % GUI, non of the alert generation / model block updates take
        % place.
        updateModelBlocksAndAlerts = false;
        % If result is editable
        if ~eventSrc.isReadOnly
            updateModelBlocksAndAlerts = true;
        end

        % Update context of result handler in terms of proposal settings and
        % datasets
        this.updateResultHandler(eventSrc);

        % If result belongs to a dt group & editable
        if eventSrc.hasDTGroup && updateModelBlocksAndAlerts
            % Invoke UI Handler
            changeGroup = this.GUIHandler.promptChangeGroupDialog();

            % if change group prompted by user, change all results in a
            % group
            if(changeGroup)
                this.ResultHandler.setProposedDTForGroup(eventSrc, proposedDTValue);           
            end
        else
           % Update individual result with proposed dt (in both editable
           % and non editable cases)
            this.ResultHandler.setProposedDT(eventSrc, proposedDTValue, updateModelBlocksAndAlerts);
        end
        this.GUIHandler.updateUI(eventSrc);
    else
        % handle invalid proposed dt by throwing a dialog in GUI
        this.GUIHandler.handleInvalidProposedDT(proposedDTValue);
    end
end
