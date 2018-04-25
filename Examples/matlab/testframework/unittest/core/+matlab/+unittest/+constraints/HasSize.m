classdef HasSize < matlab.unittest.constraints.BooleanConstraint
    % HasSize - Constraint specifying an expected size of an array
    %
    %   The HasSize constraint produces a qualification failure for
    %   any actual value array that does not have a specified array size.
    %
    %   HasSize methods:
    %       HasSize - Class constructor
    %
    %   HasSize properties:
    %       Size - Size a value must have to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.HasSize;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(ones(2, 5, 3), HasSize([2 5 3]));
    %       testCase.assumeThat({'SomeString', 'SomeOtherString'}, HasSize([1 2]));
    %       testCase.fatalAssertThat([1 2 3; 4 5 6], HasSize([2 3]));
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat([2 3], HasSize([3 2]));
    %       testCase.verifyThat([1 2 3; 4 5 6], HasSize(6));
    %       testCase.assertThat(eye(2), HasSize([4 1]));
    %
    %   See also:
    %       HasElementCount
    %       HasLength
    %       IsEmpty
    %       IsScalar
    %       size
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    
    properties (SetAccess=private)
        % Size - Size a value must have to satisfy the constraint
        Size
    end
    
    
    methods
        function constraint = HasSize(sz)
            % HasSize - Class constructor
            %
            %   HasSize(SIZE) creates a constraint that is able to determine
            %   whether an actual value is an array whose size is equal to SIZE.
                        
            constraint.Size = sz;
        end
        
        function tf = satisfiedBy(constraint, actual)
            actSize = size(actual);
            actSize(end+1:numel(constraint.Size)) = 1;
            tf = isequal(actSize, constraint.Size);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        function constraint = set.Size(constraint, sz)
            validateattributes(                             ...
                sz,                                         ...
                {'numeric'},                                ...
                {'row','nonnegative','finite','integer'},   ...
                '', 'size');
            
            if numel(sz) < 2
                error(message('MATLAB:unittest:HasSize:ExpectedAtLeastTwoElements'));
            end
            constraint.Size = sz;
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Size);
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:ExpectedSize'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                % Use a sub-diagnostic to report the value's wrong size
                sizeDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, size(actual), constraint.Size);
                sizeDiag.Description = getString(message('MATLAB:unittest:HasSize:MustHaveExpectedSize'));
                sizeDiag.ActValHeader = getString(message('MATLAB:unittest:HasSize:ActualSize'));
                sizeDiag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:ExpectedSize'));
                diag.addCondition(sizeDiag);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Size);
                diag.addCondition(message('MATLAB:unittest:HasSize:MustNotHaveProhibitedSize'));
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:ProhibitedSize'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                sizeDiag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, size(actual), constraint.Size);
                sizeDiag.Description = getString(message('MATLAB:unittest:HasSize:DidNotHaveProhibitedSize'));
                sizeDiag.ActValHeader = getString(message('MATLAB:unittest:HasSize:ActualSize'));
                sizeDiag.ExpValHeader = getString(message('MATLAB:unittest:HasSize:ProhibitedSize'));
                diag.addCondition(sizeDiag);
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