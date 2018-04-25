classdef IsSupersetOf < matlab.unittest.internal.constraints.SubsetSupersetConstraint
    % IsSupersetOf - Constraint specifying a superset of another set
    %
    %   The IsSupersetOf constraint produces a qualification failure for any
    %   actual value that is not a superset of the expected subset. An actual
    %   value is considered a superset of the expected subset if
    %   ismember(expected,actual) returns an array that contains all true
    %   values and one of the following conditions is met:
    %       * The actual value and the expected subset are of the same class.
    %       * The actual value is an object.
    %       * The expected subset is an object.
    %
    %   IsSupersetOf methods:
    %       IsSupersetOf - Class constructor
    %
    %   IsSupersetOf properties:
    %       Subset - Set that a value must be a superset of to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsSupersetOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat({'a','b','c'}, IsSupersetOf({'c';'b'}));
    %
    %       testCase.fatalAssertThat(magic(21), IsSupersetOf([25;209]));
    %
    %       testCase.verifyThat(table([1:2:5]',{'A';'C';'E'},logical([1;0;0])),...
    %           IsSupersetOf(table([3,1]',{'C';'A'},logical([0;1]))));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat({'a','b','c'}, IsSupersetOf({'a','d'}));
    %
    %       testCase.verifyThat(25:35, IsSupersetOf(20:40));
    %
    %       testCase.assumeThat(single(0:5), IsSupersetOf(1:3));
    %
    %   See also:
    %       ISSUBSETOF
    %       ISSAMESETAS
    %       ISMEMBER
    
    %  Copyright 2015-2017 The MathWorks, Inc.
    
    properties(Dependent,SetAccess=private)
        % Subset - Set that a value must be a superset of to satisfy the constraint
        Subset
    end
    
    properties(Hidden,Access=protected)
        Expected
    end
    
    properties(Hidden,Constant,Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:IsSupersetOf');
        DoSubsetCheck = false;
        DoSupersetCheck = true;
    end
    
    methods
        function subset = get.Subset(constraint)
            subset = constraint.Expected;
        end
        
        function constraint = IsSupersetOf(expected)
            % IsSupersetOf - Class constructor
            %
            %   IsSupersetOf(EXPECTEDSET) creates a constraint that determines if a
            %   value is a superset of EXPECTEDSET.
            
            constraint.Expected = expected;
        end
    end
end

% LocalWords:  superset unittest ISSUBSETOF ISSAMESETAS EXPECTEDSET
