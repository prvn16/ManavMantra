classdef (Sealed, Hidden) AliasDecorator < matlab.unittest.internal.constraints.ConstraintDecorator
    % This class is undocumented.
    
    % AliasDecorator - Decorates Constraint's alias
    %
    %   The AliasDecorator decorates a ConstraintDiagnostic obtained from
    %   diagnosing a Constraint with an alias. The specified 'alias'
    %   replaces the default Description of the ConstraintDiagnostic. 
    %   
    %   See also
    %       matlab.unittest.internal.constraints.ConstraintDecorator
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Alias - ConstraintDiagnostic description alias
        Alias;
    end
    
    methods
        function decorator = AliasDecorator(constraint, alias)            
            decorator@matlab.unittest.internal.constraints.ConstraintDecorator(constraint);   
            validateattributes(alias, {'char'}, {'nonempty'}, '', 'Alias');
            decorator.Alias = alias;
        end
        
        function bool = satisfiedBy(decorator, varargin)
            % Pass through to decorated constraint's satisfiedBy()
            bool = decorator.Constraint.satisfiedBy(varargin{:});
        end
        
        function diags = getDiagnosticFor(decorator, varargin)                        
            diags = decorator.Constraint.getDiagnosticFor(varargin{:});
            for k = 1:numel(diags)
                diag = diags(k);
                diag.applyAlias(decorator.Alias);
                % Sanity check. ^-- will error if any constraint that is aliased returns a
                % diagnostic which not a matlab.unittest.internal.mixin.ApplyAliasMixin
            end
        end
    end        
end

