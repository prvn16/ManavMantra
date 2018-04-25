classdef HasLength < matlab.unittest.constraints.BooleanConstraint
    % HasLength - Constraint specifying an expected length of an array
    %
    %   The HasLength constraint produces a qualification failure for
    %   any actual value array that does not have a specified length. The
    %   length of an array is defined as the largest dimension of that array
    %
    %   HasLength methods:
    %       HasLength - Class constructor
    %
    %   HasLength properties:
    %       Length - Length a value must have to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasLength;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(ones(2, 5, 3), HasLength(5));
    %       testCase.verifyThat({'SomeString', 'SomeOtherString'}, HasLength(2));
    %       testCase.verifyThat([1 2 3; 4 5 6], HasLength(3));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat([2 3], HasLength(3));
    %       testCase.verifyThat([1 2 3; 4 5 6], HasLength(6));
    %       testCase.verifyThat(eye(2), HasLength(4));
    %
    %   See also:
    %       HasElementCount
    %       HasSize
    %       IsEmpty
    %       length
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Length - Length a value must have to satisfy the constraint
        Length
    end
    
    
    methods
        function constraint = HasLength(length)
            % HasLength - Class constructor
            %
            %   HasLength(LENGTH) creates a constraint that is able to determine
            %   whether an actual value is an array whose largest dimension's length is
            %   equal to LENGTH.
            
            constraint.Length = length;
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = isequal(length(actual), constraint.Length);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        function constraint = set.Length(constraint, length)
            validateattributes(length, {'numeric'}, ...
                {'scalar','nonnegative','finite','integer'}, '', 'length');
            
            constraint.Length = length;
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Length);
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasLength:ExpectedLength'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                % Use a sub-diagnostic to report the value's wrong length
                lengthDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, length(actual), constraint.Length);
                lengthDiag.Description = getString(message('MATLAB:unittest:HasLength:MustHaveLength'));
                lengthDiag.ActValHeader = getString(message('MATLAB:unittest:HasLength:ActualLength'));
                lengthDiag.ExpValHeader = getString(message('MATLAB:unittest:HasLength:ExpectedLength'));
                diag.addCondition(lengthDiag);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Length);
                diag.addCondition(message('MATLAB:unittest:HasLength:MustNotHaveProhibitedLength'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasLength:ProhibitedLength'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                lengthDiag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, length(actual), constraint.Length);
                lengthDiag.Description = getString(message('MATLAB:unittest:HasLength:DidNotHaveProhibitedLength'));
                lengthDiag.ActValHeader = getString(message('MATLAB:unittest:HasLength:ActualLength'));
                lengthDiag.ExpValHeader = getString(message('MATLAB:unittest:HasLength:ProhibitedLength'));
                diag.addCondition(lengthDiag);
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
