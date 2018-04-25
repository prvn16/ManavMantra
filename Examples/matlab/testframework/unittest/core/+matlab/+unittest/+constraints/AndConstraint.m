classdef AndConstraint < matlab.unittest.internal.constraints.CombinableConstraint
    % AndConstraint - Boolean conjunction of two constraints.
    %   An AndConstraint is produced when the "&" operator is used to
    %   denote the conjunction of two constraints.
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Left constraint that is being AND'ed
        FirstConstraint (1,1) matlab.unittest.internal.constraints.CombinableConstraint = ...
            matlab.unittest.constraints.IsAnything;
        
        % Right constraint that is being AND'ed
        SecondConstraint (1,1) matlab.unittest.internal.constraints.CombinableConstraint = ...
            matlab.unittest.constraints.IsAnything;
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.CombinableConstraint)
        function andConstraint = AndConstraint(firstConstraint, secondConstraint)
            % This constraint holds onto two constraints and applies AND behavior.
            % Constructor requires two CombinableConstraints.
            andConstraint.FirstConstraint = firstConstraint;
            andConstraint.SecondConstraint = secondConstraint;
        end
    end
    
    methods
        function tf = satisfiedBy(andConstraint, actual)
            tf = andConstraint.FirstConstraint.satisfiedBy(actual) && ...
                andConstraint.SecondConstraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(andConstraint, actual)
            diag = andConstraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(andConstraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(andConstraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.CombinableConstraintCondition;
            
            satisfied1 = andConstraint.FirstConstraint.satisfiedBy(actual);
            satisfied2 = andConstraint.SecondConstraint.satisfiedBy(actual);
            
            if (satisfied1 && satisfied2)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    andConstraint, DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    andConstraint, DiagnosticSense.Positive);
            end
            
            diag1 = andConstraint.FirstConstraint.getDiagnosticFor(actual);
            diag2 = andConstraint.SecondConstraint.getDiagnosticFor(actual);
            
            cond1 = CombinableConstraintCondition.forFirstCondition(diag1);
            cond2 = CombinableConstraintCondition.forSecondCondition(diag2,...
                getString(message('MATLAB:unittest:Constraint:BooleanAnd')));
            
            diag.addCondition(cond1);
            diag.addCondition(cond2);
        end
    end
    
    methods (Hidden)
        function constraint = not(andConstraint)
            % Apply De Morgan's law. This will throw an error if either
            % FirstConstraint or SecondConstraint is not Negatable, which
            % is required if the AndConstraint itself is to be negated.
            constraint = ~andConstraint.FirstConstraint | ~andConstraint.SecondConstraint;
        end
    end
end

% LocalWords:  AND'ed Negatable Formattable
