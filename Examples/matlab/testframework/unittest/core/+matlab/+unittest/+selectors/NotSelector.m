classdef (Sealed) NotSelector < matlab.unittest.internal.selectors.Selector
    % NotSelector - Boolean complement of a selector.
    %   A NotSelector is produced when the "~" operator is used to denote the
    %   complement of a selector.
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Selector - The selector that is being complemented.
        Selector (1,1) matlab.unittest.internal.selectors.Selector = ...
            matlab.unittest.internal.selectors.NeverFilterSelector;
    end
    
    methods (Access=?matlab.unittest.internal.selectors.Selector)
        function notSelector = NotSelector(selector)
            notSelector.Selector = selector;
        end
    end
    
    methods (Sealed)
        function notNotSelector = not(notSelector)
            notNotSelector = notSelector.Selector;
        end
    end
    
    methods (Hidden)
        function bool = uses(selector, attributeClass)
            bool = selector.Selector.uses(attributeClass);
        end
        
        function result = select(selector, attributes)
            result = ~selector.Selector.select(attributes);
        end
        
        function bool = reject(selector, attributes)
            bool = selector.Selector.negatedReject(attributes);
        end
    end
end

