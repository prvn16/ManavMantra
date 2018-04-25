classdef BaseFolderAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % BaseFolderAttribute - Attribute for TestSuite element defining folder.
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        function attribute = BaseFolderAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsBaseFolder(attribute, selector)
            result = selector.Constraint.satisfiedBy(attribute.Data);
        end
    end
end