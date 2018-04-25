classdef IsFalse < matlab.unittest.constraints.Constraint
    % IsFalse - Constraint specifying a false value
    %
    %   The IsFalse constraint produces a qualification failure for
    %   any value that is not a scalar logical with a value of false.
    %
    %   IsFalse methods:
    %       IsFalse - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsFalse;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(false, IsFalse);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(true, IsFalse);
    %       testCase.verifyThat(0, IsFalse);
    %       testCase.assertThat([false true false], IsFalse);
    %       testCase.assumeThat([false false false], IsFalse);
    %
    %   See also:
    %       IsTrue
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    methods
        function constraint = IsFalse
            % IsFalse - Class constructor
            %
            %   IsFalse creates a constraint that is able to determine whether an
            %   actual value is false, and produce an appropriate qualification failure
            %   if it is any other value.
        end
        
        function tf = satisfiedBy(~, actual)
            tf = islogical(actual) && isscalar(actual) && ~actual;
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
                    diag.addCondition(message('MATLAB:unittest:IsFalse:MustBeLogical', class(actual)));
                end
                
                % Scalar
                if ~isscalar(actual)
                    diag.addCondition(message('MATLAB:unittest:IsFalse:MustBeScalar', int2str(size(actual))));
                end
                
                % Convertable to logical and false
                evaluatesToFalse = false;
                try
                    % Minimize the code in the try block
                    if actual
                        % If statement written this way because of empty
                        % values. [] and ~[] both do not execute the true
                        % path of an if statement, so we need this logic
                        % without using negation (~)
                    else
                        evaluatesToFalse = true;
                    end
                catch me
                    % Only do nothing if the value could not be converted
                    assert(strcmp(me.identifier, 'MATLAB:invalidConversion'), me.identifier, me.message);
                end
                
                if ~evaluatesToFalse
                    diag.addCondition(message('MATLAB:unittest:IsFalse:MustBeFalse'));
                end
            end
        end
    end
end

% LocalWords:  Convertable
