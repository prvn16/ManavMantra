function addRange(this, rangeType, newMinExtremum, newMaxExtremum)
    % ADDRANGE This function provides a public API to register member ranges. We
    % keep a detailed list of all different types of ranges that are
    % available in the data typing workflow and we consolidate each one
    % separately. When asked about the final unionized range, we
    % consolidate all the unionized ranges.
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    
    this.ranges{fxptds.RangeType.getIndex(rangeType)}.appendRange(newMinExtremum, newMaxExtremum);
end