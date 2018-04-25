function unionizedRange = plus(rangeLHS, rangeRHS)
    % This function overloads the + operator for MATLAB in order to provide
    % functionality for seamless unionization of ranges for the class.
    % Every time the user adds two range objects, the resulting object will
    % be a range object that will have as range the union of the extrema of
    % the input ranges and will be of the same type as the input if the two
    % inputs have the same type, or mixed type if the input ranges are not
    % of the same type
    % Copyright 2016 The MathWorks, Inc.
    
    if rangeLHS.type ~= rangeRHS.type
        % if the input ranges have different type, assign type of mixed to the
        % new range
        unionizedRangeType = fxptds.RangeType.Mixed;
    else
        % if the input ranges have the same type, assign it to the new
        % range
        unionizedRangeType = rangeRHS.type;
    end
    
    % the new range will have as range the union of the extrema of the
    % input ranges
    
    % we need to handle cases where one of the extrema is empty
    [minExtremum, maxExtremum] = SimulinkFixedPoint.extractMinMax([...
        rangeLHS.minExtremum ...
        rangeLHS.maxExtremum ...
        rangeRHS.minExtremum ...
        rangeRHS.maxExtremum]);
    
    % create the new unionized range object with the expanded bounds for
    % range
    unionizedRange = fxptds.Range(unionizedRangeType, minExtremum, maxExtremum);
end