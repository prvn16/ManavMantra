function initializeConstraints(this)
    % INITIALIZECONSTRAINTS This function initializes the internal refrence for the group
    % constraints to an empty constraint
	
    %   Copyright 2016 The MathWorks, Inc.
    
    % initialize the reference with an empty abstract constraint
    this.constraints = SimulinkFixedPoint.AutoscalerConstraints.AbstractConstraint.empty;
    
end