classdef NameAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % NameAttribute - Attribute for TestSuite element name.
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        function attribute = NameAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsName(attribute, selector)
            result = selector.Constraint.satisfiedBy(attribute.Data);
        end
    end
end