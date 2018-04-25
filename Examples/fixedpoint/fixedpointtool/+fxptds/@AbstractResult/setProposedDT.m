function setProposedDT(this, newDT)
%% SETPROPOSEDDT function sets the proposed dt field of the result to newDT
% when newDT is validated. 
% newDT is a char array representing the dt string

% Copyright 2016 The MathWorks, Inc.

    % check if newDT is a valid numeric type
    [isValidDT, evaluatedNumericType] = this.validateProposedDT(newDT);

    % The model could be closed while waiting for a user response.
    % In that case the result object will be invalidated.
    if this.isvalid
        % if newDT was found to be a nuemric type, 
        if isValidDT
            % set proposedDT to stringified version of the numeric type
            this.ProposedDT = evaluatedNumericType.tostring;

            % Cache the value for performance instead of computing on the fly
            this.HasProposedDT = this.hasProposedDT;

            if this.HasProposedDT
                % Turn on the checkbox if the specifiedDT and proposedDT are different.
                this.updateAcceptFlag;
                this.firePropertyChange;
            end
        else
            % if newDT is not valid, but is equivalent of locked / na
            % update proposed dt and accept flag
            if strcmpi(newDT, fxptds.DataTypeStrings.notApplicable) || strcmpi(newDT, fxptds.DataTypeStrings.locked)
                this.ProposedDT = newDT;
                this.updateAcceptFlag;
                this.firePropertyChange;
            end
            % When newDT string is found to be valid, update 'IsLocked'
            % property of the result
            if strcmpi(newDT, fxptds.DataTypeStrings.locked)
                this.IsLocked = true;
            end
        end
    end
end

       