classdef DerivedRangeStates < uint8
    % DerivedRangeStates enumeration lists all possible Derived Range
    % states. Result objects are assigned Unknown state to start and are
    % then assigned the default state once a result object is updated.
    
    %   Copyright 2017 The MathWorks, Inc.
    
    enumeration
        Default                      (1)
        InsufficientRangeInterface   (2)
        InsufficientRange            (3)
        EmptyIntersection            (4)
        Unknown                      (5)
    end
    methods(Static)
        messageString = getMessageStringFromState(state);
    end
end