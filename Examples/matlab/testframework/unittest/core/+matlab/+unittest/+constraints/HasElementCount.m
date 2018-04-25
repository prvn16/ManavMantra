classdef HasElementCount < matlab.unittest.constraints.BooleanConstraint
    % HasElementCount - Constraint specifying an expected number of elements
    %
    %   The HasElementCount constraint produces a qualification failure for
    %   any actual value array that does not have a specified number of
    %   elements.
    %
    %   HasElementCount methods:
    %       HasElementCount - Class constructor
    %
    %   HasElementCount properties:
    %       Count - Number of elements a value must have to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasElementCount;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       n = 7;
    %       testCase.verifyThat(eye(n), HasElementCount(n^2));
    %       testCase.verifyThat({'SomeString', 'SomeOtherString'}, HasElementCount(2));
    %       testCase.verifyThat(3, HasElementCount(1));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat([1 2 3; 4 5 6], HasElementCount(5));
    %       s.Field1 = 1;
    %       s.Field2 = 2;
    %       testCase.verifyThat(s, HasElementCount(2));
    %
    %   See also:
    %       HasLength
    %       HasSize
    %       IsEmpty
    %       IsScalar
    %       numel
    
    %  Copyright 2010-2017 The MathWorks, Inc.

    properties (SetAccess=private)
        % Count - Number of elements a value must have to satisfy the constraint
        Count
    end
    
    
    methods
        function constraint = HasElementCount(count)
            % HasElementCount - Class constructor
            %
            %   HasElementCount(COUNT) creates a constraint that is able to determine
            %   whether an actual value is an array with a number of elements specified
            %   by COUNT.
            
            constraint.Count = count;
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = isequal(numel(actual), constraint.Count);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        function constraint = set.Count(constraint, count)
            validateattributes(                              ...
                count,                                       ...
                {'numeric'},                                 ...
                {'scalar','nonnegative','finite','integer'}, ...
                '', 'count');
            
            constraint.Count = count;
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;

            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Count);
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasElementCount:ExpectedElementCount'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                % Use a sub-diagnostic to report the element count mismatch
                countDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, numel(actual), constraint.Count);
                countDiag.Description = getString(message('MATLAB:unittest:HasElementCount:MustHaveExpectedElementCount'));
                countDiag.ActValHeader = getString(message('MATLAB:unittest:HasElementCount:ActualElementCount'));
                countDiag.ExpValHeader = getString(message('MATLAB:unittest:HasElementCount:ExpectedElementCount'));
                diag.addCondition(countDiag);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Count);
                diag.addCondition(message('MATLAB:unittest:HasElementCount:MustNotHaveUnexpectedElementCount'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasElementCount:UnexpectedElementCount'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Count);
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasElementCount:UnexpectedElementCount'));
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
end