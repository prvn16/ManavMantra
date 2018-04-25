classdef IssuesNoWarnings < matlab.unittest.internal.constraints.WarningQualificationConstraint
    % IssuesNoWarnings - Constraint specifying a function that issues no warnings
    %
    %   The IssuesNoWarnings constraint produces a qualification failure for
    %   any value that is not a function handle or is a function handle that
    %   issues at least one warning.
    %
    %   The FunctionOutputs property provides access to the output arguments
    %   produced when invoking the function handle. The Nargout property
    %   specifies the number of output arguments to be returned.
    %
    %   IssuesNoWarnings methods:
    %       IssuesNoWarnings - Class constructor
    %
    %   IssuesNoWarnings properties:
    %       FunctionOutputs - Cell array of outputs produced when invoking the supplied function handle
    %       Nargout         - Specifies the number of outputs this instance should supply
    %
    %   Examples:
    %       import matlab.unittest.constraints.IssuesNoWarnings;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % Simple case
    %       testCase.verifyThat(@true, IssuesNoWarnings);
    %       testCase.verifyThat(@() size([]), IssuesNoWarnings('WhenNargoutIs', 2));
    %
    %       % Access the outputs returned by the function handle
    %       issuesNoWarningsConstraint = IssuesNoWarnings('WhenNargoutIs', 2);
    %       testCase.verifyThat(@() size([]), issuesNoWarningsConstraint);
    %       [actualOut1, actualOut2] = issuesNoWarningsConstraint.FunctionOutputs{:};
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.verifyThat(5, IssuesNoWarnings);
    %
    %       % Issues a warning
    %       testCase.verifyThat(@() warning('some:id', 'Message'), IssuesNoWarnings);
    %
    %   See also:
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.IssuesWarnings
    %       matlab.unittest.constraints.Throws
    %       warning
    
    %  Copyright 2011-2017 The MathWorks, Inc.
    
    properties(Access=private)
        ActualWarningDescriptions
    end
    
    methods
        function constraint = IssuesNoWarnings(varargin)
            % IssuesNoWarnings - Class constructor
            %
            %   IssuesNoWarnings creates a constraint that is able to determine whether
            %   an actual value is a function handle that issues no MATLAB warnings
            %   when invoked, and produces an appropriate qualification failure if
            %   warnings are issued upon function invocation.
            %
            %   IssuesNoWarnings('WhenNargoutIs',NUMOUTPUTS) creates a constraint that
            %   is able to determine whether an actual value is a function handle that
            %   issues no MATLAB warnings when invoked with NUMOUTPUTS number of output
            %   arguments.
            %
            %   See also:
            %       Nargout
            
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.issuesNoWarnings(actual);
            
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return
            end
            
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never issued any warnings
            if constraint.HasIssuedSomeWarnings
                diag = constraint.createWarningsIssuedDiagnostic;
                return
            end
            
            
            % If we've made it this far and we have no conditions then we have passed
            diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
        end
    end
    
    methods(Hidden,Access=protected)
        function processWarnings(constraint, actualWarningsIssued)
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            
            constraint.ActualWarningDescriptions = actualWarningsIssued;
            
            % Broadcast which warnings were accounted for via this constraint. Warnings
            % not accounted for may be picked up by external tooling. However, all
            % warnings thrown here are caught through a failure of this
            % tool and thus are accounted for.
            ExpectedWarningsNotifier.notifyExpectedWarnings(actualWarningsIssued);
        end
    end
    
    methods(Access=private)
        function tf = issuesNoWarnings(constraint, actual)
            constraint.invoke(actual);
            
            tf = ~constraint.HasIssuedSomeWarnings;
        end
        
        function diag = createWarningsIssuedDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                constraint, DiagnosticSense.Positive, ...
                convertToDisplayableList(constraint.ActualWarningDescriptions));
                
            subDiag.Description = getString(message('MATLAB:unittest:IssuesNoWarnings:WarningsWereIssued'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesNoWarnings:WarningsIssuedHeader'));
            
            diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
            diag.addCondition(subDiag);
        end
    end
end

function str = convertToDisplayableList(actualAlert)
import matlab.unittest.internal.diagnostics.indentWithArrow;
strs = arrayfun(@(x)indentWithArrow(getIDAndMessageStrFrom(x)), actualAlert, 'UniformOutput',false);
str = strjoin(strs, '\n');
end

function str = getIDAndMessageStrFrom(warningAlert)
import matlab.unittest.internal.constraints.IDAndMessageDiagnosticDisplayHelper;
import matlab.unittest.internal.diagnostics.getValueDisplay;

displayHelper = IDAndMessageDiagnosticDisplayHelper(...
    warningAlert.identifier, ...
    warningAlert.message);

str = char(getValueDisplay(displayHelper));
str = regexprep(str, {'^    ', '\n    '},{'','\n'});
end

% LocalWords:  strs
