classdef Range < handle
    % Copyright 2016-2017 The MathWorks, Inc.
    properties(SetAccess=private)
        % the type of the range is defined in the enumeration class
        % fxptds.RangeType
        type fxptds.RangeType = fxptds.RangeType.empty()
        minExtremum
        maxExtremum
    end
    
    methods(Access=public)
        function this = Range(rangeType, minExtremum, maxExtremum)
            this.type = rangeType;
            if minExtremum > maxExtremum
                DAStudio.error('SimulinkFixedPoint:autoscaling:invalidRanges');
            end
            this.minExtremum = minExtremum;
            this.maxExtremum = maxExtremum;
        end
        
        % Overloading the plus operator of MATLAB to unionize ranges
        unionizedRange = plus(rangeLHS, rangeRHS);
        
        % Public API to get the extrema of the range as a single vector
        % rather than distinct values
        extrema = getExtrema(this);
        
        appendRange(this, newMinExtremum, newMaxExtremum);
    end
end