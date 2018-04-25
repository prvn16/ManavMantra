classdef (Hidden) TeardownDelegate < matlab.mixin.Copyable
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    
    properties(Transient, NonCopyable, Access=private)
        TeardownStack = matlab.unittest.internal.TeardownElement.empty;
    end
    
    methods
        function doAddTeardown(delegate, teardownElement)
            delegate.push(teardownElement);
        end
        
        function doRunAllTeardownThroughProcedure(delegate, procedure)
            while ~delegate.isEmpty()
                teardownElement = delegate.peek();
                delegate.pop();
                teardownElement.teardownThroughProcedure(procedure);
            end
        end
        
        function appendTeardownFrom(delegate, other)
            delegate.TeardownStack = [other.TeardownStack, delegate.TeardownStack];
        end
    end
    
    
    % Stack manipulation methods
    methods (Access=private)
        function push(delegate, teardownElement)
            delegate.TeardownStack = [teardownElement, delegate.TeardownStack];
        end
        
        function bool = isEmpty(delegate)
            bool = isempty(delegate.TeardownStack);
        end
        
        function teardownElement = peek(delegate)
            teardownElement = delegate.TeardownStack(1);
        end
        
        function pop(delegate)
            delegate.TeardownStack(1) = [];
        end
    end
end

