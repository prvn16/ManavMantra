function messageString = getMessageStringFromState(state)
    % GETMESSAGESTRINGFROMSTATE This function resolves the enumerated type to the proper string
    % representation that can be used to query the fxptui message catalog
    
    % Copyright 2017 The MathWorks, Inc.
    
    switch(state)
        case fxptds.DerivedRangeStates.Default
            messageString = '';
        case fxptds.DerivedRangeStates.InsufficientRangeInterface
            messageString = 'hiliteInportBlk';
        case fxptds.DerivedRangeStates.InsufficientRange
            messageString = 'hiliteBlkwithoutDesign';
        case fxptds.DerivedRangeStates.EmptyIntersection
            messageString = 'hiliteEmptyRange';
        otherwise
            DAStudio.error('SimulinkFixedPoint:autoscaling:invalidDerivedRangeState');
    end
    
end

% LocalWords:  Blkwithout autoscaling
