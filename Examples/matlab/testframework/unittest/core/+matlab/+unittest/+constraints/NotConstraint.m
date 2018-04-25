classdef NotConstraint < matlab.unittest.constraints.BooleanConstraint & ...
                         matlab.unittest.internal.constraints.CasualDiagnosticMixin & ...
                         matlab.unittest.internal.constraints.CasualNegativeDiagnosticMixin
    % NotConstraint - Boolean complement of a constraint.
    %   A NotConstraint is produced when the "~" operator is used to denote
    %   the complement of a constraint.
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess = private)
        % Constraint that is being complemented -- must be NegatableConstraint
        Constraint
    end
    
    methods
        function notConstraint = set.Constraint(notConstraint, constraint)
            validateattributes(constraint, ...
                {'matlab.unittest.internal.constraints.NegatableConstraint'}, ...
                {'scalar'}, '', 'constraint');
            notConstraint.Constraint = constraint;
        end
    end
    
    methods (Access = {?matlab.unittest.internal.constraints.NegatableConstraint})
        function notConstraint = NotConstraint(constraint)
            % Create a new NotConstraint and store the NegatableConstraint to be negated
            notConstraint.Constraint = constraint;
        end
    end
    
    methods
        function tf = satisfiedBy(notConstraint, actual)
            tf = ~notConstraint.Constraint.satisfiedBy(actual);
        end
        
        function diag = getDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getNegativeDiagnosticFor(actual);
        end
    end
    
    methods(Hidden)
        function diag = getCasualDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getCasualNegativeDiagnosticFor(actual);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getNegativeConstraintDiagnosticFor(actual);
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getDiagnosticFor(actual);
        end
    end
    
    methods (Access = protected, Hidden)
        function diag = getCasualNegativeDiagnosticFor(notConstraint, actual)
            diag = notConstraint.Constraint.getCasualDiagnosticFor(actual);
        end        
    end
end
% LocalWords:  Negatable
