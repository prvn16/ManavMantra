classdef IsScalar < matlab.unittest.constraints.BooleanConstraint
    % IsScalar - Constraint specifying a scalar value
    %
    %   The IsScalar constraint produces a qualification failure for
    %   any non-scalar actual value.
    %
    %   IsScalar methods:
    %       IsScalar - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsScalar;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(0, IsScalar);
    %       testCase.assertThat(ones(1, 1, 1, 1), IsScalar);
    %       testCase.assumeThat(timeseries(1), IsScalar);
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat([2 3], IsScalar);
    %       testCase.assertThat(struct([]), IsScalar);
    %       testCase.verifyThat({[], [], []}, IsScalar);
    %       testCase.verifyThat(struct, ~IsScalar);
    %
    %   See also:
    %       HasElementCount
    %       HasLength
    %       HasSize
    %       IsEmpty
    %       isscalar
    
    %  Copyright 2014-2017 The MathWorks, Inc.
    
    methods
        function constraint = IsScalar
            % IsScalar - Class constructor
            %
            %   IsScalar creates a constraint that is able to determine
            %   whether an actual value is a scalar.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = isscalar(actual);
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
            
            if ~isscalar(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                diag.addCondition(message('MATLAB:unittest:IsScalar:MustBeScalar'));
                diag.addCondition(message('MATLAB:unittest:IsScalar:ActualSize', int2str(size(actual))));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if isscalar(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(message('MATLAB:unittest:IsScalar:MustNotBeScalar'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
            end
            diag.addCondition(message('MATLAB:unittest:IsScalar:ActualSize', int2str(size(actual))));
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
end
