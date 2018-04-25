classdef IsFinite < matlab.unittest.constraints.BooleanConstraint
    % IsFinite - Constraint specifying a finite value
    %
    %   The IsFinite constraint produces a qualification failure for
    %   any value that does not contain all finite values.
    %
    %   IsFinite methods:
    %       IsFinite - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsFinite;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsFinite);
    %       testCase.assumeThat([0 5 1], IsFinite);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(NaN, IsFinite);
    %       testCase.verifyThat(Inf, IsFinite);
    %       testCase.assertThat(-Inf, IsFinite);
    %       testCase.verifyThat([5 6 NaN 8], IsFinite);
    %       testCase.fatalAssertThat([5 6 7 Inf], IsFinite);
    %       testCase.verifyThat(5+NaN*i, IsFinite);
    %
    %   See also:
    %       HasInf
    %       HasNaN
    %       isfinite
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function constraint = IsFinite
            % IsFinite - Class constructor
            %
            %   IsFinite creates a constraint that is able to determine whether all
            %   values of an actual value array are finite, and produce an appropriate
            %   qualification failure if the array contains any non-finite value.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = false;
            % Check isnumeric to avoid an error if "actual" is an object
            % that doesn't support isfinite().
            if isnumeric(actual)
                mask = isfinite(actual);
                tf = all(mask(:));
            end
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
            import matlab.unittest.internal.diagnostics.indent;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                if isnumeric(actual)
                    if isscalar(actual)
                        diag.addCondition(message('MATLAB:unittest:IsFinite:MustBeFinite'));
                    else
                        indicesString = indicesOfNonFiniteElementsString(actual);
                        diag.addCondition(message('MATLAB:unittest:IsFinite:AllMustBeFinite', indent(indicesString)));
                    end
                else
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustBeNumeric'));
                end
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.indent;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustNotBeFinite'));
                else
                    diag.addCondition(message('MATLAB:unittest:IsFinite:MustHaveOneNonFiniteElement'));
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if isnumeric(actual)
                    indicesString = indicesOfNonFiniteElementsString(actual);
                    diag.addCondition(message('MATLAB:unittest:IsFinite:IndicesWithNonFiniteValues', indent(indicesString)));
                else
                    diag.addCondition(message('MATLAB:unittest:IsFinite:IsNotNumeric'));
                end
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

function str = indicesOfNonFiniteElementsString(actual)
str = mat2str(reshape(find(~isfinite(actual)),1,[]));
end

% LocalWords:  FNDSB
