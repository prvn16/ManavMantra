function extremumSet = getExtremaSim(this, SafetyMarginForSimMinMax)
    % This function inflates the simulation range of a result based on the
    % safety margin that was provided by the user. This function is capable
    % of handling ranges of real numbers as well as complex number ranges.
    %   Copyright 2016 The MathWorks, Inc.
	% calculate the range factor from the safety margin
    rangeFactorSim = this.SafetyMargin2RangeFactor(SafetyMarginForSimMinMax);
    
    % if the simulation ranges are in proper order we need to apply the
    % safety margin in order to get a proposal that will honor the safety
    % margin
    if this.SimMin <= this.SimMax
        scaleSimMin = this.SimMin * rangeFactorSim;
        scaleSimMax = this.SimMax * rangeFactorSim;
        
        % unionize the extrema of the simulation range
        extremumSet = SimulinkFixedPoint.AutoscalerUtils.unionRange( scaleSimMin, scaleSimMax);
        
        % if the minimum value equals the maximum value, return a single
        % value, not a range (vector)
        extremumSet = this.combineIFsame(extremumSet);
    else
        % if the simulation ranges are not in proper order, the extremum
        % will be empty
        extremumSet = []; % system does not execute
    end
end