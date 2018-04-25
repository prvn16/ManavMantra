classdef (Sealed) HasSharedTestFixture < matlab.unittest.internal.selectors.SingleAttributeSelector
    % HasSharedTestFixture - Select TestSuite elements that use a shared test fixture.
    %
    %   The HasSharedTestFixture selector filters TestSuite array elements
    %   based on the shared test fixtures used.
    %
    %   HasSharedTestFixture methods:
    %       HasSharedTestFixture - Class constructor
    %
    %   HasSharedTestFixture properties:
    %       ExpectedFixture - Shared test fixture that must be used.
    %
    %   Examples:
    %
    %       import matlab.unittest.selectors.HasSharedTestFixture;
    %       import matlab.unittest.fixtures.PathFixture;
    %       import matlab.unittest.fixtures.CurrentFolderFixture;
    %
    %       % Create a TestSuite to filter
    %       suite = TestSuite.fromPackage('mypackage');
    %
    %       % Select TestSuite array elements that use a PathFixture.
    %       newSuite = suite.selectIf(HasSharedTestFixture(PathFixture('helpers')));
    %
    %       % Select TestSuite array elements that do not use a PathFixture but
    %       % do use a CurrentFolderFixture.
    %       newSuite = suite.selectIf(~HasSharedTestFixture(PathFixture('helpers')) & ...
    %           HasSharedTestFixture(CurrentFolderFixture));
    %
    %   See also: matlab.unittest.TestSuite/selectIf
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % ExpectedFixture - Shared test fixture that must be used.
        %
        %   The ExpectedFixture property is a matlab.unittest.fixtures.Fixture
        %   instance which specifies the shared test fixture that must be used by a
        %   TestSuite array element in order to be retained.
        ExpectedFixture (1,1) matlab.unittest.fixtures.Fixture = ...
            matlab.unittest.fixtures.EmptyFixture;
    end
    
    properties (Constant, Hidden, Access=protected)
        AttributeClassName char = 'matlab.unittest.internal.selectors.SharedTestFixtureAttribute';
        AttributeAcceptMethodName char = 'acceptsSharedTestFixture';
    end
    
    methods
        function selector = HasSharedTestFixture(fixture)
            % HasSharedTestFixture - Class constructor
            %
            %   selector = HasSharedTestFixture(FIXTURE) creates a selector that
            %   filters TestSuite array elements based on the fixtures used. FIXTURE
            %   can be any matlab.unittest.fixtures.Fixture instance. A TestSuite array
            %   element must use the specified fixture in order to be retained.
            
            selector.ExpectedFixture = fixture;
        end
    end
end

% LocalWords:  mypackage
