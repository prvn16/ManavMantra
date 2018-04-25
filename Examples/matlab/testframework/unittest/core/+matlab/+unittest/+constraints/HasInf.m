classdef HasInf < matlab.unittest.constraints.BooleanConstraint
    % HasInf - Constraint specifying an array containing any infinite value
    %
    %   The HasInf constraint produces a qualification failure for a value that
    %   does not contain any infinite values.
    %
    %   HasInf methods:
    %       HasInf - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasInf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(Inf, HasInf);
    %       testCase.verifyThat(-Inf, HasInf);
    %       testCase.verifyThat([-Inf Inf], HasInf);
    %       testCase.verifyThat([4 Inf], HasInf);
    %       testCase.verifyThat([-Inf 5 NaN], HasInf);
    %       testCase.verifyThat(NaN+Inf*i, HasInf);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(NaN, HasInf);
    %       testCase.verifyThat([5 NaN], HasInf);
    %       testCase.verifyThat(NaN+6i, HasInf);
    %       testCase.verifyThat([5 6 NaN 8], HasInf);
    %       testCase.verifyThat([5 6 7 8], HasInf);
    %
    %   See also:
    %       IsFinite
    %       HasNaN
    %       isinf
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function constraint = HasInf
            % HasInf - Class constructor
            %
            %   HasInf creates a constraint that is able to determine whether any
            %   value of an actual value array is infinite, and produce an appropriate
            %   qualification failure if the array does not contain any infinite values.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = false;
            % Check isfloat to avoid an error if "actual" is an object that
            % doesn't support isinf().
            if isfloat(actual)
                infMask = isinf(actual);
                tf = any(infMask(:));
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
                indicesString = indicesOfInfString(actual);
                diag.addCondition(message('MATLAB:unittest:HasInf:IndicesThatHaveInf', indent(indicesString)));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                if ~isfloat(actual)
                    diag.addCondition(message('MATLAB:unittest:HasInf:MustBeFloatingPoint', class(actual)));
                end
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:HasInf:MustBeInfScalar'));
                else
                    diag.addCondition(message('MATLAB:unittest:HasInf:MustBeInfNonScalar'));
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
                    diag.addCondition(message('MATLAB:unittest:HasInf:MustNotBeInfScalar'));
                else
                    indicesString = indicesOfInfString(actual);
                    diag.addCondition(message('MATLAB:unittest:HasInf:AllMustBeNonInf', indent(indicesString)));
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if ~isfloat(actual)
                    diag.addCondition(message('MATLAB:unittest:HasInf:IsNotFloatingPoint', class(actual)));
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

function str = indicesOfInfString(actual)
str = mat2str(reshape(find(isinf(actual)),1,[]));
end

% LocalWords:  FNDSB
