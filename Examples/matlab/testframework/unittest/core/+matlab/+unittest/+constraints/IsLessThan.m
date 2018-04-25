classdef IsLessThan < matlab.unittest.internal.constraints.CombinableConstraint
    % IsLessThan - Constraint specifying a value less than another value
    %
    %   The IsLessThan constraint produces a qualification failure for any
    %   actual value array that is not less than a specified ceiling value.
    %
    %   IsLessThan methods:
    %       IsLessThan - Class constructor
    %
    %   IsLessThan properties:
    %       CeilingValue - The smallest value which fails the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsLessThan;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(2, IsLessThan(3));
    %       testCase.assertThat([5 6 7], IsLessThan(9));
    %       testCase.verifyThat([5 -3 2], IsLessThan([7 -1 8]));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(9, IsLessThan(5));
    %       testCase.verifyThat([1 2 3; 4 5 6], IsLessThan(4));
    %       testCase.assertThat(eye(2), IsLessThan(eye(2)));
    %
    %   See also:
    %       IsLessThanOrEqualTo
    %       IsGreaterThan
    %       IsGreaterThanOrEqualTo
    %       lt
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % CeilingValue - The smallest value which fails the constraint
        CeilingValue
    end
    
    methods
        function constraint = IsLessThan(ceiling)
            % IsLessThan - Class constructor
            %
            %   IsLessThan(CEILING) creates a constraint that is able to determine
            %   whether an actual value is an array which is less than CEILING. The
            %   actual value is determined to be less than the CEILING if and only if
            %   all the elements of the inequality hold true according to MATLAB's LT
            %   function, or equivalently when all(actual < CEILING) is true.

            if isempty(ceiling)
                error(message('MATLAB:unittest:IsLessThan:ExpectedNonEmptyMaximum'));
            end
            constraint.CeilingValue = ceiling;
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            mask = actual < constraint.CeilingValue;
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
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsLessThan:ExpectedMaximum'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.CeilingValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsLessThan:ExpectedMaximum'));
                
                if isempty(actual)
                    % If actual value is empty return early with
                    % appropriate diagnostics.
                    diag.addCondition(message('MATLAB:unittest:IsLessThan:FailingEmptyActual'));
                    return
                end
                
                scalarAct = isscalar(actual);
                scalarExp = isscalar(constraint.CeilingValue);
                
                if scalarAct && scalarExp
                    diag.addCondition(message('MATLAB:unittest:IsLessThan:FailingScalarActScalarExp'));
                else
                    failedMask = ~(actual < constraint.CeilingValue);
                    indices = find(failedMask);
                    subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, indices(:)');
                    
                    subDiag.ActValHeader = getString(message('MATLAB:unittest:IsLessThan:FailingIndices'));
                    
                    if scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThan:FailingScalarActNonscalarExp'));
                    elseif ~scalarAct && scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThan:FailingNonscalarActScalarExp'));
                    else % ~scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsLessThan:FailingNonscalarActNonscalarExp'));
                    end
                    subDiag.Description = description;
                    diag.addCondition(subDiag);
                end
            end
        end
        
    end
end
