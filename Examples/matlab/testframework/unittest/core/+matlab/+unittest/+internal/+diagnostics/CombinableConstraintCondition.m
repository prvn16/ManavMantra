classdef(Hidden) CombinableConstraintCondition < matlab.unittest.internal.diagnostics.CompositeDiagnostic
    % This class is undocumented and may change in a future release

    %  Copyright 2017 The MathWorks, Inc.
    properties(Access=private)
        ConditionHeader char
        ConditionFooter char
    end
    
    methods(Hidden, Static)
        function diag = forFirstCondition(delegateDiagnostic)
            import matlab.unittest.internal.diagnostics.CombinableConstraintCondition;
            conditionHeader = getString(message('MATLAB:unittest:Constraint:FirstConditionHeader'));
            conditionFooter = '';
            diag = CombinableConstraintCondition(delegateDiagnostic, conditionHeader, conditionFooter);
        end
        
        function diag = forSecondCondition(delegateDiagnostic,conjuctionWord)
            import matlab.unittest.internal.diagnostics.CombinableConstraintCondition;
            conditionHeader = sprintf('%s\n%s',...
                conjuctionWord,...
                getString(message('MATLAB:unittest:Constraint:SecondConditionHeader')));
            conditionFooter = getString(message('MATLAB:unittest:Constraint:ConditionFooter'));
            diag = CombinableConstraintCondition(delegateDiagnostic, conditionHeader, conditionFooter);
        end
    end
    
    methods(Access=private)
        function diag = CombinableConstraintCondition(delegateDiagnostic, conditionHeader, conditionFooter)
            assert(isscalar(delegateDiagnostic)); % Sanity check
            diag.ComposedDiagnostics = delegateDiagnostic;
            diag.ConditionHeader = conditionHeader;
            diag.ConditionFooter = conditionFooter;
        end
    end
    
    methods(Hidden, Sealed, Access=protected)
        function diagText = createDiagnosticText(diag)
            indention = ' |   ';
            diagText = indent(diag.ComposedDiagnostics.FormattableDiagnosticText,indention);
            
            if ~isempty(diag.ConditionHeader)
                diagText = sprintf('%s\n%s',diag.ConditionHeader,diagText);
            end
            
            if ~isempty(diag.ConditionFooter)
                diagText = sprintf('%s\n%s',diagText,diag.ConditionFooter);
            end
        end
    end
end