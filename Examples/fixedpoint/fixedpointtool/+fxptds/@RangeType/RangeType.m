classdef RangeType
    % This is an enumeration class to register all the ranges that are
    % necessary in the data typing workflow. Currently the infrastructure
    % is supporting six ranges: simulation ranges, design ranges, ranges
    % related to derived range workflow (derived ranges and calculated
    % derived ranges), initial ranges and model required ranges. 
    % Copyright 2016 The MathWorks, Inc.
    
    enumeration
        Simulation      
        Design
        Derived
        CalculatedDerived
        Initial
        ModelRequired
        Mixed
    end
    
    methods(Static)
        rangeTypeString = getString(rangeType);
        index = getIndex(rangeType);
    end
end