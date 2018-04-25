function stringRangeType = getString(rangeType)
    % This function is placing the role of an interface between the
    % definition of the ranges as an enumeration and the actual property
    % names defined in the AbstractResults hierarchy.
    
    % Copyright 2016-2017 The MathWorks, Inc.
    switch(rangeType)
        % case of calculated ranges
        case fxptds.RangeType.CalculatedDerived
            stringRangeType = 'CalcDerived';
            % case of derived ranges
        case fxptds.RangeType.Derived
            stringRangeType = 'Derived';
            % case of design ranges
        case fxptds.RangeType.Design
            stringRangeType = 'Design';
            % case of initial ranges
        case fxptds.RangeType.Initial
            stringRangeType = 'InitialValue';
            % case of unionized ranges of different types, the final range
            % type will be reported as mixed
        case fxptds.RangeType.ModelRequired
            stringRangeType = 'ModelRequired';
            % case of simulation ranges
        case fxptds.RangeType.Simulation
            stringRangeType = 'Sim';
        otherwise
            % if none of the above, throw error warning for invalid range
            % type
            DAStudio.error('SimulinkFixedPoint:autoscaling:invalidRangeType');
    end
    
end