classdef Eventually < matlab.unittest.internal.constraints.FunctionHandleConstraint
    % Eventually - Poll for a value to asynchronously satisfy a constraint
    %
    %   The Eventually constraint produces a qualification failure for any
    %   value that is not a function handle or is a function handle that
    %   never returns a value that satisfies a provided constraint for each
    %   attempt started within a given timeout period. A constraint is
    %   required, and the timeout value is optional, with a default timeout
    %   value of 20 seconds. The drawnow function is invoked between each
    %   attempt to satisfy the provided constraint.
    %
    %   Eventually methods:
    %       Eventually - Class constructor
    %
    %   Eventually properties:
    %       FinalReturnValue - Output value produced when invoking the supplied function handle
    %       Timeout          - Specifies the maximum time to attempt to produce passing behavior
    %
    %   Examples:
    %       import matlab.unittest.constraints.Eventually;
    %       import matlab.unittest.constraints.IsGreaterThan;
    %       import matlab.unittest.constraints.IsLessThan;
    %       import matlab.unittest.TestCase;
    %
    %       % Create a TestCase for interactive use
    %       testCase = TestCase.forInteractiveUse;
    %
    %       % Simple passing example
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(10)));
    %
    %       % Simple failing example
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsLessThan(0)));
    %
    %       % Passing example with timeout
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(50), ...
    %           'WithTimeoutOf', 75), 'test diagnostic');
    %
    %       % Failing example with timeout
    %       tic;
    %       testCase.verifyThat(@toc, Eventually(IsGreaterThan(50), ...
    %           'WithTimeoutOf', 25));
    
    % Copyright 2011-2017 The MathWorks, Inc.
    
    properties(SetAccess=immutable)
        % Timeout - Specifies the maximum time to attempt to produce passing behavior
        %
        %   The Timeout property, specified through the 'WithTimeoutOf' constructor
        %   parameter, determines the amount of time (in seconds) in which attempts
        %   are made to satisfy the constraint by the actual value provided before
        %   producing a qualification failure. It has a default value of 20
        %   seconds.
        Timeout
    end
    
    properties(SetAccess=private)
        % FinalReturnValue - Output value produced when invoking the supplied function handle
        %
        %   The FinalReturnValue property stores the output that is
        %   produced when the supplied function handle is invoked.
        %
        %   This property is read only and is set when the function handle
        %   is invoked.
        FinalReturnValue = missing;
    end
    
    properties(GetAccess=private,SetAccess=immutable)
        InnerConstraint
    end
    
    properties(Access=private)
        Passed
        ElapsedTime
    end
    
    methods
        
        function constraint = Eventually(anotherConstraint, varargin)
            % Eventually - Class constructor
            %
            %   Eventually(ANOTHERCONSTRAINT) creates a constraint that is able to poll
            %   for an actual value function handle to satisfy the constraint specified
            %   in ANOTHERCONSTRAINT. It will produce an appropriate qualification
            %   failure if none of the attempts within 20 seconds produce a value that
            %   satisfies the constraint.
            %
            %   Eventually(..., 'WithTimeoutOf', TIMEOUT) creates a constraint that is
            %   able to determine whether an actual value is a function handle that
            %   returns a value that satisfies the constraint specified in
            %   ANOTHERCONSTRAINT by an attempt started within a time period specified
            %   (in seconds) via TIMEOUT.
            %
            %   See also:
            %       Timeout
            
            validateattributes(anotherConstraint,{'matlab.unittest.constraints.Constraint'},...
                {'scalar'},'','anotherConstraint');
            constraint.InnerConstraint = anotherConstraint;
            
            p = matlab.unittest.internal.strictInputParser;
            p.addParameter('WithTimeoutOf',20, ...
                @(t) validateattributes(t, {'numeric'},{'scalar','nonnegative'}, '', 'timeout'));
            p.parse(varargin{:});
            
            constraint.Timeout = p.Results.WithTimeoutOf;
        end
        
        function tf = satisfiedBy(constraint, actual)
            
            tf = constraint.isFunction(actual) && ...
                constraint.eventuallySatisfiesInnerConstraint(actual);
            
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
            
            if ~constraint.isFunction(actual)
                diag = constraint.buildIsFunctionDiagnosticFor(actual);
                return;
            end
            
            if constraint.shouldInvoke(actual)
                constraint.eventuallySatisfiesInnerConstraint(actual);
            end
            
            subDiag = constraint.InnerConstraint.getDiagnosticFor(constraint.FinalReturnValue);
            if constraint.Passed
                diag = constraint.generatePassingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(message('MATLAB:unittest:Eventually:ConstraintPassed', ...
                    num2str(constraint.ElapsedTime),num2str(constraint.Timeout)));
            else
                diag = constraint.generateFailingFcnDiagnostic(DiagnosticSense.Positive);
                diag.addCondition(message('MATLAB:unittest:Eventually:ConstraintFailed', ...
                    num2str(constraint.Timeout)));
            end
            diag.addCondition(subDiag);
        end
    end
    
    methods(Access=private)
        function tf = eventuallySatisfiesInnerConstraint(constraint, fcn)
            flushingServices = locateFlushingServices();
            timerVal = tic;
            
            % Evaluate first one time outside of the loop for performance in quickly
            % passing cases (no flushing services used if it passes right away).
            constraint.updateWithAttempt(fcn, timerVal);
            numAttempts = 1;
            
            while ~constraint.Passed && (constraint.ElapsedTime <= constraint.Timeout)
                fulfill(flushingServices);
                if numAttempts >= 10
                    pause(1);
                end
                constraint.updateWithAttempt(fcn, timerVal);
                numAttempts = numAttempts + 1;
            end
            
            tf = constraint.Passed;
        end
        
        function updateWithAttempt(constraint, fcn, timerVal)
            value = constraint.invoke(fcn);
            constraint.ElapsedTime = toc(timerVal);
            constraint.FinalReturnValue = value;
            constraint.Passed = constraint.InnerConstraint.satisfiedBy(value);
        end
    end
end

function flushingServices = locateFlushingServices
import matlab.unittest.internal.services.ServiceFactory;
import matlab.unittest.internal.services.ServiceLocator;

flushingPackage = meta.package.fromName('matlab.unittest.internal.services.flushing');
flushingServiceClass = ?matlab.unittest.internal.services.flushing.FlushingService;
locator = ServiceLocator.forPackage(flushingPackage);
serviceClasses = locator.locate(flushingServiceClass);
flushingServices = ServiceFactory.create(serviceClasses);
end

% LocalWords:  ANOTHERCONSTRAINT