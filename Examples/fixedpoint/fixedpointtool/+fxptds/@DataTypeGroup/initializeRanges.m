function initializeRanges(this)
    % INITIALIZERANGES This function initializes the internal list of ranges. We use the
    % enumeration of fxptds.RangeType and read all the enumerated ranges to
    % populate the list
	
    %   Copyright 2016 The MathWorks, Inc.
    
    % read the enumeration to get all the kinds of ranges
    allRangeTypes = enumeration('fxptds.RangeType');
    
    % initialize a cell array of ranges
    this.ranges = cell(length(allRangeTypes), 1);
    
    % for every kind of ranges, initialize an empty range object
    for indx = 1:length(this.ranges)
        this.ranges{indx} = fxptds.Range(allRangeTypes(indx), [], []);
    end
end