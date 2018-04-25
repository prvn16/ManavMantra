classdef IsSubsetOf < matlab.unittest.internal.constraints.SubsetSupersetConstraint
    % IsSubsetOf - Constraint specifying a subset of another set
    %
    %   The IsSubsetOf constraint produces a qualification failure for any
    %   actual value that is not a subset of the expected superset. An actual
    %   value is considered a subset of the expected superset if
    %   ismember(actual,expected) returns an array that contains all true
    %   values and one of the following conditions is met:
    %       * The actual value and the expected superset are of the same class.
    %       * The actual value is an object.
    %       * The expected superset is an object.
    %
    %   IsSubsetOf methods:
    %       IsSubsetOf - Class constructor
    %
    %   IsSubsetOf properties:
    %       Superset - Set that a value must be a subset of to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsSubsetOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat({'c','b'}, IsSubsetOf({'a','b','c'}));
    %
    %       testCase.fatalAssertThat([25;209], IsSubsetOf(magic(21)));
    %
    %       testCase.verifyThat(table([3,1]',{'C';'A'},logical([0;1])),...
    %           IsSubsetOf(table([1:2:5]',{'A';'C';'E'},logical([1;0;0]))));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat({'a';'d'}, IsSubsetOf({'a','b','c'}));
    %
    %       testCase.verifyThat(20:40, IsSubsetOf(25:35));
    %
    %       testCase.assumeThat(single(1:3), IsSubsetOf(0:5));
    %
    %   See also:
    %       ISSUPERSETOF
    %       ISSAMESETAS
    %       ISMEMBER
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Dependent,SetAccess=private)
        % Superset - Set that a value must be a subset of to satisfy the constraint
        Superset
    end
    
    properties(Hidden,Access=protected)
        Expected
    end
    
    properties(Hidden,Constant,Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:IsSubsetOf');
        DoSubsetCheck = true;
        DoSupersetCheck = false;
    end
    
    methods
        function superset = get.Superset(constraint)
            superset = constraint.Expected;
        end
        
        function constraint = IsSubsetOf(expected)
            % IsSubsetOf - Class constructor
            %
            %   IsSubsetOf(EXPECTEDSET) creates a constraint that determines if a value
            %   is a subset of EXPECTEDSET.
            
            constraint.Expected = expected;
        end
    end
end

% LocalWords:  Superset unittest ISSUPERSETOF ISSAMESETAS EXPECTEDSET
