classdef IsGreaterThanOrEqualTo < matlab.unittest.internal.constraints.CombinableConstraint
    % IsGreaterThanOrEqualTo - Constraint specifying a value greater than or equal to another value
    %
    %   The IsGreaterThanOrEqualTo constraint produces a qualification failure
    %   for any actual value array that is not greater than or equal to a
    %   specified floor value.
    %
    %   IsGreaterThanOrEqualTo methods:
    %       IsGreaterThanOrEqualTo - Class constructor
    %
    %   IsGreatherThanOrEqualTo properties:
    %       FloorValue - The minimum value to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(3, IsGreaterThanOrEqualTo(2));
    %       testCase.assertThat(3, IsGreaterThanOrEqualTo(3));
    %       testCase.assertThat([5 2 7], IsGreaterThanOrEqualTo(2));
    %       testCase.verifyThat([5 -3 2], IsGreaterThanOrEqualTo([4 -3 0]));
    %       testCase.assertThat(eye(2), IsGreaterThanOrEqualTo(eye(2)));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(5, IsGreaterThanOrEqualTo(9));
    %       testCase.verifyThat([1 2 3; 4 5 6], IsGreaterThanOrEqualTo(4));
    %
    %   See also:
    %       IsGreaterThan
    %       IsLessThan
    %       IsLessThanOrEqualTo
    %       ge
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % FloorValue - The minimum value to satisfy the constraint
        FloorValue
    end
    
    methods
        function constraint = IsGreaterThanOrEqualTo(floor)
            % IsGreaterThanOrEqualTo - Class constructor
            %
            %   IsGreaterThanOrEqualTo(FLOOR) creates a constraint that is able to
            %   determine whether an actual value is an array which is greater than or
            %   equal to FLOOR.  The actual value is determined to be greater than or
            %   equal to the FLOOR if and only if all the elements of the inequality
            %   hold true according to MATLAB's GE function, or equivalently when
            %   all(actual >= FLOOR) is true.
            
            if isempty(floor)
                error(message('MATLAB:unittest:IsGreaterThanOrEqualTo:ExpectedNonEmptyMinimum'));
            end
            constraint.FloorValue = floor;
        end
        
        function tf = satisfiedBy(constraint, actual)
            mask = actual >= constraint.FloorValue;
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
                    DiagnosticSense.Positive, actual, constraint.FloorValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:ExpectedMinimum'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.FloorValue);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:ExpectedMinimum'));
                
                if isempty(actual)
                    % If actual value is empty return early with
                    % appropriate diagnostics.
                    diag.addCondition(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingEmptyActual'));
                    return
                end
                
                scalarAct = isscalar(actual);
                scalarExp = isscalar(constraint.FloorValue);
                
                if scalarAct && scalarExp
                    diag.addCondition(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingScalarActScalarExp'));
                else
                    failedMask = ~(actual >= constraint.FloorValue);
                    indices = find(failedMask);
                    subDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, indices(:)');
                    
                    subDiag.ActValHeader = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingIndices'));
                    
                    if scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingScalarActNonscalarExp'));
                    elseif ~scalarAct && scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingNonscalarActScalarExp'));
                    else % ~scalarAct && ~scalarExp
                        description = getString(message('MATLAB:unittest:IsGreaterThanOrEqualTo:FailingNonscalarActNonscalarExp'));
                    end
                    subDiag.Description = description;
                    diag.addCondition(subDiag);
                end
            end
        end
        
    end
end
