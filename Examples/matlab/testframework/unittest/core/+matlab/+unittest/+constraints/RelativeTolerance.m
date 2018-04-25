classdef RelativeTolerance < matlab.unittest.internal.constraints.ToleranceWithValues & ...
                             matlab.unittest.internal.constraints.CasualToleranceDiagnosticMixin
    % RelativeTolerance - Relative numeric tolerance
    %
    %   This numeric tolerance assesses the magnitude of the difference
    %   between actual and expected values, relative to the expected value.
    %
    %   Requirement: | expVal - actVal | <= relTol .* | expVal |
    %
    %   The data types of the inputs to the RelativeTolerance constructor
    %   determine the data types to which the tolerance is applied. For
    %   example, RelativeTolerance(10*eps) constructs a RelativeTolerance
    %   for comparing double-precision numeric arrays while
    %   RelativeTolerance(int8(2)) constructs a RelativeTolerance for
    %   comparing numeric arrays of type int8. If the actual and expected
    %   values being compared contain more than one numeric data type, the
    %   tolerance only applies to the data types specified by the values
    %   passed into the constructor.
    %
    %   Different tolerance values can be specified for different data
    %   types by passing multiple tolerance values to the constructor. For
    %   example, RelativeTolerance(10*eps, 10*eps('single'), int8(0))
    %   constructs a RelativeTolerance that would apply the following
    %   relative tolerances:
    %       * 10*eps for double-precision numeric arrays
    %       * 10*eps('single') for single-precision numeric arrays
    %       * int8(0) for numeric arrays of type int8.
    %
    %   More than one tolerance can be specified for a particular data type
    %   by combining tolerances with the & and | operators. In order to
    %   combine two tolerances, the sizes of the tolerance values for each
    %   data type must be compatible.
    %
    %   RelativeTolerance methods:
    %       RelativeTolerance - Class constructor
    %
    %   RelativeTolerance properties:
    %       Values - Tolerance values
    %
    %   Examples:
    %       import matlab.unittest.TestCase;
    %       import matlab.unittest.constraints.IsEqualTo;
    %       import matlab.unittest.constraints.RelativeTolerance;
    %       import matlab.unittest.constraints.AbsoluteTolerance;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Simple use in IsEqualTo constraint
    %       testCase.assertThat(4.1, IsEqualTo(4.5, ...
    %           'Within', RelativeTolerance(0.1)));
    %
    %       % Specify different tolerances for different data types
    %       act = {'abc', 123, single(123), int8([1, 2, 3])};
    %       exp = {'abc', 122, single(120), int8([2, 4, 6])};
    %       testCase.verifyThat(act, IsEqualTo(exp, 'Within', ...
    %           AbsoluteTolerance(single(3), int8([2, 3, 5])) | ...
    %           RelativeTolerance(2, single(1))));
    %
    %   See also:
    %      matlab.unittest.constraints.AbsoluteTolerance
    %      matlab.unittest.constraints.IsEqualTo
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    methods (Hidden, Access = protected)
        function comp = compareValues(~, actVal, expVal, tolVal)
            % compareValues - Element-wise comparison of the actual and expected values.
            %   Assumes actual and expected validation has already been performed.
            
            % Infinite values in the expected value are comparison failures
            % at their corresponding element indices.
            comp = ~isinf(expVal) & abs(expVal - actVal) <= tolVal .* abs(expVal);
        end
    end
    
    methods
        function tolerance = RelativeTolerance(varargin)
            % RelativeTolerance - Class constructor
            %
            %   RelativeTolerance(TOLVALS) creates a relative tolerance object that
            %   assesses the magnitude of the difference between actual and expected
            %   values, relative to the expected value.
            
            tolerance = tolerance@matlab.unittest.internal.constraints.ToleranceWithValues(varargin);
            
            % Further validate that each tolerance value is a floating point data type
            cellfun(@(val)validateToleranceValue(val), varargin);
            function validateToleranceValue(val)
                if ~isfloat(val)
                    error(message('MATLAB:unittest:Tolerance:ToleranceMustBeFloat'));
                end
            end
        end
        
        function diag = getDiagnosticFor(tolerance, actVal, expVal)
            % getDiagnosticFor - Returns a diagnostic object containing
            %   information about the result of a comparison.
            diag = tolerance.getConstraintDiagnosticFor(actVal, expVal);
            diag.enableWarnOnUseFor(tolerance);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(tolerance, actVal, expVal)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
           
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            if ~tolerance.supports(expVal)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:ToleranceNotUsed', ...
                    class(expVal), strjoin(tolerance.Types,', ')));
                return;
            end
            
            cond = tolerance.produceFailureCondition(actVal, expVal);
            if isempty(cond)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:RelativeTolerancePassed'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:RelativeToleranceFailed'));
                diag.addCondition(cond);
            end
        end
    end
    
    methods (Hidden)
        function diag = getCasualDiagnosticFor(tolerance, actVal, expVal)
            % getCasualDiagnosticFor - Returns a casual diagnostic object containing
            %   information about the failing condition.
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            tolerance.validateActualExpectedValues(actVal, expVal);
            
            if ~tolerance.supports(expVal)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:ToleranceNotUsed', ...
                    class(expVal), strjoin(tolerance.Types,', ')));
                return;
            end
            
            if isempty(tolerance.getFailedIndices(actVal, expVal))
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:RelativeTolerancePassed'));
            else
                % Actual value is not equal to expected value within the
                % given tolerance
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(tolerance, ...
                    DiagnosticSense.Positive, actVal, expVal);
                diag.addCondition(message('MATLAB:unittest:Tolerance:RelativeToleranceFailed'));
                return;
            end
        end
    end
end

% LocalWords:  abc Elementwise