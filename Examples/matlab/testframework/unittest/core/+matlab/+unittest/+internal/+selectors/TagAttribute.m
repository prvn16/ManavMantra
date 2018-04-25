classdef TagAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % TagAttribute - Attribute for TestSuite element tag.
    
    % Copyright 2014 The MathWorks, Inc.
    
    methods
        function attribute = TagAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsTag(attribute, selector)
            import matlab.unittest.constraints.AnyCellOf;
            
            proxy = AnyCellOf(attribute.Data);
            result = proxy.satisfiedBy(selector.Constraint);
        end
    end
end