classdef(Hidden) SubstringConstraint < matlab.unittest.constraints.BooleanConstraint & ...
                                       matlab.unittest.internal.mixin.IgnoringCaseMixin & ...
                                       matlab.unittest.internal.mixin.IgnoringWhitespaceMixin
    % This class is undocumented and may change in a future release.
    
    % SubstringConstraint is implemented to avoid duplication of code
    % between ContainsSubstring, IsSubstringOf, EndsWithSubstring, 
    % and StartsWithSubstring.
    
    %  Copyright 2016-2017 The MathWorks, Inc.
   
    properties (Hidden, GetAccess = protected, SetAccess = immutable)
        ExpectedValue
    end
    
    properties(Abstract,Hidden,Constant,GetAccess=protected)
        PropertyName
    end
    
    methods(Abstract, Hidden, Access=protected)
        catalog = getMessageCatalog(constraint)
        bool = satisfiedByText(constraint, text)
    end
    
    methods
        function constraint = SubstringConstraint(expectedValue, varargin)
            matlab.unittest.internal.validateNonemptyText(expectedValue,constraint.PropertyName);
            constraint.ExpectedValue = expectedValue;
            constraint = constraint.parse(varargin{:});
        end
    end
    
    methods(Sealed)
        function bool = satisfiedBy(constraint, actual)
            bool = isSupportedActualValue(actual) && ...
                constraint.satisfiedByText(actual);
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
            catalog = constraint.getMessageCatalog();
            
            if ~isSupportedActualValue(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                diag.addCondition(catalog.getString('ActualMustBeASupportedType',...
                    class(actual),mat2str(size(actual))));
            elseif ~constraint.satisfiedByText(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.ExpectedValue);
                diag.ExpValHeader = catalog.getString('ExpectedValueHeader');
                diag.addCondition(constraint.getDiagnosticCondition('NotSatisfiedByText'));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.ExpectedValue);
                diag.ExpValHeader = catalog.getString('ExpectedValueHeader');
                diag.addCondition(constraint.getDiagnosticCondition('SatisfiedByText'));
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            catalog = constraint.getMessageCatalog();
            
            if ~isSupportedActualValue(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                diag.addCondition(catalog.getString('ActualIsNotASupportedType',...
                    class(actual),mat2str(size(actual))));
            elseif ~constraint.satisfiedByText(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.ExpectedValue);
                diag.ExpValHeader = catalog.getString('ProhibitedValueHeader');
                diag.addCondition(constraint.getDiagnosticCondition('NotSatisfiedByText'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.ExpectedValue);
                diag.ExpValHeader = catalog.getString('ProhibitedValueHeader');
                diag.addCondition(constraint.getDiagnosticCondition('SatisfiedByText'));
            end
        end
    end
    
    methods(Sealed,Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods (Access = private)       
        function cond = getDiagnosticCondition(constraint,keyPrefix)
            catalog = constraint.getMessageCatalog();
            
            if constraint.IgnoreWhitespace && constraint.IgnoreCase
                cond = catalog.getString([keyPrefix 'IgnoringCaseAndWhitespace']);
            elseif constraint.IgnoreWhitespace
                cond = catalog.getString([keyPrefix 'IgnoringWhitespace']);
            elseif constraint.IgnoreCase
                cond = catalog.getString([keyPrefix 'IgnoringCase']);
            else
                cond = catalog.getString(keyPrefix);
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

% LocalWords:  lon ASupported isstring
