function index = getIndex(rangeType)
    % GETINDEX this function translates the range type coming from the
    % enumeration to an index that can be used for proper array indexing
    % NOTE: this manipulation came up from performance analysis that showed
    % that enumeration classes that derive from basic types are up to 10
    % times slower
    
    % Copyright 2016 The MathWorks, Inc.
    
    switch(rangeType)
        case fxptds.RangeType.Simulation
            index = 1;
        case fxptds.RangeType.Design
            index = 2;
        case fxptds.RangeType.Derived
            index = 3;
        case fxptds.RangeType.CalculatedDerived
            index = 4;
        case fxptds.RangeType.Initial
            index = 5;
        case fxptds.RangeType.ModelRequired
            index = 6;
        case fxptds.RangeType.Mixed
            index = 7;
        otherwise
            % if none of the above, throw error warning for invalid range
            % type
            DAStudio.error('SimulinkFixedPoint:autoscaling:invalidRangeType');
    end
end