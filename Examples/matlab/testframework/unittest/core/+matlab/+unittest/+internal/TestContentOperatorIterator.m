classdef TestContentOperatorIterator < handle
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (Access=private)
        Operators;
        CurrentIndex = 1;
    end
    
    properties (Hidden, SetAccess=private)
        HasPlugin = false;
    end
    
    properties (Dependent, SetAccess=private)
        HasNext;
        CurrentOperator;
        LastOperator;
    end
    
    methods
        function iter = TestContentOperatorIterator(operators)
            iter.Operators = operators;
        end
        
        function advance(iter)
            iter.CurrentIndex = iter.CurrentIndex + 1;
        end
        
        function bool = get.HasNext(iter)
            bool = iter.CurrentIndex < numel(iter.Operators);
        end
        
        function operator = get.CurrentOperator(iter)
            operator = iter.Operators(iter.CurrentIndex);
        end
        
        function operator = get.LastOperator(iter)
            operator = iter.Operators(end);
        end
    end
    
    methods (Hidden)
        function addPlugin(iter, plugin)
            iter.HasPlugin = true;
            iter.Operators = [plugin, iter.Operators];
        end
        
        function reset(iter)
            iter.CurrentIndex = 1;
        end
    end
end

