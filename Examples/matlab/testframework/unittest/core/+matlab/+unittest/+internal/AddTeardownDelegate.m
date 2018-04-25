classdef (Hidden) AddTeardownDelegate < handle
    % AddTeardownDelegate - a teardown delegate that only supports adding
    % teardown content but not executing it.
    
    %  Copyright 2016 The MathWorks, Inc.
    
    properties (SetAccess=immutable, GetAccess=private)
        TeardownDelegate;
    end
    
    methods
        function delegate = AddTeardownDelegate(otherDelegate)
            delegate.TeardownDelegate = otherDelegate;
        end
        
        function doAddTeardown(delegate, teardownElement)
            delegate.TeardownDelegate.doAddTeardown(teardownElement);
        end
        
        function appendTeardownFrom(delegate, other)
            delegate.TeardownDelegate.appendTeardownFrom(other);
        end
        
        function doRunAllTeardownThroughProcedure(~, ~)
            % Do nothing.
        end
    end
end

