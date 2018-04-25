classdef EveryCellOf < matlab.unittest.constraints.ActualValueProxy
    % EveryCellOf - Test if all elements of a cell array meet a constraint
    %
    %   The EveryCellOf class defines an object that serves as a proxy of the
    %   actual value to the framework. It allows a test writer to apply a
    %   constraint against each cell of a cell array, and ensure that a passing
    %   result occurs only when all cells of the cell array satisfy the
    %   constraint.
    %
    %   NOTE: Because EveryCellOf loops over each cell of the MATLAB
    %   cell array provided and checks whether each cell satisfies the
    %   constraint, its usage may result in slower qualification than when
    %   the actual value is qualified in one shot. This is particularly
    %   true for large cell arrays. If the semantics of the comparison can
    %   be achieved in an alternate manner, then it is a good idea to weigh
    %   the performance penalty of this looping operation against the
    %   readability and diagnostic information that you receive when using
    %   the EveryCellOf object to determine whether or not it should be
    %   used.
    %
    %   EveryCellOf methods:
    %       EveryCellOf - Class constructor
    %
    %   EveryCellOf properties:
    %       ActualValue - Actual value to test against a constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.EveryCellOf;
    %       import matlab.unittest.constraints.HasNaN;
    %       import matlab.unittest.constraints.ContainsSubstring;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing verification
    %       testCase.verifyThat(EveryCellOf({'abc', 'abc123'}), ContainsSubstring('abc'));
    %
    %       % Failing assertion
    %       testCase.assertThat(EveryCellOf({NaN Inf 5}), HasNaN);
    %
    %   See also:
    %       ActualValueProxy
    %       AnyCellOf
    %       EveryElementOf
    %       AnyElementOf
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    methods
        function proxy = EveryCellOf(actualValue)
            % EveryCellOf - Class constructor
            %
            %   EveryCellOf(ACTUAL) creates an EveryCellOf proxy instance which
            %   results in comparing a given constraint against each element of the
            %   ACTUAL value provided, and a passing result occurs only if each element
            %   individually satisfies the constraint.
            %
            %   This class is intended to be used through matlab.unittest
            %   qualifications as is shown in the examples. The class does
            %   not modify the provided actual value in any way, but simply
            %   serves as a wrapper to perform the constraint analysis on the
            %   value on an element by element basis.
            
            proxy = proxy@matlab.unittest.constraints.ActualValueProxy(actualValue);
        end
    end
    
    methods(Hidden)
        function tf = satisfiedBy(proxy, constraint)
            proxy.validateConstraint(constraint);
            
            if ~iscell(proxy.ActualValue) || isempty(proxy.ActualValue)
                tf = false;
                return;
            end
            
            result = proxy.getSatisfiedByMask(constraint);
            tf = all(result(:));
        end
        
        function diag = getDiagnosticFor(proxy, constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.indent;
            
            proxy.validateConstraint(constraint);
            
            if ~iscell(proxy.ActualValue) || isempty(proxy.ActualValue)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(proxy, ...
                    DiagnosticSense.Positive, proxy.ActualValue);
                diag.addCondition(message('MATLAB:unittest:EveryCellOf:ExpectedNonEmpty'));
                return;
            end
            
            passed = proxy.getSatisfiedByMask(constraint);
            failed = ~passed;
            
            if all(passed)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    constraint, DiagnosticSense.Positive, proxy.ActualValue);
                diag.Description = getString(message('MATLAB:unittest:EveryCellOf:AllSatisfied', class(constraint)));
                diag.ActValHeader = getString(message('MATLAB:unittest:EveryCellOf:ActualValueCellArray'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, proxy.ActualValue);
                
                diag.Description = getString(message('MATLAB:unittest:EveryCellOf:NotAllSatisfied', ...
                    indent(mat2str(reshape(find(failed),1,[])))));
                
                subDiag = constraint.getDiagnosticFor(proxy.ActualValue{find(failed, 1)});
                
                diag.addCondition(subDiag);
                diag.ActValHeader = getString(message('MATLAB:unittest:EveryCellOf:ActualValueCellArray'));
            end
        end
    end
    
    methods(Access = private)
        function result = getSatisfiedByMask(proxy, constraint)
           % Loops over all values of the actual value and checks whether
           % each element satisfies the constraint. Returns a logical mask.
           actual = proxy.ActualValue;
           result = false(size(actual));
           
           for ct = 1:numel(actual)
               result(ct) = constraint.satisfiedBy(actual{ct});
           end
        end
    end
end

% LocalWords:  abc FNDSB
