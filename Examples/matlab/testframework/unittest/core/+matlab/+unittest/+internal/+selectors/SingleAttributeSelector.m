classdef(Hidden) SingleAttributeSelector < matlab.unittest.internal.selectors.Selector
    % This class is undocumented and may change in a future release.
    
    % SingleAttributeSelector - Selector that uses only one attribute.
    %
    %   The SingleAttributeSelector implements the Selector interface for a
    %   selector that uses only one attribute and can therefore definitively
    %   reject a suite element based on a subset of attributes by returning
    %   false from the select method. Selectors that use multiple attributes
    %   (e.g., AndSelector, OrSelector, NotSelector) cannot use this interface
    %   because they cannot definitely reject a suite element by returning
    %   false from the select method. For selectors that use multiple
    %   attributes, the presence of additional attributes can change the result
    %   of select from false to true.
    
    %  Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Abstract, Constant, Hidden, Access=protected)
        % AttributeClassName - Name of the attribute class the selector uses
        AttributeClassName char;
        
        % AttributeAcceptMethodName - Name of the attribute method the selector
        %   uses to make a selection determination.
        AttributeAcceptMethodName char;
    end
    
    methods (Sealed)
        function notSelector = not(selector)
            import matlab.unittest.selectors.NotSelector;
            notSelector = NotSelector(selector);
        end
    end
    
    methods (Hidden, Sealed)
        function bool = uses(selector, attributeClass)
            bool = attributeClass <= meta.class.fromName(selector.AttributeClassName);
        end
        
        function bool = select(selector, attributes)
            for currentAttribute = attributes
                if ~currentAttribute.(selector.AttributeAcceptMethodName)(selector)
                    bool = false;
                    return;
                end
            end
            
            bool = true;
        end
        
        function bool = reject(selector, attributes)
            bool = ~selector.select(attributes);
        end
        
        function bool = negatedReject(selector, attributes)
            bool = selector.usesAnyOf(attributes) && selector.select(attributes);
        end
    end
    
    methods (Access=private)
        function bool = usesAnyOf(selector, attributes)
            bool = any(arrayfun(@(attr)selector.uses(metaclass(attr)), attributes));
        end
    end
end

