function clearProposalData(this)
    % CLEARPROPOSEDDTDATA clears proposal related data
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    clearProposalData@fxptds.AbstractResult(this);    
    this.ActualSourceIDs = {};
    this.HasSupportingMinMax = false;
    this.ActualSourceIDs=[];
end
