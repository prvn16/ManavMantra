classdef(Hidden) ActualValueProxy 
    % This class is undocumented and may change in a future release.
    
    % Copyright 2010-2017 The MathWorks, Inc.
    
    properties(SetAccess=private)
        % ActualValue - Actual value to test against constraint
        ActualValue
    end
    
    methods(Access=protected)
        function p = ActualValueProxy(actual)
            narginchk(1, 1);
            
            % Constructor takes the actual value and holds onto it for use
            % in the satisfiedBy and getDiagnosticFor methods.
            p.ActualValue = actual;
        end
    end
    
    methods(Hidden, Abstract)
        tf = satisfiedBy(proxy, constraint)
        diag = getDiagnosticFor(proxy, constraint)
    end
    
    methods(Hidden, Access = protected)
        function validateConstraint(~, constraint)
            % This should be called by subclasses to enforce that the first
            % argument to satisfiedBy and getDiagnosticFor are constraints.
            % Given we are utilizing class precedence to dispatch to the
            % proxy instead of the constraint, we should confirm no-one ever
            % calls proxy.satisfiedBy(...)
            validateattributes(constraint,{'matlab.unittest.constraints.Constraint'},{'scalar'}, '', 'constraint');
        end
    end
end