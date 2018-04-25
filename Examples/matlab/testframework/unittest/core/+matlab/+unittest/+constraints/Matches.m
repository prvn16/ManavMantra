classdef Matches < matlab.unittest.constraints.BooleanConstraint & ...
                   matlab.unittest.internal.mixin.IgnoringCaseMixin
    % Matches - Constraint specifying a string or character vector matching a given regular expression
    %
    %   The Matches constraint produces a qualification failure for any actual
    %   value that is not a string scalar or character vector that matches a
    %   given regular expression.
    %
    %   Matches methods:
    %       Matches - Class constructor
    %
    %   Matches properties:
    %      Expression - Regular expression the value must match to satisfy the constraint
    %      IgnoreCase - Boolean indicating whether this instance is insensitive to case
    %
    %   Examples:
    %       import matlab.unittest.constraints.Matches;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat('SomeText', Matches('Some[Tt]?ext'));
    %       testCase.assertThat("Sometext", Matches('Some[Tt]?ext'));
    %       testCase.fatalAssertThat("Someext", Matches("Some[Tt]?ext"));
    %       testCase.verifyThat('SomeText', Matches("some*", 'IgnoringCase', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.assumeThat('SomeTtext', Matches('Some[Tt]?ext'));
    %
    %   See also:
    %       regexp
    %       ContainsSubstring
    %       IsSubstringOf
    %       StartsWithSubstring
    %       EndsWithSubstring
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Expression - Regular expression the value must match to satisfy the constraint
        %
        %   The Expression property can either be a string scalar or character
        %   vector. This property is read only and can be set only through the
        %   constructor.
        Expression
    end
    
    methods
        function constraint = Matches(expression, varargin)
            % Matches - Class constructor
            %
            %   Matches(EXPRESSION) creates a constraint that is able to determine
            %   whether an actual value is a string scalar or character vector that
            %   matches the regular expression provided.
            %
            %   Matches(EXPRESSION, 'IgnoringCase', true) creates a constraint that is
            %   able to determine whether an actual value is a string scalar or
            %   character vector that matches the regular expression provided, while
            %   ignoring any differences in case.
            
            matlab.unittest.internal.validateNonemptyText(expression,'Expression');
            constraint.Expression = expression;
            constraint = constraint.parse(varargin{:});
        end
        
        function bool = satisfiedBy(constraint, actual)
            bool = isSupportedActualValue(actual) && ...
                constraint.matches(actual);
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
            
            if ~isSupportedActualValue(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                diag.addCondition(message('MATLAB:unittest:Matches:ActualMustBeASupportedType',...
                    class(actual),mat2str(size(actual))));
            elseif ~constraint.matches(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Expression);
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:RegularExpression'));
                diag.addCondition(constraint.getDiagnosticCondition('DoesNotMatchExpression'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Expression);
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:RegularExpression'));
                diag.addCondition(constraint.getDiagnosticCondition('DoesMatchExpression'));
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if ~isSupportedActualValue(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(getString(message('MATLAB:unittest:Matches:ActualIsNotASupportedType',...
                    class(actual),mat2str(size(actual)))));
            elseif ~constraint.matches(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Expression);
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:RegularExpression'));
                diag.addCondition(constraint.getDiagnosticCondition('DoesNotMatchExpression'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Expression);
                diag.ExpValHeader = getString(message('MATLAB:unittest:Matches:RegularExpression'));
                diag.addCondition(constraint.getDiagnosticCondition('DoesMatchExpression'));
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods (Access = private)
        function bool = matches(constraint, actual)
            if constraint.IgnoreCase
                caseHandling = 'ignorecase';
            else
                caseHandling = 'matchcase';
            end
            
            bool = ~isempty(regexp(actual, constraint.Expression, 'once', caseHandling));
        end
        
        function cond = getDiagnosticCondition(constraint,keyPrefix)
            if constraint.IgnoreCase
                cond = message(['MATLAB:unittest:Matches:' keyPrefix 'IgnoringCase']);
            else
                cond = message(['MATLAB:unittest:Matches:' keyPrefix]);
            end
        end
    end
end

function bool = isSupportedActualValue(value)
bool = isCharacterVector(value) || isStringScalar(value);
end

function bool = isStringScalar(value)
bool = isstring(value) && isscalar(value);
end

function bool = isCharacterVector(value)
bool = ischar(value) && (isrow(value) || strcmp(value,''));
end

% LocalWords:  Tt Sometext Someext Ttext ASupported ignorecase matchcase