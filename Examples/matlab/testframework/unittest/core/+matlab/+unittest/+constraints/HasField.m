classdef HasField < matlab.unittest.constraints.BooleanConstraint
    % HasField - Constraint specifying a structure containing the mentioned field
    %
    %    The HasField constraint produces a qualification failure for any actual argument that is a structure
    %    that does not contain the specified field or is not a structure.
    %
    %    HasField methods:
    %       HasField - Class constructor
    %
    %    HasField properties:
    %       Field - Field that a structure must have to satisfy the constraint
    %
    %    Examples:
    %       import matlab.unittest.constraints.HasField;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %       % Passing Scenarios
    %       %%%%%%%%%%%%%
    %       S1 = struct('one',[]);
    %       testCase.verifyThat(S1, HasField('one'));
    %       testCase.assumeThat(struct('Tag', 123, 'Serial', 345), HasField('Tag'));
    %
    %
    %       % Failing Scenarios
    %       %%%%%%%%%%%%%
    %       S1 = struct('one',[]);
    %       testCase.verifyThat(S1, HasField('One'));
    %       testCase.assumeThat(struct('Tag', 123, 'Serial', 345), HasField('Name'));
    %       testCase.assertThat([2 3], HasField('Name'))
    
    %  Copyright 2012-2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        % Field - Field that a structure must have to satisfy the constraint
        Field
    end
    
    methods
        
        function constraint = HasField(fieldname)
            % HasField - Class constructor
            %
            %   HasField(FIELDNAME) creates a constraint that is able to determine if
            %   the specified FIELDNAME is a field of the structure actual value.
            
            constraint.Field = fieldname;
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            tf = isfield(actual, constraint.Field);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        function constraint = set.Field(constraint,fieldname)
            matlab.unittest.internal.validateNonemptyText(fieldname,'Field');
            constraint.Field = char(fieldname);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            import matlab.unittest.internal.diagnostics.getDisplayableStringWithNoHeader;
            
            expFieldDisplay = getFieldListDisplay({constraint.Field});
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual, expFieldDisplay);
                diag.ExpValHeader = getString(message('MATLAB:unittest:HasField:ExpectedField'));
            else
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Positive, actual);
                
                if isstruct(actual)
                    if isempty(fieldnames(actual))
                        actFieldsDisplay = getString(message('MATLAB:unittest:HasField:NoField'));
                    else
                        actFieldsDisplay = getFieldListDisplay(fieldnames(actual));
                    end
                    
                    fieldDiag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                        DiagnosticSense.Positive, actFieldsDisplay, expFieldDisplay);
                    fieldDiag.Description = getString(message('MATLAB:unittest:HasField:MustHaveExpectedField'));
                    fieldDiag.ActValHeader = getString(message('MATLAB:unittest:HasField:ActualField'));
                    fieldDiag.ExpValHeader = getString(message('MATLAB:unittest:HasField:ExpectedField'));
                    diag.addCondition(fieldDiag);
                else
                    diag.addCondition(message('MATLAB:unittest:HasField:NotAStruct',class(actual)));
                end
            end
        end
    end
    
    methods(Hidden,Sealed,Access={?matlab.unittest.constraints.NotConstraint})
        function diag = getNegativeConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            expFieldDisplay = getFieldListDisplay({constraint.Field});
            
            if constraint.satisfiedBy(actual)
                diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, expFieldDisplay);
                diag.addCondition(getString(message('MATLAB:unittest:HasField:MustNotHaveField')));
            else
                diag = ConstraintDiagnosticFactory.generatePassingDiagnostic(constraint, ...
                    DiagnosticSense.Negative, actual, expFieldDisplay);
            end
            
            diag.ExpValHeader = getString(message('MATLAB:unittest:HasField:UnexpectedField'));
        end
    end
    
    methods(Access=protected)
        function diag = getNegativeDiagnosticFor(constraint, actual)
            diag = constraint.getNegativeConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
end

function d = getFieldListDisplay(fields)
import matlab.unittest.internal.diagnostics.indent;

d = indent(char(join("'" + fields + "'", newline)));
end

% LocalWords:  unittest fieldname AStruct
