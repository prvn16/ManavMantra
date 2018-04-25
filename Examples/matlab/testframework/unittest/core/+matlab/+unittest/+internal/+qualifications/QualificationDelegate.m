classdef QualificationDelegate < matlab.mixin.Copyable
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties(Abstract, Constant, Access=protected)
        Type
        
        % This private Constant property is for use in qualifyTrue, which should be
        % as performant as possible, and thus cannot pay the overhead of
        % constructing a new instance for every call. Note each subclass needs one since
        % the IsTrue constraints need different constraint alias (verifyTrue/assertTrue/etc).
        IsTrueConstraint
    end
    
        
    properties (Access = private, Transient)
        EvaluatingAdditionalDiagnostics = false;
    end
    
    methods(Abstract)
        doFail(delegate, qualificationFailedExceptionMarker);
    end
    
    methods(Static, Access=protected)
        function constraint = generateIsTrueConstraint(type)
            import matlab.unittest.internal.constraints.AliasDecorator
            
            alias = ['matlab.unittest.TestCase.', type, 'True'];
            constraint = AliasDecorator(matlab.unittest.constraints.IsTrue, alias);
        end
    end
    
    methods(Sealed)
        function pass(~, notificationData, actual, constraint, varargin)
            import matlab.unittest.qualifications.QualificationEventData;
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            import matlab.unittest.diagnostics.Diagnostic
            
            stack = dbstack('-completenames');
            marker = QualificationFailedExceptionMarker;
            diagData = notificationData.DiagnosticData;
            additionalDiagnostics = Diagnostic.empty(1,0);
            eventData = QualificationEventData(stack, actual, constraint, marker, diagData, additionalDiagnostics, varargin{:});
            notificationData.NotifyPassed(eventData);
        end
        
        function fail(delegate, notificationData, actual, constraint, varargin)
            import matlab.unittest.qualifications.QualificationEventData;
            import matlab.unittest.internal.qualifications.QualificationFailedExceptionMarker;
            import matlab.unittest.diagnostics.DiagnosticData;
            
            stack = dbstack('-completenames');
            marker = QualificationFailedExceptionMarker;
            diagData = notificationData.DiagnosticData;
            cl = onCleanup.empty(1,0);
            if ~delegate.EvaluatingAdditionalDiagnostics
                additionalDiagnostics = notificationData.OnFailureDiagnostics();
                delegate.setEvaluatingAdditionalDiagnostics(true);
                cl = onCleanup(@()setEvaluatingAdditionalDiagnostics(delegate,false));
            else
                additionalDiagnostics = matlab.unittest.diagnostics.Diagnostic.empty(1,0);
            end
            eventData = QualificationEventData(stack, actual, constraint, marker, diagData, additionalDiagnostics, varargin{:});
            
            % diagnose the onFailureDiagnostics immediately
            eventData.AdditionalDiagnosticResults;
            delete(cl);
            notificationData.NotifyFailed(eventData);
            delegate.doFail(marker);
        end
    end
    
    methods
        function qualifyThat(delegate, notificationData, actual, constraint, varargin)
            narginchk(4,5);
            
            if isa(actual, 'matlab.unittest.constraints.ActualValueProxy')
                result = actual.satisfiedBy(constraint);
            elseif isa(constraint, 'matlab.unittest.constraints.Constraint')
                result = constraint.satisfiedBy(actual);
            else
                validateattributes(constraint, {'matlab.unittest.constraints.Constraint'},{},'', 'constraint');
            end
            
            if islogical(result) && isscalar(result) && result
                if notificationData.HasPassedListener()
                    delegate.pass(notificationData, actual, constraint, varargin{:});
                end
            else
                delegate.fail(notificationData, actual, constraint, varargin{:});
            end
        end
        
        function qualifyFail(delegate, notificationData, varargin)
            import matlab.unittest.internal.constraints.FailingConstraint;
            fail = delegate.decorateConstraintAlias(FailingConstraint, 'Fail');
            delegate.qualifyThat(notificationData, [], fail, varargin{:});
        end
        
        function qualifyTrue(delegate, notificationData, actual, varargin)
            delegate.qualifyThat(notificationData, actual, delegate.IsTrueConstraint, varargin{:});
        end
        
        function qualifyFalse(delegate, notificationData, actual, varargin)
            import matlab.unittest.constraints.IsFalse;
            isFalse = delegate.decorateConstraintAlias(IsFalse, 'False');
            delegate.qualifyThat(notificationData, actual, isFalse, varargin{:});
        end
        
        function qualifyEqual(delegate, notificationData, actual, expected, varargin)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.constraints.AbsoluteTolerance;
            import matlab.unittest.constraints.RelativeTolerance;
            import matlab.unittest.internal.constraints.CasualDiagnosticDecorator
            
            % We allow optional name/value pairs plus an optional
            % diagnostic argument. Assume the last argument is a diagnostic
            % if there are an odd number of inputs. This diagnostic needs
            % to be handled separately, outside of inputParser.
            diag = {};
            if mod(nargin, 2) == 1
                diag = varargin(end);
                varargin(end) = [];
            end
            
            % Tolerance constructors handle input validation; none needed here
            p = inputParser;
            p.addParameter('AbsTol',[]);
            p.addParameter('RelTol',[]);
            p.parse(varargin{:});
            
            absTolSpecified = ~any(strcmp('AbsTol', p.UsingDefaults));
            relTolSpecified = ~any(strcmp('RelTol', p.UsingDefaults));
            
            constraint = IsEqualTo(expected);
            if absTolSpecified && relTolSpecified
                % AbsoluteTolerance "or" RelativeTolerance
                constraint = constraint.within(AbsoluteTolerance(p.Results.AbsTol) | ...
                    RelativeTolerance(p.Results.RelTol));
            elseif relTolSpecified
                % RelativeTolerance only
                constraint = constraint.within(RelativeTolerance(p.Results.RelTol));
            elseif absTolSpecified
                % AbsoluteTolerance only
                constraint = constraint.within(AbsoluteTolerance(p.Results.AbsTol));
            end
            
            constraint = delegate.decorateConstraintAlias(CasualDiagnosticDecorator(constraint), 'Equal');
            delegate.qualifyThat(notificationData, actual, constraint, diag{:});
        end
        
        function qualifyNotEqual(delegate, notificationData, actual, notExpected, varargin)
            import matlab.unittest.constraints.IsEqualTo;
            import matlab.unittest.internal.constraints.CasualDiagnosticDecorator
            
            isNotEqualTo = delegate.decorateConstraintAlias(CasualDiagnosticDecorator(~IsEqualTo(notExpected)), 'NotEqual');
            delegate.qualifyThat(notificationData, actual, isNotEqualTo, varargin{:});
        end
        
        function qualifySameHandle(delegate, notificationData, actual, expectedHandle, varargin)
            import matlab.unittest.constraints.IsSameHandleAs;
            
            isSameHandleAs = delegate.decorateConstraintAlias(IsSameHandleAs(expectedHandle), 'SameHandle');
            delegate.qualifyThat(notificationData, actual, isSameHandleAs, varargin{:});
        end
        
        function qualifyNotSameHandle(delegate, notificationData, actual, notExpectedHandle, varargin)
            import matlab.unittest.constraints.IsSameHandleAs;
            isNotSameHandleAs = delegate.decorateConstraintAlias(~IsSameHandleAs(notExpectedHandle), 'NotSameHandle');
            delegate.qualifyThat(notificationData, actual, isNotSameHandleAs, varargin{:});
        end
        
        function varargout = qualifyError(delegate, notificationData, actual, errorClassOrID, varargin)
            import matlab.unittest.constraints.Throws;
            throwsWithOutputs = Throws(errorClassOrID, 'WhenNargoutIs', nargout);
            throwsWithOutputs = delegate.decorateConstraintAlias(throwsWithOutputs, 'Error');
            delegate.qualifyThat(notificationData, actual, throwsWithOutputs, varargin{:});
            varargout = throwsWithOutputs.RootConstraint.FunctionOutputs;
        end
        
        function varargout = qualifyWarning(delegate, notificationData, actual, warningID, varargin)
            import matlab.unittest.constraints.IssuesWarnings;
            import matlab.unittest.internal.constraints.CasualDiagnosticDecorator;
            
            validateattributes(warningID,{'char','string'},{'scalartext'},'','warningID');
            issuesWarningsWithOutputs = IssuesWarnings(cellstr(warningID), 'WhenNargoutIs',nargout);
            issuesWarningsWithOutputs = delegate.decorateConstraintAlias(CasualDiagnosticDecorator(issuesWarningsWithOutputs), 'Warning');
            delegate.qualifyThat(notificationData, actual, issuesWarningsWithOutputs, varargin{:});
            varargout = issuesWarningsWithOutputs.RootConstraint.FunctionOutputs;
        end
        
        function varargout = qualifyWarningFree(delegate, notificationData, actual, varargin)
            import matlab.unittest.constraints.IssuesNoWarnings;
            issuesNoWarningsWithOutputs = IssuesNoWarnings('WhenNargoutIs',nargout);
            issuesNoWarningsWithOutputs = delegate.decorateConstraintAlias(issuesNoWarningsWithOutputs, 'WarningFree');
            delegate.qualifyThat(notificationData, actual, issuesNoWarningsWithOutputs, varargin{:});
            varargout = issuesNoWarningsWithOutputs.RootConstraint.FunctionOutputs;
        end
        
        function qualifyEmpty(delegate, notificationData, actual, varargin)
            import matlab.unittest.constraints.IsEmpty;
            isEmpty = delegate.decorateConstraintAlias(IsEmpty, 'Empty');
            delegate.qualifyThat(notificationData, actual, isEmpty, varargin{:});
        end
        
        function qualifyNotEmpty(delegate, notificationData, actual, varargin)
            import matlab.unittest.constraints.IsEmpty;
            isNotEmpty = delegate.decorateConstraintAlias(~IsEmpty, 'NotEmpty');
            delegate.qualifyThat(notificationData, actual, isNotEmpty, varargin{:});
        end
        
        function qualifySize(delegate, notificationData, actual, expectedSize, varargin)
            import matlab.unittest.constraints.HasSize;
            hasSize = delegate.decorateConstraintAlias(HasSize(expectedSize), 'Size');
            delegate.qualifyThat(notificationData, actual, hasSize, varargin{:});
        end
        
        function qualifyLength(delegate, notificationData, actual, expectedLength, varargin)
            import matlab.unittest.constraints.HasLength;
            hasLength = delegate.decorateConstraintAlias(HasLength(expectedLength), 'Length');
            delegate.qualifyThat(notificationData, actual, hasLength, varargin{:});
        end
        
        function qualifyNumElements(delegate, notificationData, actual, expectedElementCount, varargin)
            import matlab.unittest.constraints.HasElementCount;
            hasElementCount = delegate.decorateConstraintAlias(HasElementCount(expectedElementCount), 'NumElements');
            delegate.qualifyThat(notificationData, actual, hasElementCount, varargin{:});
        end
        
        function qualifyGreaterThan(delegate, notificationData, actual, floor, varargin)
            import matlab.unittest.constraints.IsGreaterThan;
            isGreaterThan = delegate.decorateConstraintAlias(IsGreaterThan(floor), 'GreaterThan');
            delegate.qualifyThat(notificationData, actual, isGreaterThan, varargin{:});
        end
        
        function qualifyGreaterThanOrEqual(delegate, notificationData, actual, floor, varargin)
            import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            isGreaterThanOrEqualTo = delegate.decorateConstraintAlias(IsGreaterThanOrEqualTo(floor), 'GreaterThanOrEqual');
            delegate.qualifyThat(notificationData, actual, isGreaterThanOrEqualTo, varargin{:});
        end
        
        function qualifyLessThan(delegate, notificationData, actual, ceiling, varargin)
            import matlab.unittest.constraints.IsLessThan;
            isLessThan = delegate.decorateConstraintAlias(IsLessThan(ceiling), 'LessThan');
            delegate.qualifyThat(notificationData, actual, isLessThan, varargin{:});
        end
        
        function qualifyLessThanOrEqual(delegate, notificationData, actual, ceiling, varargin)
            import matlab.unittest.constraints.IsLessThanOrEqualTo;
            
            isLessThanOrEqualTo = delegate.decorateConstraintAlias(IsLessThanOrEqualTo(ceiling), 'LessThanOrEqual');
            delegate.qualifyThat(notificationData, actual, isLessThanOrEqualTo, varargin{:});
        end
        
        function qualifyReturnsTrue(delegate, notificationData, actual, varargin)
            import matlab.unittest.constraints.ReturnsTrue;
            
            returnsTrue = delegate.decorateConstraintAlias(ReturnsTrue, 'ReturnsTrue');
            delegate.qualifyThat(notificationData, actual, returnsTrue, varargin{:});
        end
        
        function qualifyInstanceOf(delegate, notificationData, actual, expectedBaseClass, varargin)
            import matlab.unittest.constraints.IsInstanceOf;
            isInstanceOf = delegate.decorateConstraintAlias( IsInstanceOf(expectedBaseClass), 'InstanceOf');
            delegate.qualifyThat(notificationData, actual, isInstanceOf, varargin{:});
        end
        
        function qualifyClass(delegate, notificationData, actual, expectedClass, varargin)
            import matlab.unittest.constraints.IsOfClass;
            isOfClass = delegate.decorateConstraintAlias( IsOfClass(expectedClass), 'Class');
            delegate.qualifyThat(notificationData, actual, isOfClass, varargin{:});
        end
        
        function qualifySubstring(delegate, notificationData, actual, substring, varargin)
            import matlab.unittest.constraints.ContainsSubstring;
            containsSubstring = delegate.decorateConstraintAlias(ContainsSubstring(substring), 'Substring');
            delegate.qualifyThat(notificationData, actual, containsSubstring, varargin{:});
        end
        
        function qualifyMatches(delegate, notificationData, actual, expression, varargin)
            import matlab.unittest.constraints.Matches;
            matches = delegate.decorateConstraintAlias(Matches(expression), 'Matches');
            delegate.qualifyThat(notificationData, actual, matches, varargin{:});
        end
    end
    
    methods(Access=private)
        function constraint = decorateConstraintAlias(delegate, constraint, aliasSuffix)
            import matlab.unittest.internal.constraints.AliasDecorator
            constraint = AliasDecorator(constraint, ['matlab.unittest.TestCase.' delegate.Type, aliasSuffix]);
        end
        
        function setEvaluatingAdditionalDiagnostics(delegate, value)
            delegate.EvaluatingAdditionalDiagnostics = value;
        end
    end
end

% LocalWords:  performant completenames el Teardownable scalartext
