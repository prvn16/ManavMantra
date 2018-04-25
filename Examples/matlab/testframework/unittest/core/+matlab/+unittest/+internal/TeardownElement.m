classdef TeardownElement
    
    % Copyright 2013 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        Function;
        Arguments;
    end
    
    methods
        function element = TeardownElement(fcn, args)
            element.Function = fcn;
            element.Arguments = args;
        end
    end
    
    methods
        function teardownThroughProcedure(teardownElement, procedure)
            procedure(teardownElement.Function, teardownElement.Arguments{:});
        end
    end
end