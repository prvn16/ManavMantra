classdef HasNaN < matlab.unittest.constraints.BooleanConstraint
    % HasNaN - Constraint specifying an array containing a NaN value
    %
    %   The HasNaN constraint produces a qualification failure for a value that
    %   does not contain any NaN values.
    %
    %   HasNaN methods:
    %       HasNaN - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasNaN;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(NaN, HasNaN);
    %       testCase.verifyThat([NaN Inf], HasNaN);
    %       testCase.verifyThat([4 NaN], HasNaN);
    %       testCase.verifyThat([-Inf 5 NaN], HasNaN);
    %       testCase.verifyThat(NaN+Inf*i, HasNaN);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(Inf, HasNaN);
    %       testCase.verifyThat([5 Inf], HasNaN);
    %       testCase.verifyThat(Inf+6i, HasNaN);
    %       testCase.verifyThat([5 6 Inf 8], HasNaN);
    %       testCase.verifyThat([5 6 7 8], HasNaN);
    %
    %   See also:
    %       IsFinite
    %       HasInf
    %       isnan
    
    %  Copyright 2010-2017 The MathWorks, Inc.
      
    methods
        function constraint = HasNaN
            % HasNaN - Class constructor
            %
            %   HasNaN creates a constraint that is able to determine whether any
            %   value of an actual value array is NaN, and produce an appropriate
            %   qualification failure if the array does not contain any NaN values.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = false;
            % Check isfloat to avoid an error if "actual" is an object that
            % doesn't support isnan().
            if isfloat(actual)
                nanMask = isnan(actual);
                tf = any(nanMask(:));
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
                indicesString = indicesOfNaNString(actual);
                diag.addCondition(message('MATLAB:unittest:HasNaN:IndicesThatHaveNaN',indent(indicesString)));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                if ~isfloat(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustBeFloatingPoint', class(actual)));
                end
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustBeNaN'));
                else
                    diag.addCondition(message('MATLAB:unittest:HasNaN:AtLeastOneElementMustBeNaN'));
                end
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.indent;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:MustNotBeNaN'));
                else
                    indicesString = indicesOfNaNString(actual);
                    diag.addCondition(message('MATLAB:unittest:HasNaN:AllElementsMustBeNonNaN', indent(indicesString)));
                end
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                if ~isfloat(actual)
                    diag.addCondition(message('MATLAB:unittest:HasNaN:IsNotFloatingPoint', class(actual)));
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

function str = indicesOfNaNString(actual)
str = mat2str(reshape(find(isnan(actual)),1,[]));
end

% LocalWords:  NString FNDSB
