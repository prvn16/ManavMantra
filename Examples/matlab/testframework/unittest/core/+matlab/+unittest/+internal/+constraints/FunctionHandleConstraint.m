classdef(Hidden) FunctionHandleConstraint < matlab.unittest.constraints.Constraint & handle
    % This class is undocumented and may change in a future release.
    
    %  Copyright 2011-2017 The MathWorks, Inc.
    
    properties(Constant,Access=private)
        FcnConstraint = matlab.unittest.constraints.IsInstanceOf(?function_handle);
    end
    
    properties(Access=private)
        FcnInvoked;
    end

    methods(Hidden, Access=protected)
        function diag = generateFailingFcnDiagnostic(constraint, consType)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                consType, constraint.FcnInvoked);
            diag.ActValHeader = getString(message('MATLAB:unittest:FunctionHandleConstraint:EvaluatedFunctionHandle'));
        end
        
        function diag = generatePassingFcnDiagnostic(constraint, consType)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                consType, constraint.FcnInvoked);
            diag.ActValHeader = getString(message('MATLAB:unittest:FunctionHandleConstraint:EvaluatedFunctionHandle'));
        end
        
        function varargout = invoke(constraint, fcn)
            constraint.FcnInvoked = fcn;
            [varargout{1:nargout}] = fcn();
        end
        
        function tf = isFunction(constraint, value)
            % Determine whether some value meets the def'n of being a function that can
            % be operated on by this constraint.
            
            tf = constraint.FcnConstraint.satisfiedBy(value);
        end
        
        function tf = shouldInvoke(constraint, fcn)
            % Determine whether the given actual function is the last value to be
            % invoked by this constraint.
            
            tf = isempty(constraint.FcnInvoked) || ~isequal(constraint.FcnInvoked, fcn);
        end
        
        function diag = buildIsFunctionDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
            diag.addConditionsFrom(constraint.FcnConstraint.getConstraintDiagnosticFor(actual));
        end
    end
    
end

% LocalWords:  def'n
