classdef OrConstraint < matlab.unittest.internal.constraints.CombinableConstraint
    % OrConstraint - Boolean disjunction of two constraints.
    %   An OrConstraint is produced when the "|" operator is used to denote
    %   the disjunction of two constraints.
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Left constraint that is being OR'ed
        FirstConstraint (1,1) matlab.unittest.internal.constraints.CombinableConstraint = ...
            matlab.unittest.constraints.IsAnything;
        
        % Right constraint that is being OR'ed
        SecondConstraint (1,1) matlab.unittest.internal.constraints.CombinableConstraint = ...
            matlab.unittest.constraints.IsAnything;
    end
    
    methods (Access = ?matlab.unittest.internal.constraints.CombinableConstraint)
        function orConstraint = OrConstraint(firstConstraint, secondConstraint)
            % This constraint holds onto two constraints and applies OR behavior.
            % Constructor requires two CombinableConstraints.
            orConstraint.FirstConstraint = firstConstraint;
            orConstraint.SecondConstraint = secondConstraint;
        end
    end
    
    methods
        function tf = satisfiedBy(orConstraint, actual)
            tf = orConstraint.FirstConstraint.satisfiedBy(actual) || ...
                orConstraint.SecondConstraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(orConstraint, actual)
            diag = orConstraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(orConstraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(orConstraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.CombinableConstraintCondition;
            
            satisfied1 = orConstraint.FirstConstraint.satisfiedBy(actual);
            satisfied2 = orConstraint.SecondConstraint.satisfiedBy(actual);
            
            if (satisfied1 || satisfied2)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(...
                    orConstraint, DiagnosticSense.Positive);
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    orConstraint, DiagnosticSense.Positive);
            end
            
            diag1 = orConstraint.FirstConstraint.getDiagnosticFor(actual);
            diag2 = orConstraint.SecondConstraint.getDiagnosticFor(actual);
            
            cond1 = CombinableConstraintCondition.forFirstCondition(diag1);
            cond2 = CombinableConstraintCondition.forSecondCondition(diag2,...
                getString(message('MATLAB:unittest:Constraint:BooleanOr')));
            
            diag.addCondition(cond1);
            diag.addCondition(cond2);
        end
    end
    
    methods (Hidden)
        function constraint = not(orConstraint)
            % Apply De Morgan's law. This will throw an error if either
            % FirstConstraint or SecondConstraint is not Negatable, which
            % is required if the OrConstraint itself is to be negated.
            constraint = ~orConstraint.FirstConstraint & ~orConstraint.SecondConstraint;
        end
    end
end

% LocalWords:  OR'ed Negatable Formattable