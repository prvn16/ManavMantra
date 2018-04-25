classdef IsReal < matlab.unittest.constraints.BooleanConstraint
    % IsReal - Constraint specifying a real valued array
    %
    %   The IsReal constraint produces a qualification failure for
    %   any value that is not a real-valued array.
    %
    %   IsReal methods:
    %       IsReal - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsReal;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsReal);
    %       testCase.assertThat(5+0i, IsReal);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(i, IsReal);
    %       testCase.verifyThat(1+i, IsReal);
    %       testCase.assumeThat([3 1+i], IsReal);
    %
    %   See also:
    %       isreal
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function constraint = IsReal
            % IsReal - Class constructor
            %
            %   IsReal creates a constraint that is able to determine whether an actual
            %   value array is real valued, and produce an appropriate qualification
            %   failure if the array is not real.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = isreal(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                diag.addCondition(message('MATLAB:unittest:IsReal:MustBeReal'));
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(message('MATLAB:unittest:IsReal:MustNotBeReal'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
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