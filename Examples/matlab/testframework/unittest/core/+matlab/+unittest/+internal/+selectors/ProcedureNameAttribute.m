classdef ProcedureNameAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % ProcedureNameAttribute - Attribute for TestSuite element's procedure name.
    
    % Copyright 2016 The MathWorks, Inc.
    
    methods
        function attribute = ProcedureNameAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsProcedureName(attribute, selector)
            result = selector.Constraint.satisfiedBy(attribute.Data);
        end
    end
end