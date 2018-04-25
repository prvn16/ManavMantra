classdef Throws < matlab.unittest.internal.constraints.FunctionHandleConstraint & ...
                  matlab.unittest.internal.mixin.WhenNargoutIsMixin & ...
                  matlab.unittest.internal.mixin.CausedByMixin & ...
                  matlab.unittest.internal.mixin.RespectingSetMixin & ...
                  matlab.unittest.internal.diagnostics.ErrorReportingMixin
    % Throws - Constraint specifying a function handle that throws an MException
    %
    %   The Throws constraint produces a qualification failure for any
    %   value that is not a function handle that throws a specific exception.
    %
    %   A qualification failure is always produced when the actual value
    %   provided is not a function handle or if it is a function handle that
    %   does not throw any MException.
    %
    %   If an MException is thrown by the function handle and the
    %   ExpectedException property is an error identifier, a qualification
    %   failure will occur if the actual MException thrown has a different
    %   identifier. Alternately, if the ExpectedException property is a
    %   meta.class a qualification failure will occur if the actual MException
    %   thrown does not derive from the ExpectedException.
    %
    %   If an MException is thrown with causes, a qualification failure
    %   will occur if the actual MException thrown does not contain one
    %   or more exceptions listed in the RequiredCauses property, in
    %   its cause tree. Additionally, a qualification failure will occur if
    %   the RespectSet property is true and the actual MException
    %   contains, in its cause tree, an exception which is not listed in the
    %   RequiredCauses property.
    %
    %   Throws methods:
    %       Throws - Class constructor
    %
    %   Throws properties:
    %       ExpectedException - Expected MException identifier or class
    %       Nargout           - Specifies the number of outputs this instance should supply
    %       RequiredCauses    - Lists the expected causes to look for, inside the actual cause tree
    %       RespectSet        - Specifies whether this instance respects set elements of RequiredCauses
    %
    %   Examples:
    %       import matlab.unittest.constraints.Throws;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % By identifier
    %       testCase.verifyThat(@() error('SOME:error:id','Error!'), Throws('SOME:error:id'));
    %
    %       % By class
    %       testCase.verifyThat(@() error('SOME:error:id','Error!'), Throws(?MException));
    %
    %       % With a certain number of outputs
    %       testCase.verifyThat(@() disp('hi'), Throws('MATLAB:maxlhs','WhenNargoutIs', 1));
    %
    %       % Check Causes by identifier
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id',...
    %           'CausedBy', {'causedBy:someOtherError:id'}));
    %
    %       % Check Causes by class
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id','CausedBy', ?MException));
    %
    %       % Check for no unexpected Causes
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id',...
    %           'CausedBy', {'causedBy:someOtherError:id'}, 'RespectingSet', true));
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.fatalAssertThat(5, Throws('some:id'));
    %
    %       % does not throw any exception
    %       testCase.assumeThat(@why, Throws(?MException));
    %
    %       % wrong id
    %       testCase.verifyThat(@() error('SOME:id'), Throws('OTHER:id'));
    %
    %       % wrong class type
    %       testCase.verifyThat(@testCase.fatalAssertFail, ...
    %           Throws(?matlab.unittest.qualifications.AssumptionFailedException));
    %
    %       % cause id not found
    %       testCase.verifyThat(@() error('TOP:error:id','TopLevelError!'), ...
    %           Throws('TOP:error:id','CausedBy',{'causedBy:someOtherError:id'}));
    %
    %       % cause class type not found
    %       testCase.verifyThat(@() error('TOP:error:id','TopLevelError!'), ...
    %           Throws('TOP:error:id','CausedBy',?MException));
    %
    %       % an unexpected cause was found
    %       me      = MException('TOP:error:id','TopLevelError!');
    %       causeBy = MException('causedBy:someOtherError:id','CausedByError!');
    %       me      = me.addCause(causeBy);
    %       testCase.verifyThat(@() me.throw, Throws('TOP:error:id',...
    %           'CausedBy', {}, 'RespectingSet', true));
    %
    %   See also:
    %       matlab.unittest.constraints.Constraint
    %       MException
    %       error
    
    %  Copyright 2011-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % ExpectedException - Expected MException identifier or class
        %
        %   The exception that should be thrown when supplied a function to invoke.
        %   This property is either an error identifier or a meta.class instance
        %   which describes a subclass of MException.
        %
        %   This property is read only and can only be set through the constructor.
        %
        %   See also:
        %       meta.class
        ExpectedException;
    end
    
    properties(Hidden, Constant, Access=private)
        MetaClassExceptionParser = createParser('ExpectedException',...
            @(class) isscalar(class) && class <=  ?MException);
    end
    
    properties(Access=private)
        ActualExceptionDescription;
        ExpectedExceptionSpecification;
        
        InternalRequiredCauseSpecifications = [];
    end
    
    properties(Hidden, Access=protected)
        ActualExceptionThrown = MException.empty;
    end
    
    properties(Dependent, Access=private)
        HasThrownAnException;
        HasThrownExpectedException;
        RequiredCauseSpecifications;
    end
    
    properties (Hidden, SetAccess = private)
        FunctionOutputs = cell(1,0);
    end
    
    methods
        function constraint = Throws(exception, varargin)
            % Throws - Class constructor
            %
            %   Throws(EXCEPTION) creates a constraint that is able to determine
            %   whether an actual value is a function handle that throws a particular
            %   MException when invoked, and produce an appropriate qualification
            %   failure if it does not. EXCEPTION can be an error identifier or a
            %   meta.class representing the specific type of exception that is expected
            %   to be thrown. If EXCEPTION is a meta.class, then it must represent a
            %   class that derives from MException or the constructor itself throws an
            %   MException.
            %
            %   Throws(..., 'WhenNargoutIs', NUMOUTPUTS) creates a constraint that is
            %   able to determine whether an actual value is a function handle that
            %   throws a particular MException when invoked with NUMOUTPUTS number of
            %   output arguments.
            %
            %   Throws(..., 'CausedBy', CAUSES) creates a constraint that is able to
            %   determine whether an actual value is a function handle that throws a
            %   particular MException with list of causes specified as an array of
            %   CAUSES in its cause tree.
            %
            %   Throws(..., 'CausedBy', CAUSES, 'RespectingSet',true) creates a
            %   constraint that is able to determine whether an actual value is a
            %   function handle that throws a particular MException with a list of
            %   causes specified as an array of CAUSES in its cause tree. In addition
            %   to ensuring that all of the causes specified were found in the actual
            %   cause tree, this instance will also produce a qualification failure if
            %   any extra, unspecified cause is found.
            
            import matlab.unittest.internal.constraints.ExpectedAlertSpecification;
            
            exception = validateExpectedException(exception);
            constraint.ExpectedException = exception;
            constraint.ExpectedExceptionSpecification = ExpectedAlertSpecification.fromData(exception);
            
            constraint = constraint.parse(varargin{:});
        end
        
        function tf = satisfiedBy(constraint, actual)
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.throwsExpectedException(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
        
        % get methods -----------------------------------------------------
        function tf = get.HasThrownExpectedException(constraint)
            tf = constraint.ExpectedExceptionSpecification.accepts(constraint.ActualExceptionDescription);
        end
        
        function tf = get.HasThrownAnException(constraint)
            % Check to see if an error was thrown
            tf = ~isempty(constraint.ActualExceptionThrown);
        end
        
        function reqDescs = get.RequiredCauseSpecifications(constraint)
            import matlab.unittest.internal.constraints.ExpectedAlertSpecification;
            
            if isempty(constraint.InternalRequiredCauseSpecifications)
                constraint.InternalRequiredCauseSpecifications = ExpectedAlertSpecification.fromData(constraint.RequiredCauses);
            end
            reqDescs = constraint.InternalRequiredCauseSpecifications;
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % Failure diag if it's not a function
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return;
            end
            
            % We need to invoke in this method in two scenarios
            %   1) satisfiedBy has not yet been called
            %   2) the last time satisfiedBy was called was for a "different"
            %      function handle
            if constraint.shouldInvoke(actual)
                constraint.invoke(actual);
            end
            
            % Failure diag if it never threw an exception
            if ~constraint.HasThrownAnException
                subDiag = constraint.createNoExceptionThrownDiagnostic();
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(subDiag);
                return;
            end
            
            % Failure diag if it did not throw the expected (top level) exception
            if ~constraint.HasThrownExpectedException
                diag = constraint.createBaseFailureDiagnostic(actual);
                diag.addCondition(constraint.createWrongExceptionDiagnostic);
                diag.addCondition(constraint.createActualErrorReportDiagnostic);
                return;
            end
            
            %Failure diag if the cause tree did not validate
            subDiags = constraint.getAllCauseTreeDiagnostics();
            if ~isempty(subDiags) %Passing case
                diag = constraint.createBaseFailureDiagnostic(actual);
                diag = constraint.addActualErrorStructureToDiag(diag);
                for k=1:length(subDiags)
                    diag.addCondition(subDiags{k});
                end
                diag.addCondition(constraint.createActualErrorReportDiagnostic);
                return;
            end
            
            %Passing case
            diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
            diag.DisplayExpVal = true;
            diag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedException'));
            diag.ExpVal = constraint.ExpectedExceptionSpecification.toStringForDisplay();
        end
    end
    
    methods(Hidden,Access=protected)
        function constraint = causedByPostSet(constraint)
            constraint.InternalRequiredCauseSpecifications = [];
        end
        
        function invoke(constraint,fcn)
            import matlab.unittest.internal.constraints.ExceptionAlert;
            % Function which actually invokes the function to observe errors
            
            [constraint.FunctionOutputs{1:constraint.Nargout}] = deal(missing);
            constraint.ActualExceptionThrown = MException.empty;
            
            try
                [constraint.FunctionOutputs{:}] = constraint.invoke@matlab.unittest.internal.constraints.FunctionHandleConstraint(fcn);
            catch ex
                constraint.ActualExceptionThrown = ex;
            end
            
            constraint.ActualExceptionDescription = ExceptionAlert(constraint.ActualExceptionThrown);
        end
        
        function trimmed = createTrimmedException(~, exception)
            trimmed = matlab.unittest.internal.TrimmedForThrowsException(exception);
        end
    end
    
    methods(Access=private)
        function tf = throwsExpectedException(constraint, actual)
            % invoke the function to see whether it throws any exception
            constraint.invoke(actual);
            
            tf = ...
                constraint.HasThrownAnException && ...
                constraint.HasThrownExpectedException && ...
                constraint.causeTreeValidationPasses();
        end
        
        % Cause Tree Validation Helpers -----------------------------------
        function tf = causeTreeValidationPasses(constraint)
            import matlab.unittest.internal.constraints.CompositeAlertCheck;
            import matlab.unittest.internal.constraints.MissingAlertCheck;
            import matlab.unittest.internal.constraints.UnexpectedAlertCheck;
            
            reqDescs = constraint.RequiredCauseSpecifications;
            
            causeChecker = CompositeAlertCheck();
            causeChecker.addAlertCheck(MissingAlertCheck(reqDescs));
            if constraint.RespectSet
                causeChecker.addAlertCheck(UnexpectedAlertCheck(reqDescs));
            end
            
            constraint.examineCauseTree(constraint.ActualExceptionThrown.cause,causeChecker);
            
            tf = causeChecker.isSatisfied();
        end
        
        function subDiags = getAllCauseTreeDiagnostics(constraint)
            import matlab.unittest.internal.constraints.CompositeAlertCheck;
            import matlab.unittest.internal.constraints.MissingAlertCheck;
            import matlab.unittest.internal.constraints.UnexpectedAlertCheck;
            
            reqDescs = constraint.RequiredCauseSpecifications;
            
            causeChecker = CompositeAlertCheck();
            missingCheck = MissingAlertCheck(reqDescs);
            causeChecker.addAlertCheck(missingCheck);
            if constraint.RespectSet
                unexpectedCheck = UnexpectedAlertCheck(reqDescs);
                causeChecker.addAlertCheck(unexpectedCheck);
            end
            
            constraint.examineCauseTreeExhaustively(constraint.ActualExceptionThrown.cause,causeChecker);
            
            subDiags = cell(1,0);
            
            missingCauseDescriptions = missingCheck.UnhitAlertSpecifications;
            if ~isempty(missingCauseDescriptions)
                subDiags{end+1} = constraint.createDiagnosticForMissingExpectedCauses(missingCauseDescriptions);
            end
            
            if constraint.RespectSet
                unexpectedCauseSpecifications = unsortedUnique(unexpectedCheck.UnexpectedAlertSpecifications);
                if ~isempty(unexpectedCauseSpecifications)
                    subDiags{end+1} = constraint.createDiagnosticForUnexpectedCauses(unexpectedCauseSpecifications);
                end
            end
        end
        
        function examineCauseTree(constraint,causes,causeChecker)
            import matlab.unittest.internal.constraints.ExceptionAlert;
            for k=1:numel(causes)
                if causeChecker.isDone
                    return;
                end
                
                causeDescription = ExceptionAlert(causes{k});
                causeChecker.check(causeDescription);
                
                constraint.examineCauseTree(causes{k}.cause,causeChecker);
            end
        end
        
        function examineCauseTreeExhaustively(constraint, causes, causeChecker)
            import matlab.unittest.internal.constraints.ExceptionAlert;
            for k=1:numel(causes)
                
                causeDescription = ExceptionAlert(causes{k});
                causeChecker.check(causeDescription);
                
                constraint.examineCauseTreeExhaustively(causes{k}.cause,causeChecker);
            end
        end
        
        % Diagnostic Helpers ----------------------------------------------
        function subDiag = createNoExceptionThrownDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            subDiag = ConstraintDiagnostic;
            subDiag.DisplayDescription = true;
            subDiag.Description = getString(message('MATLAB:unittest:Throws:NoExceptionThrown'));
            subDiag.DisplayExpVal = true;
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedException'));
            subDiag.ExpVal = constraint.ExpectedExceptionSpecification.toStringForDisplay();
        end
        
        function subDiag = createWrongExceptionDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, constraint.ExpectedExceptionSpecification.formatForDisplay(constraint.ActualExceptionDescription), ...
                constraint.ExpectedExceptionSpecification.toStringForDisplay);
            subDiag.Description = getString(message('MATLAB:unittest:Throws:WrongException'));
            subDiag.ActValHeader = getString(message('MATLAB:unittest:Throws:ActualException'));
            subDiag.ExpValHeader = getString(message('MATLAB:unittest:Throws:ExpectedException'));
        end
        
        function diag = createBaseFailureDiagnostic(constraint,actual)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            diag = ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, actual);
            diag.ActValHeader = getString(message('MATLAB:unittest:FunctionHandleConstraint:EvaluatedFunctionHandle'));
        end
        
        function diag = createActualErrorReportDiagnostic(constraint)
            import matlab.unittest.internal.diagnostics.FormattableStringDiagnostic;
            
            diag = FormattableStringDiagnostic(sprintf('%s\n%s', ...
                getString(message('MATLAB:unittest:Throws:ActualErrorReport')), ...
                indent(constraint.getExceptionReport(constraint.ActualExceptionThrown))));
        end
        
        function subDiag = createDiagnosticForMissingExpectedCauses(constraint,missingCauseDescriptions)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, '');
            subDiag.DisplayActVal = false;
            subDiag.Description = getString(message('MATLAB:unittest:Throws:MissingCauseException'));
            
            for desc = missingCauseDescriptions
                subDiag.addCondition(desc.toStringForDisplay);
            end
        end
        
        function subDiag = createDiagnosticForUnexpectedCauses(constraint,UnexpectedAlertSpecifications)
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(constraint, ...
                DiagnosticSense.Positive, '');
            subDiag.DisplayActVal = false;
            subDiag.Description = getString(message('MATLAB:unittest:Throws:UnexpectedCauseException'));
            
            for desc = UnexpectedAlertSpecifications
                subDiag.addCondition(constraint.RequiredCauseSpecifications.formatForDisplay(desc));
            end
        end
        
        function diag = addActualErrorStructureToDiag(constraint,diag)
            import matlab.unittest.internal.diagnostics.indent;
            
            ActStructureHeader = getString(message('MATLAB:unittest:Throws:ActualErrorStructure'));
            treeStr = getErrorTreeStructureString(constraint.ActualExceptionThrown);
            ActStructureVal = indent(treeStr);
            diag.ActValHeader = sprintf('%s\n%s\n\n%s',ActStructureHeader,ActStructureVal,diag.ActValHeader);
        end
    end
end


function treeStr = getErrorTreeStructureString(exception)
import matlab.unittest.internal.diagnostics.indentWithArrow;

treeStr = exceptionToClassAndIDString(exception);

for k=1:numel(exception.cause)
    cause = exception.cause{k};
    subTreeStr = indentWithArrow(getErrorTreeStructureString(cause));
    treeStr = sprintf('%s\n%s',treeStr,subTreeStr);
end
end


function str = exceptionToClassAndIDString(exception)
import matlab.unittest.internal.constraints.ExceptionAlert;
import matlab.unittest.internal.constraints.ClassSpecification;
import matlab.unittest.internal.constraints.IDSpecification;

str = sprintf('%s %s', ...
    ClassSpecification.formatForDisplay(ExceptionAlert(exception)), ...
    IDSpecification.formatForDisplay(ExceptionAlert(exception)));
end


function exception= validateExpectedException(exception)
import matlab.unittest.constraints.Throws;

if isa(exception,'message')
    validateattributes(exception,{'message'},{'scalar'},'','ExpectedException');
    % Validate message object by calling getString
    getString(exception);
    return;
end

validateattributes(exception,{'char','meta.class','string'},{},'','ExpectedException');

if ischar(exception)
    szAttrs = {'row'};
    if isempty(exception)
        szAttrs = {};
    end
    validateattributes(exception,{'char'},szAttrs,'','ExpectedException');
elseif isa(exception, 'meta.class')
    % Validate meta.class object with constant property (for performance)
    Throws.MetaClassExceptionParser.parse(exception);
else %string
    validateattributes(exception,{'string'},{'scalar'},'','ExpectedException');
    if ismissing(exception)
        error(message('MATLAB:unittest:StringInputValidation:InvalidStringPropertyValueMissingElement','ExpectedException'));
    end
    exception = char(exception);
end
end


function p = createParser(inpName,validationFunc)
p = inputParser();
p.addRequired(inpName,validationFunc);
end

% LocalWords:  maxlhs Diags Descs Unhit sz Attrs inp Func Formattable
