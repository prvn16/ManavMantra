classdef IsInstanceOf < matlab.unittest.constraints.BooleanConstraint
    % IsInstanceOf - Constraint specifying inclusion in a given class hierarchy
    %
    %   The IsInstanceOf constraint produces a qualification failure for any
    %   actual value that does not derive from a specified MATLAB class. The
    %   expected class can be specified either by its classname as a char or by
    %   the expected meta.class instance.
    %
    %   IsInstanceOf methods:
    %       IsInstanceOf - Class constructor
    %
    %   IsInstanceOf properties:
    %       Class - The class name a value must derive from or be to satisfy the constraint
    %
    %   Examples:
    %       import matlab.unittest.constraints.IsInstanceOf;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsInstanceOf('double'));
    %       testCase.assertThat(@sin, IsInstanceOf(?function_handle));
    %
    %       classdef DerivedExample < BaseExample
    %       end
    %       testCase.assertThat(DerivedExample, IsInstanceOf(?BaseExample));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       testCase.verifyThat(5, IsInstanceOf('char'));
    %       testCase.assertThat('sin', IsInstanceOf(?function_handle));
    %
    %   See also:
    %       IsOfClass
    %       isa
    
    %  Copyright 2010-2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Class - The class name a value must derive from or be to satisfy the constraint
        Class
    end
    
    
    methods
        function constraint = IsInstanceOf(class)
            % IsInstanceOf - Class constructor
            %
            %   IsInstanceOf(CLASS) creates a constraint that is able to determine
            %   whether an actual value is an instance of a class that derives from the
            %   CLASS provided. This is not an exact class match, but rather specifies
            %   an "isa" relationship between the actual value instance and CLASS.
            %   CLASS can either be a char whose value is a fully qualified class
            %   name, or CLASS can be an instance of meta.class.
            
            constraint.Class = class;
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = isa(actual, constraint.Class);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        function constraint = set.Class(constraint, class)
            validateattributes(class, {'char', 'meta.class', 'string'}, {'nonempty'}, '', 'Class');
            
            if isa(class,'meta.class')
                validateattributes(class, {'meta.class'}, {'scalar'}, '', 'Class');
                class = class.Name;
            else
                matlab.unittest.internal.validateNonemptyText(class,'Class');
            end
            
            constraint.Class = char(class);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, constraint.Class);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsInstanceOf:ExpectedClass'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                % Use a sub-diagnostic to report the value's wrong class
                classDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, class(actual), constraint.Class);
                classDiag.Description = getString(message('MATLAB:unittest:IsInstanceOf:MustBeInstance'));
                classDiag.ActValHeader = getString(message('MATLAB:unittest:IsInstanceOf:ActualClassHeader'));
                classDiag.ExpValHeader = getString(message('MATLAB:unittest:IsInstanceOf:ExpectedClass'));
                diag.addCondition(classDiag);
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            if constraint.satisfiedBy(actual)
                
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual);
                
                % Use a sub-diagnostic to report the value's wrong class
                classDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, class(actual), constraint.Class);
                classDiag.Description = getString(message('MATLAB:unittest:IsInstanceOf:MustNotBeInstance'));
                classDiag.ActValHeader = getString(message('MATLAB:unittest:IsInstanceOf:ActualClassHeader'));
                classDiag.ExpValHeader = getString(message('MATLAB:unittest:IsInstanceOf:UnexpectedClass'));
                diag.addCondition(classDiag);
        
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, constraint.Class);
                diag.ExpValHeader = getString(message('MATLAB:unittest:IsInstanceOf:UnexpectedClass'));
            end
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
end
