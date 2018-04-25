classdef IsGreaterThan < matlab.unittest.internal.constraints.CombinableConstraint
    % IsGreaterThan - Constraint specifying a value greater than another value
    %
    %   The IsGreaterThan constraint produces a qualification failure for any
    %   actual value array that is not greater than a specified floor value.
    %
    %   IsGreaterThan methods:
    %       IsGreaterThan - Class constructor
    %
    %   IsGreaterThan properties:
    %       FloorValue - The largest value which fails the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsGreaterThan;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(3, IsGreaterThan(2));
    %       testCase.assertThat([5 6 7], IsGreaterThan(2));
    %       testCase.assumeThat(5, IsGreaterThan([1 2 3]));
    %       testCase.verifyThat([5 -3 2], IsGreaterThan([4 -9 0]));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(5, IsGreaterThan(9));
    %       testCase.verifyThat([1 2 3; 4 5 6], IsGreaterThan(4));
    %       testCase.assertThat(eye(2), IsGreaterThan(eye(2)));
    %
    %   See also:
    %       IsGreaterThanOrEqualTo
    %       IsLessThan
    %       IsLessThanOrEqualTo
    %       gt
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % FloorValue - The largest value which fails the constraint
        FloorValue
    end
    
    methods
        function constraint = IsGreaterThan(floor)
            % IsGreaterThan - Class constructor
            %
            %   IsGreaterThan(FLOOR) creates a constraint that is able to determine
            %   whether an actual value is an array which is greater than FLOOR. The
            %   actual value is determined to be greater than the FLOOR if and only if
            %   all the elements of the inequality hold true according to MATLAB's GT
            %   function, or equivalently when all(actual > FLOOR) is true.
            
            if isempty(floor)
                error(message('MATLAB:unittest:IsGreaterThan:ExpectedNonEmptyMinimum'));
            end
            constraint.FloorValue = floor;
        end
        
        function tf = satisfiedBy(constraint, actual)
            gtMask = actual > constraint.FloorValue;
            tf = ~isempty(gtMask) && all(gtMask(:));
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
                    DiagnosticSense.Positive, actual, constraint.FloorValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsGreaterThan:ExpectedMinimum'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.FloorValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsGreaterThan:ExpectedMinimum'));
                
                if isempty(actual)
                    % If actual value is empty return early with
                    % appropriate diagnostics.
                    diag.addCondition(message('MATLAB:unittest:IsGreaterThan:FailingEmptyActual'));
                    return
                end
                
                scalarAct = isscalar(actual);
                scalarExp = isscalar(constraint.FloorValue);
                
                if scalarAct && scalarExp
                    diag.addCondition(message('MATLAB:unittest:IsGreaterThan:FailingScalarActScalarExp'));
                else
                    failedMask = ~(actual > constraint.FloorValue);
                    
                    indices = find(failedMask);
                    subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, indices(:)');
                    
                    subDiag.ActValHeader = getString(message('MATLAB:unittest:IsGreaterThan:FailingIndices'));
                    
                    if scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThan:FailingScalarActNonscalarExp'));
                    elseif ~scalarAct && scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThan:FailingNonscalarActScalarExp'));
                    else % ~scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThan:FailingNonscalarActNonscalarExp'));
                    end
                    subDiag.Description = description;
                    diag.addCondition(subDiag);
                end
            end
        end
        
    end
end
