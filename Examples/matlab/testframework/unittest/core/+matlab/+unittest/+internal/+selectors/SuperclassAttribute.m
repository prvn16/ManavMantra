classdef SuperclassAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    
    % This class is undocumented and may change in a future release.
    
    % Copyright 2017 The MathWorks, Inc.
    
    methods
        function attribute = SuperclassAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsSuperclass(attribute, selector)
            result = selector.Constraint.satisfiedBy(attribute.Data);
        end
    end
end