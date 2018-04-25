classdef ReturnsTrue < matlab.unittest.internal.constraints.FunctionHandleConstraint
    % ReturnsTrue - Constraint specifying a function handle that returns true
    %
    %   The ReturnsTrue constraint produces a qualification failure for any
    %   value that is not a function handle that returns a scalar logical with
    %   a value of true.
    %
    %   ReturnsTrue methods:
    %       ReturnsTrue - Class constructor
    %
    %   Examples:
    %       import matlab.unittest.constraints.ReturnsTrue;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % Note these are for example only, there exist fully featured
    %       % Constraints to better handle these particular comparisons
    %       testCase.verifyThat(@true, ReturnsTrue);
    %       testCase.assumeThat(@() isequal(1,1), ReturnsTrue);
    %       testCase.verifyThat(@() ~strcmp('a','b'), ReturnsTrue);
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.fatalAssertThat(@false, ReturnsTrue);
    %       testCase.verifyThat(@() strcmp('a',{'a','a'}), ReturnsTrue);
    %       testCase.assertThat(@() exist('exist'), ReturnsTrue);
    %
    %   See also:
    %       IsTrue
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (Access=private)
        ReturnValue;
    end
    
    methods
        function constraint = ReturnsTrue
            % ReturnsTrue - Class constructor
            %
            %   ReturnsTrue creates a constraint that is able to determine whether an
            %   actual value is a function handle that returns true, and produce an
            %   appropriate qualification failure if it is any other value.
        end
        
        function tf = satisfiedBy(constraint, actual)
            if constraint.isFunction(actual)
                constraint.invoke(actual);
                returnValue = constraint.ReturnValue;
                tf = islogical(returnValue) && isscalar(returnValue) && returnValue;
            else
                tf = false; % is not a function handle
            end
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return;
            end
            
            returnValue = constraint.invokeIfNeeded(actual);
            condList = getCellOfConditionsForUnsatisfaction(returnValue);
            
            if isempty(condList) % Constraint passed
                diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
            else
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                for k=1:numel(condList)
                    diag.addCondition(condList{k});
                end
            end
        end
    end
    
    methods(Sealed,Hidden)
        function constraint = not(~) %#ok<STOUT>
            % not - The logical negation of the ReturnsTrue constraint
            %
            %   not(ReturnsTrue) has been removed. Use ReturnsTrue instead. Move the
            %   negation to the inside of the actual value (function handle) input of
            %   assertThat, assumeThat, fatalAssertThat, or verifyThat. For example,
            %   replace testCase.verifyThat(@foo, ~ReturnsTrue) with
            %   testCase.verifyThat(@() ~foo(), ReturnsTrue).
            error(message('MATLAB:unittest:ReturnsTrue:NotReturnsTrueHasBeenRemoved',...
                'not(ReturnsTrue)','ReturnsTrue'));
        end
    end
    
    methods (Hidden, Access=protected)
        function invoke(constraint, actual)
            constraint.ReturnValue = invoke@matlab.unittest.internal.constraints.FunctionHandleConstraint(constraint, actual);
        end
    end
    
    methods (Access=private)
        function returnValue = invokeIfNeeded(constraint, actual)
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            returnValue = constraint.ReturnValue;
        end
    end
end

function condList = getCellOfConditionsForUnsatisfaction(returnValue)
import matlab.unittest.internal.diagnostics.MessageString;
import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
import matlab.unittest.internal.diagnostics.getDisplayableString;

condList = cell(1,0);
if ~islogical(returnValue)
    condList{end+1} = message('MATLAB:unittest:ReturnsTrue:DidNotHaveLogicalOutput', class(returnValue));
end
if ~isscalar(returnValue)
    condList{end+1} = message('MATLAB:unittest:ReturnsTrue:DidNotHaveScalarOutput', ...
        int2str(size(returnValue)));
end
if isempty(condList) && ~returnValue
    condList{end+1} = message('MATLAB:unittest:ReturnsTrue:DidNotEvaluateToTrue');
end
if ~isempty(condList)
    condList{end+1} = FormattableStringDiagnostic( ...
        MessageString('MATLAB:unittest:ReturnsTrue:ActualReturnValue', ...
        indent(getDisplayableString(returnValue))));
end
end

% LocalWords:  Negatable Unsatisfaction Formattable
