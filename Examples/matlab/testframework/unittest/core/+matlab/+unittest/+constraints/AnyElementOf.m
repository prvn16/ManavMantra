classdef AnyElementOf  < matlab.unittest.constraints.ActualValueProxy
    % AnyElementOf - Test if any element of an array meets a constraint
    %
    %   The AnyElementOf class defines an object that serves as a proxy of the
    %   actual value to the framework. It allows a test writer to apply a
    %   constraint against each element of an array, and ensure that a passing
    %   result occurs provided there is at least one element of the array that
    %   satisfies the constraint.
    %
    %   NOTE: Because AnyElementOf, in the worst case, loops over every element
    %   of the MATLAB array provided and checks whether element satisfies the
    %   constraint, its usage may result in a slower qualification than when
    %   the actual value is qualified in one shot. This is particularly true
    %   for large arrays. If the semantics of the comparison can be achieved
    %   in an alternate manner, then it is a good idea to weigh the performance
    %   penalty of this looping operation against the readability and
    %   diagnostic information that you receive when using the AnyElementOf
    %   object to determine whether or not it should be used.
    %
    %   AnyElementOf methods:
    %       AnyElementOf - Class constructor
    %
    %   AnyElementOf properties:
    %       ActualValue - Actual value to test against a constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.AnyElementOf;
    %       import matlab.unittest.constraints.IsFinite;
    %       import matlab.unittest.constraints.IsLessThan;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing verification
    %       testCase.verifyThat(AnyElementOf([NaN Inf 5]), IsFinite);
    %
    %       % Failing assertion
    %       testCase.assertThat(AnyElementOf([1 5]), IsLessThan(0));
    %
    %   See also:
    %       ActualValueProxy
    %       EveryElementOf
    %       AnyCellOf
    %       EveryCellOf
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods
        function proxy = AnyElementOf(actual)
            % AnyElementOf - Class constructor
            %
            %   AnyElementOf(ACTUAL) creates an AnyElementOf proxy instance which
            %   results in comparing a given constraint against each element of the
            %   ACTUAL value provided, and a passing result occurs if at least one
            %   element individually satisfies the constraint.
            %
            %   This class is intended to be used through matlab.unittest
            %   qualifications as is shown in the examples. The class does
            %   not modify the provided actual value in any way, but simply
            %   serves as a wrapper to perform the constraint analysis on the
            %   value on an element by element basis.
            
            proxy@matlab.unittest.constraints.ActualValueProxy(actual);
        end
    end
    
    methods(Hidden)
        function tf = satisfiedBy(proxy, constraint)
            proxy.validateConstraint(constraint);
            
            tf = false;
            actual = proxy.ActualValue;
            for ct = 1:numel(actual)
                result = constraint.satisfiedBy(actual(ct));
                if result
                    tf = true;
                    break;
                end
            end
        end
        
        function diag = getDiagnosticFor(proxy, constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            proxy.validateConstraint(constraint);
            
            passed = proxy.getSatisfiedByMask(constraint);
            failed = ~passed;
            
            if isempty(failed)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(proxy, ...
                    DiagnosticSense.Positive, proxy.ActualValue);
                diag.addCondition(message('MATLAB:unittest:AnyElementOf:ExpectedNonEmpty'));
                
            elseif all(failed(:))
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, proxy.ActualValue);
                subDiag = constraint.getDiagnosticFor(proxy.ActualValue(failed(1)));
                
                diag.addCondition(subDiag);
                diag.ActValHeader = getString(message('MATLAB:unittest:AnyElementOf:ActualValueArray'));
                diag.Description = getString(message('MATLAB:unittest:AnyElementOf:NoneSatisfied'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, proxy.ActualValue);
                diag.Description = getString(message('MATLAB:unittest:AnyElementOf:AtLeastOneSatisfied', class(constraint)));
                diag.ActValHeader = getString(message('MATLAB:unittest:AnyElementOf:ActualValueArray'));
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
               result(ct) = constraint.satisfiedBy(actual(ct));
           end
        end
    end
end
