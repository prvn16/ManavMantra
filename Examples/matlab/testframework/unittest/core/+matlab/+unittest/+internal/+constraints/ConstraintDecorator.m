classdef (Hidden,HandleCompatible) ConstraintDecorator < matlab.unittest.constraints.Constraint
    % This class is undocumented.
    
    % ConstraintDecorator - Interface for decorating constraints
    %
    %   The ConstraintDecorator interface provides a mechanism to decorate
    %   a Constraint to dynamically add/remove its responsibilities without
    %   affecting the behavior of other instances of the constraint.
    %
    %   Typically, a ConstraintDecorate is used to decorate the behavior of
    %   satisfiedBy() or getDiagnosticFor().
    %
    %   ConstraintDecorator implements a Constraint interface and contains
    %   a private reference to the constraint it decorates.
    %   
    %   See also
    %       matlab.unittest.constraints.Constraint
    
    %  Copyright 2013-2016 The MathWorks, Inc.
    
    properties (SetAccess = immutable)
        % Constraint - Decorated Constraint
        Constraint;
    end
    
    properties (Hidden, Dependent, SetAccess = private)
        % RootConstraint - Extracted deeply buried decorated constraint
        RootConstraint;
    end
    
    methods
        function decorator = ConstraintDecorator(constraint)
            decorator.Constraint = constraint;
        end
        
        function constraint = get.RootConstraint(decorator)
            % Dig out the decorated constraint
            constraint = decorator;
            while metaclass(constraint) < ?matlab.unittest.internal.constraints.ConstraintDecorator
                constraint = constraint.Constraint;
            end
        end
    end
end
