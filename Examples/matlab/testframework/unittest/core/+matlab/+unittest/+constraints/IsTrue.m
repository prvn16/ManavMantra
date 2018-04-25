classdef IsTrue < matlab.unittest.constraints.Constraint
    % IsTrue - Constraint specifying a true value
    %
    %   The IsTrue constraint produces a qualification failure for any value
    %   that is not a scalar logical with a value of true.
    %
    %   IsTrue methods:
    %       IsTrue - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsTrue;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(true, IsTrue);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(false, IsTrue);
    %       testCase.verifyThat(1, IsTrue);
    %       testCase.assumeThat([true true true], IsTrue);
    %
    %   See also:
    %       IsFalse
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function constraint = IsTrue
            % IsTrue - Class constructor
            %
            %   IsTrue creates a constraint that is able to determine whether an actual
            %   value is true, and produce an appropriate qualification failure if it
            %   is any other value.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = islogical(actual) && isscalar(actual) && actual;
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
                
                % Logical
                if ~islogical(actual)
                    diag.addCondition(message('MATLAB:unittest:IsTrue:MustBeLogical', class(actual)));
                end
                
                % Scalar
                if ~isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:IsTrue:MustBeScalar', int2str(size(actual))));
                end

                % Convertable to logical and true
                evaluatesToTrue = false;
                try
                    % Minimize the code in the try block
                    if actual
                        evaluatesToTrue = true;
                    end
                catch me
                    % Only do nothing if the value could not be converted
                    assert(strcmp(me.identifier, 'MATLAB:invalidConversion'), me.identifier, me.message);
                end
                
                if ~evaluatesToTrue
                    diag.addCondition(message('MATLAB:unittest:IsTrue:MustBeTrue'));
                end
            end
        end
    end
end
% LocalWords:  Convertable
