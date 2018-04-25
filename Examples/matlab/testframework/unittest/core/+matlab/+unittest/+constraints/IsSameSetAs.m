classdef IsSameSetAs < matlab.unittest.internal.constraints.SubsetSupersetConstraint
    % IsSameSetAs - Constraint specifying a set that contains the same elements as another set
    %
    %   The IsSameSetAs constraint produces a qualification failure for any
    %   actual value that is not the same set as the expected set. An actual
    %   value is considered the same set as the expected set if
    %   ismember(actual,expected) and ismember(expected,actual) both return
    %   arrays that contain all true values and one of the following conditions
    %   is met:
    %       * The actual value and the expected set are of the same class.
    %       * The actual value is an object.
    %       * The expected set is an object.
    %
    %   IsSameSetAs methods:
    %       IsSameSetAs - Class constructor
    %
    %   IsSameSetAs properties:
    %       ExpectedSet - Set to compare to the actual value
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsSameSetAs;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(["b","c","b"], IsSameSetAs(["c","b","c"]));
    %
    %       testCase.fatalAssertThat(zeros(3,4,2), IsSameSetAs(zeros(1,3)));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assertThat({'a';'d'}, IsSameSetAs({'a','b','c'}));
    %
    %       testCase.verifyThat(20:40, IsSameSetAs(25:35));
    %
    %       testCase.assumeThat(single(1:3), IsSubsetOf(1:3));
    %
    %   See also:
    %       ISSUBSETOF
    %       ISSUPERSETOF
    %       ISMEMBER
    
    %  Copyright 2017 The MathWorks, Inc.
    
    properties(Dependent, SetAccess=private)
        % ExpectedSet - Set to compare to the actual value
        ExpectedSet
    end
    
    properties(Hidden,Access=protected)
        Expected
    end
    
    properties(Hidden,Constant,Access=protected)
        Catalog = matlab.internal.Catalog('MATLAB:unittest:IsSameSetAs');
        DoSubsetCheck = true;
        DoSupersetCheck = true;
    end
    
    methods
        function expectedSet = get.ExpectedSet(constraint)
            expectedSet = constraint.Expected;
        end
        
        function constraint = IsSameSetAs(expectedSet)
            % IsSameSetAs - Class constructor
            %
            %   IsSameSetAs(EXPECTEDSET) creates a constraint that determines if a
            %   value is the same set as EXPECTEDSET.
            
            constraint.Expected = expectedSet;
        end
    end
end

% LocalWords:  unittest ISSUBSETOF ISSUPERSETOF EXPECTEDSET
