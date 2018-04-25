classdef (Sealed) OrSelector < matlab.unittest.internal.selectors.Selector
    % OrSelector - Boolean disjunction of two selectors.
    %   An OrSelector is produced when the "|" operator is used to denote the
    %   disjunction of two selectors.
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % FirstSelector - The left selector that is being OR'ed.
        FirstSelector (1,1) matlab.unittest.internal.selectors.Selector = ...
            matlab.unittest.internal.selectors.NeverFilterSelector;
        
        % SecondSelector - The right selector that is being OR'ed.
        SecondSelector (1,1) matlab.unittest.internal.selectors.Selector = ...
            matlab.unittest.internal.selectors.NeverFilterSelector;
    end
    
    methods (Access=?matlab.unittest.internal.selectors.Selector)
        function orSelector = OrSelector(firstSelector, secondSelector)
            orSelector.FirstSelector = firstSelector;
            orSelector.SecondSelector = secondSelector;
        end
    end
    
    methods (Sealed)
        function notSelector = not(orSelector)
            notSelector = ~orSelector.FirstSelector & ~orSelector.SecondSelector;
        end
    end
    
    methods (Hidden)
        function bool = uses(selector, attributeClass)
            bool = selector.FirstSelector.uses(attributeClass) || ...
                selector.SecondSelector.uses(attributeClass);
        end
        
        function result = select(selector, attributes)
            result = selector.FirstSelector.select(attributes) || ...
                selector.SecondSelector.select(attributes);
        end
        
        function bool = reject(selector, attributes)
            bool = selector.FirstSelector.reject(attributes) && ...
                selector.SecondSelector.reject(attributes);
        end
    end
end

% LocalWords:  OR'ed
