classdef SharedTestFixtureAttribute < matlab.unittest.internal.selectors.SelectionAttribute
    % SharedTestFixtureAttribute - Attribute for TestSuite element shared test fixture.
    
    % Copyright 2013 The MathWorks, Inc.
    
    methods
        function attribute = SharedTestFixtureAttribute(varargin)
            attribute = attribute@matlab.unittest.internal.selectors.SelectionAttribute(varargin{:});
        end
        
        function result = acceptsSharedTestFixture(attribute, selector)
            result = containsEquivalentFixture(attribute.Data, selector.ExpectedFixture);
        end
    end
end