classdef Rejected < matlab.uiautomation.internal.dispatchstate.Settled
    % This class is undocumented and subject to change in a future release
    
    % Copyright 2016-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        Exception
    end
    
    methods
        
        function state = Rejected(exception)
            state.Exception = exception;
        end
        
        function resolve(state)
            throwAsCaller(state.Exception);
        end
        
    end
    
end