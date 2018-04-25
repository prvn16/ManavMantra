classdef IssuesWarnings < matlab.unittest.internal.constraints.WarningQualificationConstraint & ...
                          matlab.unittest.internal.mixin.RespectingSetMixin & ...
                          matlab.unittest.internal.mixin.RespectingCountMixin & ...
                          matlab.unittest.internal.mixin.RespectingOrderMixin & ...
                          matlab.unittest.internal.mixin.ExactlyMixin & ...
                          matlab.unittest.internal.constraints.CasualDiagnosticMixin
    % IssuesWarnings -  Constraint specifying a function that issues an expected warning profile
    %
    %   The IssuesWarnings constraint produces a qualification failure for any
    %   value that is not a function handle that issues a specific set of
    %   warnings. The warnings are specified and compared using warning
    %   identifiers.
    %
    %   By default, the constraint only confirms that the set of warnings
    %   specified were issued, but is agnostic to the number of times they are
    %   issued, in what order they are issued, and whether or not any
    %   unspecified warnings were issued. However, through additional
    %   parameters one can respect the order, count, and the warning set.
    %   Additionally, one can simply specify that the warning profile must
    %   match exactly. See the constructor documentation and/or the examples
    %   below in order to see how this is done.
    %
    %   The FunctionOutputs property provides access to the output arguments
    %   produced when invoking the function handle. The Nargout property
    %   specifies the number of output arguments to be returned.
    %
    %   IssuesWarnings methods:
    %       IssuesWarnings - Class constructor
    %
    %   IssuesWarnings properties:
    %       ExpectedWarnings - Cell array of expected warning identifiers
    %       FunctionOutputs  - Cell array of outputs produced when invoking the supplied function handle
    %       Nargout          - Specifies the number of outputs this instance should supply
    %       RespectSet       - Specifies whether this instance respects set elements
    %       RespectCount     - Specifies whether this instance respects element counts
    %       RespectOrder     - Specifies whether this instance respects the order of elements
    %       Exact            - Specifies whether this instance performs exact comparisons
    %
    %   Examples:
    %       import matlab.unittest.constraints.IssuesWarnings;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Helper anonymous function to aid in examples
    %       issueWarnings = @(idCell) cellfun(@(id) warning(id,'Message'), idCell);
    %
    %       % Create some ids for the examples
    %       firstID =   'first:id';
    %       secondID =  'second:id';
    %       thirdID =   'third:id';
    %
    %       % Passing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %
    %       % Simple case
    %       testCase.verifyThat(@() issueWarnings({firstID}), IssuesWarnings({firstID}));
    %
    %       % Specifying number of outputs to use when invoking the function
    %       testCase.verifyThat(@() issueWarnings({firstID}), ...
    %           IssuesWarnings({firstID}, 'WhenNargoutIs', 0));
    %
    %       % Ignores count, warning set, and order
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID, secondID}));
    %
    %       % Respects warning set
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID, secondID, thirdID}, 'RespectingSet', true));
    %
    %       % Respects warning count
    %       testCase.verifyThat(@() issueWarnings({secondID, firstID, thirdID, secondID}), ...
    %           IssuesWarnings({firstID, secondID, secondID}, 'RespectingCount', true));
    %
    %       % Respects warning order
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID, secondID, thirdID}), ...
    %           IssuesWarnings({firstID, secondID}, 'RespectingOrder', true));
    %
    %       % Requires an exact match to the expected warning profile
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID, secondID, thirdID}), ...
    %           IssuesWarnings({firstID, secondID, secondID, thirdID}, ...
    %               'Exactly', true));
    %
    %       % Access the outputs returned by the function handle
    %       issuesWarningsConstraint = IssuesWarnings({'first:id'}, 'WhenNargoutIs', 2);
    %       testCase.verifyThat(@warnWithOutput, issuesWarningsConstraint); %warnWithOutput defined below
    %       [actualOut1, actualOut2] = issuesWarningsConstraint.FunctionOutputs{:};
    %       function varargout = warnWithOutput()
    %          warning('first:id','Message');
    %          varargout = {123, 'abc'};
    %       end
    %
    %
    %       % Failing scenarios
    %       %%%%%%%%%%%%%%%%%%%%
    %       % is not a function handle
    %       testCase.fatalAssertThat(5, IssuesWarnings({firstID}));
    %
    %       % does not issue any warning
    %       testCase.assumeThat(@why, IssuesWarnings({firstID}));
    %
    %       % wrong id
    %       testCase.verifyThat(@() issueWarnings({firstID}), IssuesWarnings({secondID}));
    %
    %       % Ignores count, warning set, and order, but missing an ID
    %       testCase.verifyThat(@() issueWarnings({firstID, thirdID, secondID, firstID}), ...
    %           IssuesWarnings({firstID}));
    %
    %       % Respects warning set
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID}), ...
    %           IssuesWarnings({firstID}, 'RespectingSet', true));
    %
    %       % Respects warning count
    %       testCase.verifyThat(@() issueWarnings({firstID, firstID}), ...
    %           IssuesWarnings({firstID}, 'RespectingCount', true));
    %
    %       % Respects warning order
    %       testCase.verifyThat(@() issueWarnings({firstID, secondID}), ...
    %           IssuesWarnings({secondID, firstID}, 'RespectingOrder', true));
    %
    %       % Requires an exact match to the expected warning profile
    %       testCase.verifyThat(@() issueWarnings({firstID, firstID, secondID, firstID}), ...
    %           IssuesWarnings({firstID,  secondID, firstID, firstID }, ...
    %               'Exactly', true));
    %
    %   See also:
    %       matlab.unittest.constraints.Constraint
    %       matlab.unittest.constraints.IssuesNoWarnings
    %       matlab.unittest.constraints.Throws
    %       warning
    
    %  Copyright 2011-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % ExpectedWarnings - Cell array of expected warning identifiers
        %
        %   The ExpectedWarnings property contains a cell array of strings
        %   that describe the expected warning profile that should be issued by a
        %   supplied function handle. This profile can be interpreted in different
        %   ways depending on other properties defined on this instance
        %
        %   This property is read only and can only be set through the constructor.
        %
        %   See also:
        %       Exact
        %       RespectSet
        %       RespectOrder
        %       RespectCount
        ExpectedWarnings
    end
    
    properties(Access=private)
        ActualWarningAlerts
        ExpectedWarningSpecifications
        FunctionHandleOutputLog
        HasPassedAllChecks
    end
    
    properties(Hidden, Constant, GetAccess=private)
        ExpectedWarningsParser = createExpectedWarningsParser;
    end
    
    methods
        function constraint = IssuesWarnings(warnings, varargin)
            % IssuesWarnings - Class constructor
            %
            %   IssuesWarnings(WARNINGS) creates a constraint that is able to determine
            %   whether any value is a function handle that issues a particular set of
            %   MATLAB warnings when invoked, and produces an appropriate qualification
            %   failure if it does not. WARNINGS is specified as a cell array of
            %   warning IDs that should be produced upon invocation of the function
            %   handle. An MException is produced upon construction if WARNINGS is
            %   empty.
            %
            %   IssuesWarnings(..., 'WhenNargoutIs',NUMOUTPUTS) creates a constraint
            %   that is able to determine whether a value is a function handle that
            %   issues a particular set of MATLAB warnings when invoked with NUMOUTPUTS
            %   number of output arguments.
            %
            %   IssuesWarnings(..., 'RespectingSet',true) creates a constraint that is
            %   able to determine whether a value is a function handle that issues a
            %   particular set of MATLAB warnings. In addition to ensuring that all of
            %   the warnings specified were issued, this instance will also produce a
            %   qualification failure if any extra, unspecified warnings were issued.
            %
            %   IssuesWarnings(..., 'RespectingCount',true) creates a constraint that
            %   is able to determine whether a value is a function handle that issues a
            %   particular set of MATLAB warnings. In addition to ensuring that all of
            %   the warnings specified were issued, this instance will also produce a
            %   qualification failure if the number of times that a particular warning
            %   is issues differs from the number of times that warning is specified in
            %   WARNINGS.
            %
            %   IssuesWarnings(..., 'RespectingOrder',true) creates a constraint that
            %   is able to determine whether a value is a function handle that issues a
            %   particular set of MATLAB warnings. In addition to ensuring that all of
            %   the warnings specified were issued, this instance will also produce a
            %   qualification failure if the order of the issued warnings differs from
            %   the order the warnings are specified in WARNINGS. The order of a given
            %   set of warnings is determined by trimming the warning profiles to a
            %   profile with no repeated warnings. For example, the following warning
            %   profile:
            %
            %       {id:A, id:A, id:B, id:C, id:C, id:C, id:A, id:A, id:A}
            %
            %   is trimmed to become:
            %
            %       {id:A, id:B, id:C, id:A}
            %
            %   This trimmed profile represents the order of a given warning profile,
            %   and when this constraint is respecting order, the order of the warnings
            %   that were both issued and expected must match. Warnings issued that are
            %   not listed somewhere in the ExpectedWarnings are ignored when
            %   determining order.
            %
            %   IssuesWarnings(..., 'Exactly',true) creates a constraint that is able
            %   to determine whether a value is a function handle that issues an
            %   expected warning profile exactly.
            %
            %   See also:
            %       ExpectedWarnings
            %       Nargout
            %       Exact
            %       RespectSet
            %       RespectOrder
            %       RespectCount
            
            import matlab.unittest.internal.constraints.ExpectedAlertSpecification;
            
            warnings = validateExpectedWarnings(warnings);
            constraint.ExpectedWarnings = warnings;
            constraint.ExpectedWarningSpecifications = ExpectedAlertSpecification.fromData(warnings);
            
            constraint = constraint.parse(varargin{:});
        end
        
        
        function tf = satisfiedBy(constraint, actual)
            tf = ...
                constraint.isFunction(actual) && ...
                constraint.issuesExpectedWarnings(actual);
        end
        
        function diag = getDiagnosticFor(constraint, actual)
            diag = constraint.getConstraintDiagnosticFor(actual);
            diag.enableWarnOnUseFor(constraint);
        end
    end
    
    methods(Hidden,Sealed)
        function diag = getConstraintDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            import matlab.unittest.internal.constraints.CompositeAlertCheck;
            import matlab.unittest.internal.constraints.MissingAlertCheck;
            import matlab.unittest.internal.constraints.UnexpectedAlertCheck;
            import matlab.unittest.internal.constraints.RespectingCountCheck;
            import matlab.unittest.internal.constraints.RespectingOrderCheck;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return
            end
            
            constraint.invokeIfNeeded(actual);
            
            % Failure diag if it never issued any warnings
            if ~constraint.HasIssuedSomeWarnings
                diag = constraint.createNoWarningsIssuedDiagnostic;
                return
            end
            
            conditions = ConstraintDiagnostic.empty;
            
            if constraint.Exact
                if constraint.hasMatchedExactly()
                    % Early return since everything else will pass if exact
                    % passed
                    diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
                    subDiag = constraint.createCorrectWarningProfileDiagnostic();
                    diag.addCondition(subDiag);
                    return;
                else
                    conditions(end+1) = getString(message('MATLAB:unittest:IssuesWarnings:NotExactProfile'));
                end
            end
             
            compositeWarningChecker = CompositeAlertCheck();
            
            missingWarningCheck = MissingAlertCheck(constraint.ExpectedWarningSpecifications);
            compositeWarningChecker.addAlertCheck(missingWarningCheck);
            
            if constraint.RespectSet
                unexpectedWarningCheck = UnexpectedAlertCheck(constraint.ExpectedWarningSpecifications);
                compositeWarningChecker.addAlertCheck(unexpectedWarningCheck);
            end
            
            if constraint.RespectCount
                respectingCountCheck = RespectingCountCheck(constraint.ExpectedWarningSpecifications);
                compositeWarningChecker.addAlertCheck(respectingCountCheck);
            end
            
            if constraint.RespectOrder
                respectingOrderCheck = RespectingOrderCheck(constraint.ExpectedWarningSpecifications);
                compositeWarningChecker.addAlertCheck(respectingOrderCheck);
            end
            
            % Exhaustively check all the warnings
            for ct=1:numel(constraint.ActualWarningAlerts)
                compositeWarningChecker.check(constraint.ActualWarningAlerts(ct));
            end
            
            % Diagnostic for failure related to missing or extra warnings
            if ~missingWarningCheck.isSatisfied()
                if constraint.RespectSet
                    conditions(end+1) = constraint.createWrongWarningSetDiagnostic(...
                        missingWarningCheck.UnhitAlertSpecifications, ...
                        unexpectedWarningCheck.UnexpectedAlertSpecifications);
                else
                    conditions(end+1) = constraint.createMissingWarningsDiagnostic(...
                        missingWarningCheck.UnhitAlertSpecifications);
                end
            elseif constraint.RespectSet && ~unexpectedWarningCheck.isSatisfied()
                    conditions(end+1) = constraint.createExtraWarningsDiagnostic(...
                        unexpectedWarningCheck.UnexpectedAlertSpecifications);
            end
                      
            % Respect warning count
            if constraint.RespectCount && ~respectingCountCheck.isSatisfied()
                conditions(end+1) = constraint.createWrongWarningCountDiagnostic(...
                                    respectingCountCheck.ExpectedAlertSpecifications, ...
                                    respectingCountCheck.ExpectedAlertCounts, ...
                                    respectingCountCheck.ActualAlertCounts);
            end
            
            % Respect warning order
            if constraint.RespectOrder && ~respectingOrderCheck.isSatisfied()
                conditions(end+1) = constraint.createWrongWarningOrderDiagnostic(...
                                    respectingOrderCheck.ActualThatMatchedExpectedSpecifications);
            end
            
            if ~isempty(conditions)
                subDiag = constraint.createIncorrectWarningProfileDiagnostic();
                for ct = 1:numel(conditions)
                    subDiag.addCondition(conditions(ct));
                end
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(subDiag);
            else
                % If we've made it this far and we have no conditions then we have passed
                diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
                subDiag = constraint.createCorrectWarningProfileDiagnostic();
                diag.addCondition(subDiag);
            end
        end
    end
    
    methods (Hidden)
        function diag = getCasualDiagnosticFor(constraint, actual)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.ConstraintDiagnosticFactory;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            % get diag if actual was not a fcn
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return
            end
            
            constraint.invokeIfNeeded(actual);
            
            % Failure diag if it never issued any warnings
            if ~constraint.HasIssuedSomeWarnings
                subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, ...
                    [], ...
                    constraint.ExpectedWarningSpecifications.convertToDisplayableList());
                subDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:NoWarningsIssued'));
                subDiag.DisplayActVal = false;
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedWarning'));
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(subDiag);
                return
            end
            
            % Diagnostic for failure related to missing or extra warnings
            if ~constraint.hasMissingOrExtraWarnings()
                subDiag =  ConstraintDiagnosticFactory.generateFailingDiagnostic(...
                    constraint, DiagnosticSense.Positive, ...
                    convertAlertToDisplayableListWithFormatFrom(constraint.ExpectedWarningSpecifications, ...
                        constraint.ActualWarningAlerts), ...
                    constraint.ExpectedWarningSpecifications.convertToDisplayableList());
                subDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:UnexpectedWarning'));
                subDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualWarnings'));
                subDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedWarning'));
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(subDiag);
            else
                % If we've made it this far and we have no conditions then we have passed
                diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
                subDiag = constraint.createCorrectWarningProfileDiagnostic();
                diag.addCondition(subDiag);
            end
        end
    end
    
    methods(Hidden,Access=protected)
        
        function exception = invoke(constraint, fcn)
            exception = MException.empty;
            try
                constraint.invoke@matlab.unittest.internal.constraints.WarningQualificationConstraint(fcn);
            catch exception
            end
        end
        
        
        function processWarnings(constraint, actualWarningsIssued)
            import matlab.unittest.internal.ExpectedWarningsNotifier;
            
            import matlab.unittest.internal.constraints.CompositeAlertCheck;
            import matlab.unittest.internal.constraints.MissingAlertCheck;
            import matlab.unittest.internal.constraints.UnexpectedAlertCheck;
            import matlab.unittest.internal.constraints.RespectingCountCheck;
            import matlab.unittest.internal.constraints.RespectingOrderCheck;
            import matlab.unittest.internal.constraints.WarningAlert;
            
            constraint.ActualWarningAlerts = WarningAlert(actualWarningsIssued);
            warningsAccountedFor = actualWarningsIssued;
            
            if constraint.Exact
                passed = constraint.hasMatchedExactly();
            else
                compositeWarningChecker = CompositeAlertCheck();
                compositeWarningChecker.addAlertCheck(MissingAlertCheck(constraint.ExpectedWarningSpecifications));
                
                if constraint.RespectSet
                    compositeWarningChecker.addAlertCheck(UnexpectedAlertCheck(constraint.ExpectedWarningSpecifications));
                end
                
                if constraint.RespectCount
                    compositeWarningChecker.addAlertCheck(RespectingCountCheck(constraint.ExpectedWarningSpecifications));
                end
                
                if constraint.RespectOrder
                    compositeWarningChecker.addAlertCheck(RespectingOrderCheck(constraint.ExpectedWarningSpecifications));
                end
                                
                constraint.examineWarnings(compositeWarningChecker);
                passed = compositeWarningChecker.isSatisfied();
                
                if passed && ~constraint.RespectSet
                    mask = arrayfun(@(x)any(constraint.ExpectedWarningSpecifications.accepts(x)), ...
                            constraint.ActualWarningAlerts);
                    warningsAccountedFor = actualWarningsIssued(mask);
                end
            end
            
            constraint.HasPassedAllChecks = passed;
            
            % Broadcast which warnings were accounted for via this constraint. Warnings
            % not accounted for may be picked up by external tooling. However, expected
            % warnings and warnings that already are caught through a failure of this
            % tool are regarded as accounted for.
            ExpectedWarningsNotifier.notifyExpectedWarnings(warningsAccountedFor);
        end
    end
    
    methods(Access=private)
        function tf = hasMissingOrExtraWarnings(constraint)
            import matlab.unittest.internal.constraints.CompositeAlertCheck;
            import matlab.unittest.internal.constraints.MissingAlertCheck;
            import matlab.unittest.internal.constraints.UnexpectedAlertCheck;
            
            if constraint.Exact
                tf = constraint.hasMatchedExactly();
            else
                
                compositeWarningsChecker = CompositeAlertCheck();
                compositeWarningsChecker.addAlertCheck(MissingAlertCheck(constraint.ExpectedWarningSpecifications));
                
                if constraint.RespectSet
                    compositeWarningsChecker.addAlertCheck(UnexpectedAlertCheck(constraint.ExpectedWarningSpecifications));
                end
                
                constraint.examineWarnings(compositeWarningsChecker);
                tf = compositeWarningsChecker.isSatisfied();
            end
        end
        
        function tf = hasMatchedExactly(constraint)
            tf = (...
                numel(constraint.ActualWarningAlerts) == numel(constraint.ExpectedWarningSpecifications)) ...
                && ...
                all(...
                    arrayfun(@(x, y)(y.accepts(x)), ...
                    constraint.ActualWarningAlerts, ...
                    constraint.ExpectedWarningSpecifications)...
                );
        end
        
        function examineWarnings(constraint, warningsChecker)
            for ct = 1:numel(constraint.ActualWarningAlerts)
                if warningsChecker.isDone()
                    return;
                end
                
                warningsChecker.check(constraint.ActualWarningAlerts(ct));
            end
        end
        
        function invokeIfNeeded(constraint, actual)
            if constraint.shouldInvoke(actual)
                constraint.invokeCapturingOutput(actual);
            end
        end
        
        function invokeCapturingOutput(constraint, fcn)
            % Prevent expected warnings from being seen at the command
            % prompt when invoking the function. However, if the function
            % throws an exception, do print whatever output it produced.
            
            import matlab.unittest.internal.fevalcRespectingHotlinks;
            [constraint.FunctionHandleOutputLog, exception] = fevalcRespectingHotlinks(@()constraint.invoke(fcn));
            
            if ~isempty(exception)
                fprintf('%s', constraint.FunctionHandleOutputLog);
                rethrow(exception);
            end
        end
        
        function tf = issuesExpectedWarnings(constraint, actual)
            constraint.invokeCapturingOutput(actual);
            
            tf = ...
                constraint.HasIssuedSomeWarnings && ...
                constraint.HasPassedAllChecks;
            
            % Print the function output if a failure has been encountered.
            if ~tf
                fprintf('%s', constraint.FunctionHandleOutputLog);
            end
            
        end
        
        function diag = createNoWarningsIssuedDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            import matlab.unittest.internal.diagnostics.DiagnosticSense;
            
            subDiag = constraint.createIncorrectWarningProfileDiagnostic;
            subDiag.DisplayActVal = false;
            
            subDiag.addCondition(message('MATLAB:unittest:IssuesWarnings:NoWarningsIssued'));
            diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
            diag.addCondition(subDiag);
        end
        
        function diag = createIncorrectWarningProfileDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            diag = ConstraintDiagnostic();
            diag.DisplayConditions = true;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningProfile'));
            diag = constraint.addRespectAndIgnoreQualifiers(diag);
            diag = constraint.addActualAndExpectedWarningProfiles(diag);
        end
        
        function diag = createCorrectWarningProfileDiagnostic(constraint)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            diag = ConstraintDiagnostic();
            diag.DisplayConditions = true;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:CorrectWarningProfile'));
            diag = constraint.addRespectAndIgnoreQualifiers(diag);
            diag = constraint.addActualAndExpectedWarningProfiles(diag);
        end
        
        function diag = addRespectAndIgnoreQualifiers(constraint,diag)
            if constraint.Exact
                qualifiers = getString(message('MATLAB:unittest:IssuesWarnings:MustMatchExactly'));
            else
                qualifiers = constraint.buildRespectAndIgnoreQualifierString;
            end
            diag.Description = sprintf('%s\n%s', diag.Description, qualifiers);
        end
        
        function diag = addActualAndExpectedWarningProfiles(constraint,diag)
            diag.DisplayActVal = true;
            diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualProfile'));
            diag.ActVal = convertAlertToDisplayableListWithFormatFrom(...
                constraint.ExpectedWarningSpecifications,constraint.ActualWarningAlerts);
            diag.DisplayExpVal = true;
            diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedProfile'));
            diag.ExpVal = constraint.ExpectedWarningSpecifications.convertToDisplayableList();
        end

        function respectIgnoreStr = buildRespectAndIgnoreQualifierString(constraint)
            respectList = {};
            ignoreList = {};
            setStr = getString(message('MATLAB:unittest:IssuesWarnings:Set'));
            if (constraint.RespectSet)
                respectList{end+1} = setStr;
            else
                ignoreList{end+1} = setStr;
            end
            
            countStr = getString(message('MATLAB:unittest:IssuesWarnings:Count'));
            if (constraint.RespectCount)
                respectList{end+1} = countStr;
            else
                ignoreList{end+1} = countStr;
            end
            
            orderStr = getString(message('MATLAB:unittest:IssuesWarnings:Order'));
            if (constraint.RespectOrder)
                respectList{end+1} = orderStr;
            else
                ignoreList{end+1} = orderStr;
            end
            
            
            respectStr = '';
            if ~isempty(respectList)
                respectStr = getString(message('MATLAB:unittest:IssuesWarnings:ProfileRespects'));
                respectListStr = sprintf('\n  %s',respectList{:});
                respectStr = sprintf('%s%s\n', respectStr, respectListStr);
            end
            
            ignoreStr = '';
            if ~isempty(ignoreList)
                ignoreStr = getString(message('MATLAB:unittest:IssuesWarnings:ProfileIgnores'));
                ignoreListStr = sprintf('\n  %s',ignoreList{:});
                ignoreStr = sprintf('%s%s\n', ignoreStr, ignoreListStr);
            end
            
            respectIgnoreStr = [respectStr ignoreStr];
        end
        
        
        function diag = createWrongWarningOrderDiagnostic(constraint, actualThatMatchedExpectedSpecifications)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningOrder'));
            
            
            diag.DisplayActVal = true;
            diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualOrder'));
                      
            % when looking at the order of the actual list, the only relevant
            % warnings were those specified as expected, operate on a sublist of the
            % warnings that were actually thrown and were expected
            
            actualOrder = trimRepeatedElements(actualThatMatchedExpectedSpecifications);
            diag.ActVal = convertAlertToDisplayableListWithFormatFrom(constraint.ExpectedWarningSpecifications, actualOrder);
            
            
            diag.DisplayExpVal = true;
            diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedOrder'));
            expectedOrder = trimRepeatedElements(constraint.ExpectedWarningSpecifications);
            diag.ExpVal = expectedOrder.convertToDisplayableList();
            
        end
        
        function diag = createWrongWarningCountDiagnostic(~, expectedWarningSpecifications, expectedWarningCounts, actualWarningCounts)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            import matlab.unittest.internal.constraints.RespectingCountCheck;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningCount'));
            diag.DisplayConditions = true;
            
            for ct = 1:numel(expectedWarningSpecifications)
                thisWarning = expectedWarningSpecifications(ct);

                if expectedWarningCounts(ct) ~= actualWarningCounts(ct)
                    countDiag = ConstraintDiagnostic;
                    countDiag.DisplayDescription = true;
                    countDiag.Description = getString(message('MATLAB:unittest:IssuesWarnings:Warning', ...
                        thisWarning.toStringForDisplay));
                    countDiag.DisplayConditions = true;
                    
                    % show the actual count
                    countDiag.DisplayActVal = true;
                    countDiag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ActualCount'));
                    countDiag.ActVal = actualWarningCounts(ct);
                    
                    % Show the expected count
                    countDiag.DisplayExpVal = true;
                    countDiag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExpectedCount'));
                    countDiag.ExpVal = expectedWarningCounts(ct);
                    
                    diag.addCondition(countDiag);
                    
                end
            end
        end
        
        function diag = createMissingWarningsDiagnostic(~, missingWarningDescriptions)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningSet'));
            
            diag.DisplayActVal = true;
            diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:MissingWarnings'));
            diag.ActVal = missingWarningDescriptions.convertToDisplayableList();
        end
        
        function diag = createExtraWarningsDiagnostic(constraint, extraWarnings)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningSet'));

            extra = unsortedUnique(extraWarnings);
            diag.DisplayExpVal = true;
            diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExtraWarnings'));
            diag.ExpVal = convertAlertToDisplayableListWithFormatFrom(constraint.ExpectedWarningSpecifications, extra);
        end
        
        function diag = createWrongWarningSetDiagnostic(constraint, missingWarningDescriptions, unexpectedWarningSpecifications)
            import matlab.unittest.diagnostics.ConstraintDiagnostic;
            
            diag =  ConstraintDiagnostic;
            diag.DisplayDescription = true;
            diag.Description = getString(message('MATLAB:unittest:IssuesWarnings:WrongWarningSet'));
            
            % Use ActVal for missing warnings and ExpVal for extra warnings.
            if ~isempty(missingWarningDescriptions)
                diag.DisplayActVal = true;
                diag.ActValHeader = getString(message('MATLAB:unittest:IssuesWarnings:MissingWarnings'));
                diag.ActVal = missingWarningDescriptions.convertToDisplayableList();
            end
            
            if ~isempty(unexpectedWarningSpecifications)
                extraActualWarnings = unsortedUnique(unexpectedWarningSpecifications);
                
                diag.DisplayExpVal = true;
                diag.ExpValHeader = getString(message('MATLAB:unittest:IssuesWarnings:ExtraWarnings'));
                diag.ExpVal = convertAlertToDisplayableListWithFormatFrom(constraint.ExpectedWarningSpecifications, extraActualWarnings);
            end
        end
    end
    
end

function p = createExpectedWarningsParser
% parser only needs to be created once at class initialization time
p = inputParser;
p.addRequired('ExpectedWarnings',@iscellstr);
end

function warnings = validateExpectedWarnings(warnings)
    import matlab.unittest.constraints.IssuesWarnings;
    
    if isa(warnings,'message')
        validateattributes(warnings,{'message'}, {'nonempty','row'},'','ExpectedWarnings');
        % Ensure the messages are valid by calling getString
        arrayfun(@getString,warnings,'UniformOutput',false);
        return;
    end
    
    validateattributes(warnings,{'cell','string'},{'nonempty','row'},'','ExpectedWarnings');

    if iscell(warnings)
        IssuesWarnings.ExpectedWarningsParser.parse(warnings);
    else %string array
        if any(ismissing(warnings))
            error(message('MATLAB:unittest:StringInputValidation:InvalidStringPropertyValueMissingElement','ExpectedWarnings'));
        end
        warnings = cellstr(warnings);
    end
end

function str = convertAlertToDisplayableListWithFormatFrom(expectedSpec, actualAlert)
import matlab.unittest.internal.diagnostics.indentWithArrow;
strs = arrayfun(@(x)indentWithArrow(expectedSpec.formatForDisplay(x)), actualAlert, 'UniformOutput',false);
str = strjoin(strs, '\n');
end

% LocalWords:  abc Evalc's sublist strs Unhit ismissing
