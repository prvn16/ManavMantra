function addConstraints(this, dataTypeConstraints)
    % ADDCONSTRAINTS This function is the public API of the data type group that processes
    % incoming constraints that are being registered externally. At any
    % given time, the group holds a single consolidated constraint that
    % accounts for all the different constraints that the members may have
    
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    %consolidate the incoming constraint with the existing one
    this.constraints = this.constraints + dataTypeConstraints;
end