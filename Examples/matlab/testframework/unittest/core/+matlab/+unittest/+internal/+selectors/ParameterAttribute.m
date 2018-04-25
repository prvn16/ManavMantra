classdef ParameterAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % ParameterAttribute - Attribute for TestSuite element parameters.
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods
        function attribute = ParameterAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsParameter(attribute, selector)
            result = false;
            
            for parameter = attribute.Data
                if selector.PropertyConstraint.satisfiedBy(parameter.Property) && ...
                        selector.NameConstraint.satisfiedBy(parameter.Name) && ...
                        selector.ValueConstraint.satisfiedBy(parameter.Value)
                    result = true;
                    break;
                end
            end
        end
    end
end