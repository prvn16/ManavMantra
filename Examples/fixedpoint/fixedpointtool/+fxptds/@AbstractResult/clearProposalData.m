function clearProposalData(this)
    % CLEARPROPOSEDDTDATA clears proposal related data
    
    % Copyright 2012-2016 The MathWorks, Inc.
    
    this.ProposedDT = '';
    this.DTGroup = '';
    this.LocalExtremumSet = [];
    this.Accept = false;
    this.Comments = {};
    this.Alert = '';
    this.DTConstraints = {};
    this.IsLocked = false;
    this.HasProposedDT = false;
    this.HasAlert = false;
    this.DesignMin = [];
    this.DesignMax = [];
    this.HasDesignMinMax = false;
    this.SpecifiedDT = '';
    this.HasSpecifiedDT  = false;
    this.SpecifiedDTContainerInfo = SimulinkFixedPoint.DTContainerInfo('',[]);
    this.IsReferredByOtherActualSourceID = false;
    this.IsInheritanceReplaceable = false;
    this.InitialValueMin = [];
    this.InitialValueMax = [];
    this.ModelRequiredMin = [];
    this.ModelRequiredMax = [];    
end
