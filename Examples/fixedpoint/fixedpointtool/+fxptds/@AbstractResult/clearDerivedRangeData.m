function clearDerivedRangeData(this)
    % CLEARDERIVEDRANGEDATA clears the information collected for range analysis
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    this.DerivedMin = [];
    this.DerivedMax = [];
    this.CompiledDesignMin = [];
    this.CompiledDesignMax = [];
    this.DerivedRangeState = fxptds.DerivedRangeStates.Unknown;
    this.HasDerivedMinMax = false;
end
