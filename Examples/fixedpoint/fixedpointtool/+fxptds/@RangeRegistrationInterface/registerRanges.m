function registerRanges(~, dataTypeGroup, result)
    % REGISTERRANGES This function is processing the group member (AbstractResult) and
    % ranges found in the member to the group it belongs to. The class
    % reads the different kinds of range types from the enumeration
    % provided by fxptds.RangeType and probes the incoming member for these
    % ranges. If the member does have any of the ranges, this function uses
    % the public API of the DataTypeGroup class of addRange that assumes
    % the responsibility of accessing the internal infrastrucutre to
    % finalize the consolidation of the incoming ranges
	
    %   Copyright 2016-2017 The MathWorks, Inc.
    
    % get all the types of ranges that are registered in the workflow
    dataTypeGroup.addRange(fxptds.RangeType.Simulation, result.SimMin, result.SimMax);
    dataTypeGroup.addRange(fxptds.RangeType.Design, result.DesignMin, result.DesignMax);
    dataTypeGroup.addRange(fxptds.RangeType.Derived, result.DerivedMin, result.DerivedMax);
    dataTypeGroup.addRange(fxptds.RangeType.Initial, result.InitialValueMin, result.InitialValueMax);
    dataTypeGroup.addRange(fxptds.RangeType.ModelRequired, result.ModelRequiredMin, result.ModelRequiredMax);
end