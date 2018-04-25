classdef (Sealed, Hidden) CasualDiagnosticDecorator < matlab.unittest.internal.constraints.ConstraintDecorator
    % This class is undocumented.
    
    % CasualDiagnosticDecorator - Decorates Constraint's diagnostics
    %
    %   The CasualDiagnosticDecorator is a means to provide casual
    %   diagnostics from a Constraint. A Constraint announces its ability
    %   to provide casual diagnostics by mixing in CasualDiagnosticMixin
    %   and implementing getCasualDiagnosticFor(). 
    %
    %   The CasualDiagnosticDecorator is then responsible to return either
    %   casual or full/default diagnostics depending on the decorated
    %   constraint's ability.
    %   
    %   See also
    %       matlab.unittest.internal.constraints.ConstraintDecorator
    %       matlab.unittest.internal.constraints.CasualDiagnosticMixin
    
    %  Copyright 2013-2017 The MathWorks, Inc. 
    
    methods
        function decorator = CasualDiagnosticDecorator(constraint)            
            decorator@matlab.unittest.internal.constraints.ConstraintDecorator(constraint);            
        end
        
        function bool = satisfiedBy(decorator, varargin)
            % Pass through to decorated constraint's satisfiedBy()
            bool = decorator.Constraint.satisfiedBy(varargin{:});
        end
        
        function diag = getDiagnosticFor(decorator, varargin)
            import matlab.unittest.internal.diagnostics.DiagnosticSense;   
            
            % Return either a casual or full diagnostic depending on the
            % constraint's subscription
            
            % If the constraint being decorated is a NotConstraint, check
            % if the underlying constraint is capable of providing casual
            % diagnostics.
            if metaclass(decorator.Constraint) <= ?matlab.unittest.constraints.NotConstraint
                constraintToCheckForCasualDiagnostic = decorator.Constraint.Constraint;
            else
                constraintToCheckForCasualDiagnostic = decorator.Constraint;
            end
            
            mc = metaclass(constraintToCheckForCasualDiagnostic);
            if mc < ?matlab.unittest.internal.constraints.CasualDiagnosticMixin
                diag = decorator.Constraint.getCasualDiagnosticFor(varargin{:});
            elseif ~isempty(mc.MethodList.findobj('Name','getConstraintDiagnosticFor','Access','public'))
                diag = decorator.Constraint.getConstraintDiagnosticFor(varargin{:});
            else
                diag = decorator.Constraint.getDiagnosticFor(varargin{:});
            end
        end
    end        
end