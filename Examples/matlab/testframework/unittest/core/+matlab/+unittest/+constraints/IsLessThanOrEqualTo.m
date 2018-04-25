classdef IsLessThanOrEqualTo < matlab.unittest.internal.constraints.CombinableConstraint
    % IsLessThanOrEqualTo - Constraint specifying a value less than or equal to another value
    %
    %   The IsLessThanOrEqualTo constraint produces a qualification failure for any
    %   actual value array that is not less than or equal to a specified ceiling value.
    %
    %   IsLessThanOrEqualTo methods:
    %       IsLessThanOrEqualTo - Class constructor
    %
    %   IsLessThanOrEqualTo properties:
    %       CeilingValue - The maximum value to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsLessThanOrEqualTo;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(2, IsLessThanOrEqualTo(3));
    %       testCase.assertThat(3, IsLessThanOrEqualTo(3));
    %       testCase.assumeThat([5 2 7], IsLessThanOrEqualTo(7));
    %       testCase.verifyThat([5 -3 2], IsLessThanOrEqualTo([5 -3 8]));
    %       testCase.assertThat(eye(2), IsLessThanOrEqualTo(eye(2)));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(9, IsLessThanOrEqualTo(5));
    %       testCase.verifyThat([1 2 3; 4 5 6], IsLessThanOrEqualTo(4));
    %
    %   See also:
    %       IsLessThan
    %       IsGreaterThan
    %       IsGreaterThanOrEqualTo
    %       le
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % CeilingValue - The maximum value to satisfy the constraint
        CeilingValue
    end
    
    methods
        function constraint = IsLessThanOrEqualTo(ceiling)
            % IsLessThanOrEqualTo - Class constructor
            %
            %   IsLessThanOrEqualTo(CEILING) creates a constraint that is able to
            %   determine whether an actual value is an array which is less than or
            %   equal to CEILING.  The actual value is determined to be less than the
            %   CEILING if and only if all the elements of the inequality hold true
            %   according to MATLAB's LE function, or equivalently when all(actual <=
            %   CEILING) is true.
            
            if isempty(ceiling)
                error(message('MATLAB:unittest:IsLessThanOrEqualTo:ExpectedNonEmptyMaximum'));
            end
            constraint.CeilingValue = ceiling;
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            mask = actual <= constraint.CeilingValue;
            tf = ~isempty(mask) && all(mask(:));
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.CeilingValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:ExpectedMaximum'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.CeilingValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:ExpectedMaximum'));
                
                if isempty(actual)
                    % If actual value is empty return early with
                    % appropriate diagnostics.
                    diag.addCondition(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingEmptyActual'));
                    return
                end
                
                scalarAct = isscalar(actual);
                scalarExp = isscalar(constraint.CeilingValue);
                
                if scalarAct && scalarExp
                    diag.addCondition(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingScalarActScalarExp'));
                else
                    failedMask = ~(actual <= constraint.CeilingValue);

                    indices = find(failedMask);
                    subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, indices(:)');
                    
                    subDiag.ActValHeader = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingIndices'));
                    
                    if scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingScalarActNonscalarExp'));
                    elseif ~scalarAct && scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingNonscalarActScalarExp'));
                    else % ~scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThanOrEqualTo:FailingNonscalarActNonscalarExp'));
                    end
                    subDiag.Description = description;
                    diag.addCondition(subDiag);
                    
                end
            end
        end
    end
end
