classdef FatalAssertable < matlab.mixin.Copyable & matlab.unittest.internal.DiagnosticDataMixin
    % FatalAssertable - Qualification which aborts test execution.
    %
    %   The FatalAssertable class is the means by which matlab.unittest fatal
    %   assertions are produced. Apart from actions performed in the event of
    %   failures, the FatalAssertable class has equivalent functionality to all
    %   matlab.unittest qualifications.
    %
    %   Upon a fatal assertion failure, the FatalAssertable class informs the
    %   testing framework of the failure by throwing a FatalAssertionFailedException.
    %   The test running framework then displays diagnostic information for the
    %   failure and then aborts the entire test session. This is most useful
    %   when a failure at the fatal assertion point renders the remainder of
    %   the current test method invalid and the state is unrecoverable. Often,
    %   fatal assertions are used in fixture teardown in order to guarantee the
    %   fixture state is restored correctly. If it is not restored the full
    %   testing session will abort and MATLAB should be restarted prior to
    %   resuming testing in order to maintain a consistent MATLAB state. If the
    %   fixture teardown is recoverable and can be made exception safe in the
    %   event of failure, consider using assertions instead.
    %
    %   The primary benefit of fatal assertions is to prevent false test
    %   failures due to the failure of a prior test and its inability to
    %   restore test fixtures. In this event, MATLAB can be restarted to help
    %   ensure testing can resume in a clean state.
    %
    %   FatalAssertable events:
    %       FatalAssertionFailed - Event triggered upon a failing fatal assertion
    %       FatalAssertionPassed - Event triggered upon a passing fatal assertion
    %
    %   FatalAssertable methods:
    %       fatalAssertFail - Produce an unconditional fatal assertion failure
    %       fatalAssertThat - Fatally assert that a value meets a given constraint
    %       fatalAssertTrue - Fatally assert that a value is true
    %       fatalAssertFalse - Fatally assert that a value is false
    %       fatalAssertEqual - Fatally assert the equality of a value to an expected
    %       fatalAssertNotEqual - Fatally assert a value is not equal to an expected
    %       fatalAssertSameHandle - Fatally assert two values are handles to the same instance
    %       fatalAssertNotSameHandle - Fatally assert a value isn't a handle to some instance
    %       fatalAssertError - Fatally assert a function throws a specific exception
    %       fatalAssertWarning - Fatally assert a function issues a specific warning
    %       fatalAssertWarningFree - Fatally assert a function issues no warnings
    %       fatalAssertEmpty - Fatally assert a value is empty
    %       fatalAssertNotEmpty - Fatally assert a value is not empty
    %       fatalAssertSize - Fatally assert a value has an expected size
    %       fatalAssertLength - Fatally assert a value has an expected length
    %       fatalAssertNumElements - Fatally assert a value has an expected element count
    %       fatalAssertGreaterThan - Fatally assert a value is larger than some floor
    %       fatalAssertGreaterThanOrEqual - Fatally assert a value is equal or larger than some floor
    %       fatalAssertLessThan - Fatally assert a value is less than some ceiling
    %       fatalAssertLessThanOrEqual - Fatally assert a value is equal or smaller than some ceiling
    %       fatalAssertReturnsTrue - Fatally assert a function returns true when evaluated
    %       fatalAssertInstanceOf - Fatally assert a value "isa" expected type
    %       fatalAssertClass - Fatally assert the exact class of some value
    %       fatalAssertSubstring - Fatally assert a string contains an expected string
    %       fatalAssertMatches - Fatally assert a string matches a regular expression
    %
    %
    %   See also
    %       Assertable
    %       Assumable
    %       Verifiable
    %       matlab.unittest.TestCase
    %
    
    % Copyright 2010-2017 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        % FatalAssertionFailed - Event triggered upon a failing fatal assertion.
        %   The FatalAssertionFailed event provides a means to observe and react to
        %   failing fatal assertions. Callback functions listening to the event
        %   receive information about the failing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        FatalAssertionFailed;
        
        % FatalAssertionPassed - Event triggered upon a passing fatal assertion.
        %   The FatalAssertionPassed event provides a means to observe and
        %   react to passing fatal assertion. Callback functions listening
        %   to the event receive information about the passing
        %   qualification including the actual value, constraint applied,
        %   diagnostic result and stack information in the form of
        %   QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        FatalAssertionPassed;
    end
    
    properties(Access=private)
        FatalAssertionDelegate (1,1) matlab.unittest.internal.qualifications.FatalAssertionDelegate;        
    end
    
    properties (Transient,Access=private)
        FatalAssertionOnFailureTasks matlab.unittest.internal.Task;
    end
    
    methods(Sealed)
        
        function fatalAssertFail(fatalAssertable, varargin)
            % fatalAssertFail - Produce an unconditional fatal assertion failure
            %
            %   fatalAssertFail(FATALASSERTABLE) produces an unconditional fatal
            %   assertion failure when encountered. FATALASSERTABLE is the instance
            %   which is used to fail the fatal assertion in conjunction with the test
            %   running framework.
            %
            %   fatalAssertFail(FATALASSERTABLE, DIAGNOSTIC) also provides diagnostic
            %   information in DIAGNOSTIC for the failure. DIAGNOSTIC can be a string,
            %   a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   An example of where this method may be used is in a callback function
            %   that should *NOT* be executed in a given scenario. A test can confirm
            %   this does not occur by unconditionally performing a failure if the code
            %   path is reached.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Assume a handle class "MyHandle" with a "SomethingHappened" event
            %       classdef MyHandle < handle
            %           events
            %               SomethingHappened
            %           end
            %       end
            %
            %       %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %       % inside of a TestCase class
            %       methods(Test)
            %           function testDisabledListeners(testCase)
            %
            %               h = MyHandle;
            %
            %               % Add a listener to a test helper method
            %               listener = h.addlistener('SomethingHappened', ...
            %                   @testCase.shouldNotGetCalled);
            %
            %               % Passing scenario (code path is not reached)
            %               %%%%%%%%%%%%%%%%%%%%
            %               % Disabled listener should not invoke callbacks
            %               listener.Enabled = false;
            %               h.notify('SomethingHappened');
            %
            %               % Failing scenario (code path is reached)
            %               %%%%%%%%%%%%%%%%%%%%
            %               % Enabled listener invoke callback and fail
            %               listener.Enabled = true;
            %               h.notify('SomethingHappened');
            %           end
            %       end
            %
            %       methods
            %           function shouldNotGetCalled(testCase, src, evd)
            %               % A test helper callback method that should not execute
            %               testCase.fatalAssertFail('This callback should not have executed');
            %           end
            %       end
            %
            %   See also
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFail(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                varargin{:});
        end
        
        function fatalAssertThat(fatalAssertable, actual, constraint, varargin)
            % fatalAssertThat - Fatally assert that a value meets a given constraint
            %
            %   fatalAssertThat(FATALASSERTABLE, ACTUAL, CONSTRAINT) fatally asserts
            %   that ACTUAL is a value that satisfies the CONSTRAINT provided. If the
            %   constraint is not satisfied, a fatal assertion failure is produced
            %   utilizing only the diagnostic generated by the CONSTRAINT.
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertThat(FATALASSERTABLE, ACTUAL, CONSTRAINT, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation. When using this
            %   signature, both the diagnostic information contained within DIAGNOSTIC
            %   is used in addition to the diagnostic information provided by the
            %   CONSTRAINT.
            %
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       import matlab.unittest.constraints.IsTrue;
            %       testCase.fatalAssertThat(true, IsTrue);
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       testCase.fatalAssertThat(5, IsEqualTo(5), '5 should be equal to 5');
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.HasNaN;
            %       testCase.fatalAssertThat([5 NaN], IsGreaterThan(10) | HasNaN, ...
            %           'The value was not greater than 10 or NaN');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       import matlab.unittest.constraints.AnyCellOf;
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       testCase.fatalAssertThat( AnyCellOf({'cell','of','strings'}), ...
            %           ContainsSubstring('char'),'Test description');
            %
            %       import matlab.unittest.constraints.HasSize;
            %       testCase.fatalAssertThat(zeros(10,4,2), HasSize([10,5,2]), ...
            %           @() disp('A function handle diagnostic.'));
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       testCase.fatalAssertThat(5, IsEmpty);
            %
            %   See also
            %       matlab.unittest.constraints.Constraint
            %       matlab.unittest.constraints
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyThat(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, constraint, ...
                varargin{:});
        end
        
        function fatalAssertTrue(fatalAssertable, actual, varargin)
            % fatalAssertTrue - Fatally assert that a value is true
            %
            %   fatalAssertTrue(FATALASSERTABLE, ACTUAL) fatally asserts that ACTUAL is
            %   a scalar logical with the value of true. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IsTrue;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsTrue());
            %
            %   However, this method is optimized for performance and does not
            %   construct a new IsTrue constraint for each call. Sometimes such use can
            %   come at the expense of less diagnostic information. Use the
            %   fatalAssertReturnsTrue method for a similar approach which may provide
            %   better diagnostic information.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsTrue constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertTrue(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   It is important to note that this method will pass if and only if the
            %   actual value is a scalar logical with a value of true. Therefore,
            %   entities such as true valued arrays and non-zero doubles will produce
            %   qualification failures when used in this method, despite these entities
            %   exhibiting "true-like" behavior such as triggering the execution of
            %   code inside of "if" statements.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertTrue(true);
            %       testCase.fatalAssertTrue(true, 'true should be true');
            %       % Optimized comparison that trades speed for less diagnostics
            %       testCase.fatalAssertTrue(contains('string', 'ring'), ...
            %           'Could not find expected string');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertTrue(false);
            %       testCase.fatalAssertTrue(1, 'A double value of 1 is not true');
            %       testCase.fatalAssertTrue([true true true], ...
            %           'An array of logical trues are not the one true value');
            %
            %   See also
            %       matlab.unittest.constraints.IsTrue
            %       fatalAssertThat
            %       fatalAssertFalse
            %       fatalAssertReturnsTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyTrue(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertFalse(fatalAssertable, actual, varargin)
            % fatalAssertFalse - Fatally assert that a value is false
            %
            %   fatalAssertFalse(FATALASSERTABLE, ACTUAL) fatally asserts that ACTUAL
            %   is a scalar logical with the value of false. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsFalse;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsFalse());
            %
            %   Unlike fatalAssertTrue, this method may create a new constraint for
            %   each call. For performance critical uses, consider using
            %   fatalAssertTrue.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsFalse constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertFalse(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   It is important to note that this method will pass if and only if the
            %   actual value is a scalar logical with a value of false. Therefore,
            %   entities such as empty arrays, false valued arrays and zero doubles
            %   will produce qualification failures when used in this method, despite
            %   these entities exhibiting "false-like" behavior such as bypassing the
            %   execution of code inside of "if" statements.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertFalse(false);
            %       testCase.fatalAssertFalse(false, 'false should be false');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertFalse(true);
            %       testCase.fatalAssertFalse(0, 'A double with a value of 0 is not false');
            %       testCase.fatalAssertFalse([false true false], ...
            %           'A mixed array of logicals is not the one false value');
            %       testCase.fatalAssertFalse([false false false], ...
            %           'A false array is not the one false value');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsFalse
            %       fatalAssertThat
            %       fatalAssertTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFalse(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertEqual(fatalAssertable, actual, expected, varargin)
            % fatalAssertEqual - Fatally assert the equality of a value to an expected
            %
            %   fatalAssertEqual(FATALASSERTABLE, ACTUAL, EXPECTED) fatally asserts
            %   that ACTUAL is strictly equal to EXPECTED. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsEqualTo(EXPECTED));
            %
            %   fatalAssertEqual(FATALASSERTABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL)
            %   fatally asserts that ACTUAL is equal to EXPECTED within an absolute
            %   tolerance of ABSTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL)));
            %
            %   fatalAssertEqual(FATALASSERTABLE, ACTUAL, EXPECTED, 'RelTol', RELTOL)
            %   fatally asserts that ACTUAL is equal to EXPECTED within a relative
            %   tolerance of RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', RelativeTolerance(RELTOL)));
            %
            %   fatalAssertEqual(FATALASSERTABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL, 'RelTol', RELTOL)
            %   fatally asserts that every element of ACTUAL is equal to EXPECTED within
            %   either an absolute tolerance of ABSTOL or a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL) | RelativeTolerance(RELTOL)));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo, AbsoluteTolerance, and
            %   RelativeTolerance constraints directly via fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertEqual(FATALASSERTABLE, ACTUAL, EXPECTED, ..., DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.fatalAssertEqual(5, 5, '5 should be equal to 5');
            %       testCase.fatalAssertEqual(1.5, 2, 'AbsTol', 1)
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertEqual(4.95, 5, '4.95 is not equal to 5');
            %       testCase.fatalAssertEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.fatalAssertEqual(int8(5), int16(5), 'Classes must match');
            %       testCase.fatalAssertEqual(1.5, 2, 'RelTol', 0.1, ...
            %           'Difference between actual and expected exceeds relative tolerance')
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.AbsoluteTolerance
            %       matlab.unittest.constraints.RelativeTolerance
            %       fatalAssertThat
            %       fatalAssertNotEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEqual(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expected, ...
                varargin{:});
        end
        
        function fatalAssertNotEqual(fatalAssertable, actual, notExpected, varargin)
            % fatalAssertNotEqual - Fatally assert a value is not equal to an expected
            %
            %   fatalAssertNotEqual(FATALASSERTABLE, ACTUAL, NOTEXPECTED) fatally
            %   asserts that ACTUAL is not equal to NOTEXPECTED. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, ~IsEqualTo(NOTEXPECTED));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertNotEqual(FATALASSERTABLE, ACTUAL, NOTEXPECTED, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNotEqual(4.95, 5, '4.95 should be different from 5');
            %       testCase.fatalAssertNotEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.fatalAssertNotEqual(int8(5), int16(5), 'Classes do not match');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNotEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.fatalAssertNotEqual(5, 5);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       fatalAssertThat
            %       fatalAssertEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEqual(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, notExpected, ...
                varargin{:});
        end
        
        function fatalAssertSameHandle(fatalAssertable, actual, expectedHandle, varargin)
            % fatalAssertSameHandle - Fatally assert two values are handles to the same instance
            %
            %   fatalAssertSameHandle(FATALASSERTABLE, ACTUAL, EXPECTEDHANDLE) fatally
            %   asserts that ACTUAL is the same size and contains the same instances as
            %   the EXPECTEDHANDLE handle array. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsSameHandleAs(EXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertSameHandle(FATALASSERTABLE, ACTUAL, EXPECTEDHANDLE,
            %   DIAGNOSTIC) also provides diagnostic information in DIAGNOSTIC upon a
            %   failure. DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Define a handle class for use in examples
            %       classdef ExampleHandle < handle
            %       end
            %
            %       h1 = ExampleHandle;
            %       h2 = ExampleHandle;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSameHandle(h1, h1, 'They should be the same handle.');
            %       testCase.fatalAssertSameHandle([h1 h1], [h1 h1]);
            %       testCase.fatalAssertSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSameHandle(h1, h2, 'handles were not the same');
            %       testCase.fatalAssertSameHandle([h1 h1], h1);
            %       testCase.fatalAssertSameHandle(h2, [h2 h2]);
            %       testCase.fatalAssertSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       fatalAssertThat
            %       fatalAssertNotSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySameHandle(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedHandle, ...
                varargin{:});
        end
        
        function fatalAssertNotSameHandle(fatalAssertable, actual, notExpectedHandle, varargin)
            % fatalAssertNotSameHandle - Fatally assert a value isn't a handle to some instance
            %
            %   fatalAssertNotSameHandle(FATALASSERTABLE, ACTUAL, NOTEXPECTEDHANDLE)
            %   fatally asserts that ACTUAL is a different size same size and/or does
            %   not contain the same instances as the NOTEXPECTEDHANDLE handle array.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, ~IsSameHandleAs(NOTEXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertNotSameHandle(FATALASSERTABLE, ACTUAL, NOTEXPECTEDHANDLE, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Define a handle class for use in examples
            %       classdef ExampleHandle < handle
            %       end
            %
            %       h1 = ExampleHandle;
            %       h2 = ExampleHandle;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNotSameHandle(h1, h2, 'Handles were the same');
            %       testCase.fatalAssertNotSameHandle([h1 h1], h1);
            %       testCase.fatalAssertNotSameHandle(h2, [h2 h2]);
            %       testCase.fatalAssertNotSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNotSameHandle(h1, h1, 'They should not be the same handle.');
            %       testCase.fatalAssertNotSameHandle([h1 h1], [h1 h1]);
            %       testCase.fatalAssertNotSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       fatalAssertThat
            %       fatalAssertSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotSameHandle(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, notExpectedHandle, ...
                varargin{:});
        end
        
        function varargout = fatalAssertError(fatalAssertable, actual, errorClassOrID, varargin)
            % fatalAssertError - Fatally assert a function throws a specific exception
            %
            %   fatalAssertError(FATALASSERTABLE, ACTUAL, IDENTIFIER) fatally asserts
            %   that ACTUAL is a function handle that throws an exception with an error
            %   identifier that is equal to the string IDENTIFIER.
            %
            %   fatalAssertError(FATALASSERTABLE, ACTUAL, METACLASS)  fatally asserts
            %   that ACTUAL is a function handle that throws an exception whose type is
            %   defined by the meta.class instance specified in  METACLASS. This method
            %   does not require the instance to be an exact class match, but rather it
            %   must be in the specified class hierarchy, and that hierarchy must
            %   include the MException class.
            %
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Throws;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, Throws(IDENTIFIER));
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, Throws(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Throws constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertError(FATALASSERTABLE, ACTUAL, ERRORCLASSORID, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = fatalAssertError(FATALASSERTABLE, ACTUAL, ERRORCLASSORID, ...)
            %   provides control over the number of output arguments used
            %   when invoking function handle ACTUAL. When ACTUAL errors,
            %   the outputs will each be of class "missing".
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertError(@() error('SOME:error:id','Error!'), ...
            %           'SOME:error:id');
            %       testCase.fatalAssertError(@testCase.assertFail, ...
            %           ?matlab.unittest.qualifications.AssertionFailedException);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertError(5, 'some:id', '5 is not a function handle');
            %       testCase.fatalAssertError(@testCase.verifyFail(), ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Verifications do not throw exceptions.');
            %       testCase.fatalAssertError(@() error('SOME:id'), 'OTHER:id', 'Wrong id');
            %       testCase.fatalAssertError(@() error('whoops'), ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Wrong type of exception thrown');
            %
            %   See also
            %       matlab.unittest.constraints.Throws
            %       fatalAssertThat
            %       fatalAssertWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyError(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, errorClassOrID, ...
                varargin{:});
        end
        
        function varargout = fatalAssertWarning(fatalAssertable, actual, warningID, varargin)
            % fatalAssertWarning - Fatally assert a function issues a specific warning
            %
            %   fatalAssertWarning(FATALASSERTABLE, ACTUAL, WARNINGID) fatally asserts
            %   that ACTUAL is a function handle that issues a warning with a warning
            %   identifier that is equal to the string WARNINGID. The function call
            %   will ignore any other warnings that may also be issued by the function
            %   call, and only confirms that the warning specified was issued at least
            %   once. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesWarnings;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IssuesWarnings({WARNINGID}));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesWarnings constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertWarning(FATALASSERTABLE, ACTUAL, WARNINGID, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = fatalAssertWarning(FATALASSERTABLE, ACTUAL, WARNINGID, ...)
            %   also returns the output arguments OUTPUT1, OUTPUT2, ...
            %   that are produced when invoking function handle ACTUAL.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertWarning(@() warning('SOME:warning:id','Warning!'), ...
            %           'SOME:warning:id');
            %
            %       % return function outputs
            %       [actualOut1, actualOut2] = testCase.fatalAssertWarning(@helper, ... %HELPER defined below
            %           'SOME:warning:id');
            %        function varargout = helper()
            %           warning('SOME:warning:id','Warning!');
            %           varargout = {123, 'abc'};
            %        end
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.fatalAssertWarning(@true, 'SOME:warning:id', ...
            %           '@true did not issue any warning');
            %       testCase.fatalAssertWarning(@() warning('SOME:other:id', 'Warning message'), ...
            %           'SOME:warning:id', 'Did not issue specified warning');
            %
            %   See also
            %       matlab.unittest.constraints.IssuesWarnings
            %       fatalAssertThat
            %       fatalAssertError
            %       fatalAssertWarningFree
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarning(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, warningID, ...
                varargin{:});
        end
        
        function varargout = fatalAssertWarningFree(fatalAssertable, actual, varargin)
            % fatalAssertWarningFree - Fatally assert a function issues no warnings
            %
            %   fatalAssertWarningFree(FATALASSERTABLE, ACTUAL) fatally asserts that
            %   ACTUAL is a function handle that issues no warnings. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesNoWarnings;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IssuesNoWarnings());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesNoWarnings constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertWarningFree(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = fatalAssertWarningFree(FATALASSERTABLE, ACTUAL, ...)
            %   also returns the output arguments OUTPUT1, OUTPUT2, ...
            %   that are produced when invoking function handle ACTUAL.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertWarningFree(@why);
            %       testCase.fatalAssertWarningFree(@true, ...
            %           'Simple call to true issues no warnings');
            %       actualOutputFromFalse = testCase.fatalAssertWarningFree(@false);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.fatalAssertWarningFree(5,'diagnostic');
            %
            %       % Issues a warning
            %       testCase.fatalAssertWarningFree(@() warning('some:id', 'Message'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.IssuesNoWarnings
            %       fatalAssertThat
            %       fatalAssertWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarningFree(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertEmpty(fatalAssertable, actual, varargin)
            % fatalAssertEmpty - Fatally assert a value is empty
            %
            %   fatalAssertEmpty(FATALASSERTABLE, ACTUAL) fatally asserts that ACTUAL
            %   is an empty MATLAB value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertEmpty(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.fatalAssertEmpty('','empty string should be empty');
            %       testCase.fatalAssertEmpty(MException.empty, 'empty MException should be empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertEmpty([2 3]);
            %       testCase.fatalAssertEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       fatalAssertThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEmpty(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertNotEmpty(fatalAssertable, actual, varargin)
            % fatalAssertNotEmpty - Fatally assert a value is not empty
            %
            %   fatalAssertNotEmpty(FATALASSERTABLE, ACTUAL) fatally asserts that
            %   ACTUAL is a non-empty MATLAB value. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, ~IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertNotEmpty(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNotEmpty([2 3]);
            %       testCase.fatalAssertNotEmpty({[], [], []}, ...
            %           'cell array of empties is not empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.fatalAssertNotEmpty(ones(2, 5, 0, 3), ...
            %           'empty with any zero dimension');
            %       testCase.fatalAssertNotEmpty('','empty string is empty');
            %       testCase.fatalAssertNotEmpty(MException.empty, 'empty MException is empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       fatalAssertThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEmpty(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertSize(fatalAssertable, actual, expectedSize, varargin)
            % fatalAssertSize - Fatally assert a value has an expected size
            %
            %   fatalAssertSize(FATALASSERTABLE, ACTUAL, EXPECTEDSIZE) fatally asserts
            %   that ACTUAL is a MATLAB array whose size is EXPECTEDSIZE. This method
            %   is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasSize;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, HasSize(EXPECTEDSIZE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasSize constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertSize(FATALASSERTABLE, ACTUAL, EXPECTEDSIZE, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSize(ones(2, 5, 3), [2 5 3], ...
            %           'ones produces correct array');
            %       testCase.fatalAssertSize({'SomeString', 'SomeOtherString'}, [1 2]);
            %       testCase.fatalAssertSize([1 2 3; 4 5 6], [2 3]);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSize([2 3], [3 2], 'Incorrect size');
            %       testCase.fatalAssertSize([1 2 3; 4 5 6], [6 1]);
            %       testCase.fatalAssertSize(eye(2), [4 1]);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasSize
            %       fatalAssertThat
            %       fatalAssertLength
            %       fatalAssertNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySize(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedSize, ...
                varargin{:});
        end
        
        function fatalAssertLength(fatalAssertable, actual, expectedLength, varargin)
            % fatalAssertLength - Fatally assert a value has an expected length
            %
            %   fatalAssertLength(FATALASSERTABLE, ACTUAL, EXPECTEDLENGTH) fatally
            %   asserts that ACTUAL is a MATLAB array whose length is EXPECTEDLENGTH.
            %   The length of an array is defined as the largest dimension of that
            %   array. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasLength;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, HasLength(EXPECTEDLENGTH));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasLength constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertLength(FATALASSERTABLE, ACTUAL, EXPECTEDLENGTH, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLength(ones(2, 5, 3), 5);
            %       testCase.fatalAssertLength(ones(2, 5, 3), 5, 'Test diagnostic');
            %       testCase.fatalAssertLength({'somestring', 'someotherstring'}, 2);
            %       testCase.fatalAssertLength([1 2 3; 4 5 6], 3);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLength([2 3], 3);
            %       testCase.fatalAssertLength([1 2 3; 4 5 6], 6);
            %       testCase.fatalAssertLength(eye(2), 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasLength
            %       fatalAssertThat
            %       fatalAssertSize
            %       fatalAssertNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLength(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedLength, ...
                varargin{:});
        end
        
        function fatalAssertNumElements(fatalAssertable, actual, expectedElementCount, varargin)
            % fatalAssertNumElements - Fatally assert a value has an expected element count
            %
            %   fatalAssertNumElements(FATALASSERTABLE, ACTUAL, EXPECTEDELEMENTCOUNT)
            %   fatally asserts that ACTUAL is a MATLAB array with EXPECTEDELEMENTCOUNT
            %   number of elements. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasElementCount;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, HasElementCount(EXPECTEDELEMENTCOUNT));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasElementCount constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertNumElements(FATALASSERTABLE, ACTUAL, EXPECTEDELEMENTCOUNT, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       n = 7;
            %       testCase.fatalAssertNumElements(eye(n), n^2);
            %       testCase.fatalAssertNumElements(eye(n), n^2, ...
            %           'eye should produce a square matrix');
            %       testCase.fatalAssertNumElements({'SomeString', 'SomeOtherString'}, 2);
            %       testCase.fatalAssertNumElements(3, 1);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertNumElements([1 2 3; 4 5 6], 5);
            %       s.Field1 = 1;
            %       s.Field2 = 2;
            %       testCase.fatalAssertNumElements(s, 2, 'structure only has one element');
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasElementCount
            %       fatalAssertThat
            %       fatalAssertSize
            %       fatalAssertLength
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyNumElements(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedElementCount, ...
                varargin{:});
        end
        
        function fatalAssertGreaterThan(fatalAssertable, actual, floor, varargin)
            % fatalAssertGreaterThan - Fatally assert a value is larger than some floor
            %
            %   fatalAssertGreaterThan(FATALASSERTABLE, ACTUAL, FLOOR) fatally asserts
            %   that all elements of ACTUAL are greater than all the elements of FLOOR.
            %   ACTUAL must be the same size as FLOOR unless either one is scalar, at
            %   which point scalar expansion occurs. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsGreaterThan(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThan constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertGreaterThan(FATALASSERTABLE, ACTUAL, FLOOR, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertGreaterThan(3, 2, '3 should be greater than 2');
            %       testCase.fatalAssertGreaterThan([5 6 7], 2);
            %       testCase.fatalAssertGreaterThan(5, [1 2 3]);
            %       testCase.fatalAssertGreaterThan([5 -3 2], [4 -9 0]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertGreaterThan(5, 9);
            %       testCase.fatalAssertGreaterThan([1 2 3; 4 5 6], 4);
            %       testCase.fatalAssertGreaterThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       fatalAssertThat
            %       fatalAssertGreaterThanOrEqual
            %       fatalAssertLessThan
            %       fatalAssertLessThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyGreaterThan(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function fatalAssertGreaterThanOrEqual(fatalAssertable, actual, floor, varargin)
            % fatalAssertGreaterThanOrEqual - Fatally assert a value is equal or larger than some floor
            %
            %   fatalAssertGreaterThanOrEqual(FATALASSERTABLE, ACTUAL, FLOOR) fatally
            %   asserts that all elements of ACTUAL are greater than or equal to all
            %   the elements of FLOOR. ACTUAL must be the same size as FLOOR unless
            %   either one is scalar, at which point scalar expansion occurs. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsGreaterThanOrEqualTo(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThanOrEqualTo constraint directly
            %   via fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertGreaterThanOrEqual(FATALASSERTABLE, ACTUAL, FLOOR, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertGreaterThanOrEqual(3, 2, '3 is greater than 2');
            %       testCase.fatalAssertGreaterThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.fatalAssertGreaterThanOrEqual([5 2 7], 2);
            %       testCase.fatalAssertGreaterThanOrEqual([5 -3 2], [4 -3 0]);
            %       testCase.fatalAssertGreaterThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertGreaterThanOrEqual(5, 9);
            %       testCase.fatalAssertGreaterThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       fatalAssertThat
            %       fatalAssertGreaterThan
            %       fatalAssertLessThanOrEqual
            %       fatalAssertLessThan
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyGreaterThanOrEqual(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function fatalAssertLessThan(fatalAssertable, actual, ceiling, varargin)
            % fatalAssertLessThan - Fatally assert a value is less than some ceiling
            %
            %   fatalAssertLessThan(FATALASSERTABLE, ACTUAL, CEILING) fatally asserts
            %   that all elements of ACTUAL are less than all the elements of CEILING.
            %   ACTUAL must be the same size as CEILING unless either one is scalar, at
            %   which point scalar expansion occurs. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThan;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsLessThan(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThan constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertLessThan(FATALASSERTABLE, ACTUAL, CEILING, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLessThan(2, 3, '2 is less than 3');
            %       testCase.fatalAssertLessThan([5 6 7], 9);
            %       testCase.fatalAssertLessThan([5 -3 2], [7 -1 8]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLessThan(9, 5);
            %       testCase.fatalAssertLessThan([1 2 3; 4 5 6], 4);
            %       testCase.fatalAssertLessThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThan
            %       fatalAssertThat
            %       fatalAssertLessThanOrEqual
            %       fatalAssertGreaterThan
            %       fatalAssertGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThan(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function fatalAssertLessThanOrEqual(fatalAssertable, actual, ceiling, varargin)
            % fatalAssertLessThanOrEqual - Fatally assert a value is equal or smaller than some ceiling
            %
            %   fatalAssertLessThanOrEqual(FATALASSERTABLE, ACTUAL, CEILING) fatally
            %   asserts that all elements of ACTUAL are less than or equal to all the
            %   elements of CEILING. ACTUAL must be the same size as CEILING unless
            %   either one is scalar, at which point scalar expansion occurs. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThanOrEqualTo;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsLessThanOrEqualTo(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThanOrEqualTo constraint directly
            %   via fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertLessThanOrEqual(FATALASSERTABLE, ACTUAL, CEILING, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLessThanOrEqual(2, 3, '2 is less than 3');
            %       testCase.fatalAssertLessThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.fatalAssertLessThanOrEqual([5 2 7], 7);
            %       testCase.fatalAssertLessThanOrEqual([5 -3 2], [5 -3 8]);
            %       testCase.fatalAssertLessThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertLessThanOrEqual(9, 5);
            %       testCase.fatalAssertLessThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThanOrEqual
            %       fatalAssertThat
            %       fatalAssertLessThan
            %       fatalAssertGreaterThan
            %       fatalAssertGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThanOrEqual(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function fatalAssertReturnsTrue(fatalAssertable, actual, varargin)
            % fatalAssertReturnsTrue - Fatally assert a function returns true when evaluated
            %
            %   fatalAssertReturnsTrue(FATALASSERTABLE, ACTUAL) fatally asserts that
            %   ACTUAL is a function handle that returns a scalar logical whose value
            %   is true. It is a shortcut for quick custom comparison functionality
            %   that can be defined quickly, and possibly inline. It can be preferable
            %   over simply evaluating the function directly and using fatalAssertTrue
            %   because the function handle will be shown in the diagnostics, thus
            %   providing more insight into the failure condition which is lost when
            %   using fatalAssertTrue. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.ReturnsTrue;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, ReturnsTrue());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ReturnsTrue constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertReturnsTrue(FATALASSERTABLE, ACTUAL, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertReturnsTrue(@true, '@true should return true');
            %       testCase.fatalAssertReturnsTrue(@() isequal(1,1));
            %       testCase.fatalAssertReturnsTrue(@() ~strcmp('a','b'));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertReturnsTrue(@false);
            %       testCase.fatalAssertReturnsTrue(@() strcmp('a',{'a','a'}));
            %       testCase.fatalAssertReturnsTrue(@() exist('exist'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.ReturnsTrue
            %       fatalAssertThat
            %       fatalAssertTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyReturnsTrue(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function fatalAssertInstanceOf(fatalAssertable, actual, expectedBaseClass, varargin)
            % fatalAssertInstanceOf - Fatally assert a value "isa" expected type
            %
            %   fatalAssertInstanceOf(FATALASSERTABLE, ACTUAL, CLASSNAME) fatally
            %   asserts that ACTUAL is a MATLAB value that is an instance of the class
            %   specified by the CLASSNAME string.
            %
            %   fatalAssertInstanceOf(FATALASSERTABLE, ACTUAL, METACLASS) fatally
            %   asserts that ACTUAL is a MATLAB value that is an instance of the class
            %   specified by the meta.class instance METACLASS.
            %
            %   This method does not require the instance to be an exact class match,
            %   but rather it must be in the specified class hierarchy. See
            %   fatalAssertClass to fatalAssert the exact class. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsInstanceOf(CLASSNAME));
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsInstanceOf(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsInstanceOf constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertInstanceOf(FATALASSERTABLE, ACTUAL, EXPECTEDBASECLASS, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Example classes
            %       classdef BaseExample
            %       end
            %       classdef DerivedExample < BaseExample
            %       end
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertInstanceOf(5, 'double', '5 should be a double');
            %       testCase.fatalAssertInstanceOf(@sin, ?function_handle);
            %       testCase.fatalAssertInstanceOf(DerivedExample(), ?BaseExample);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertInstanceOf(5, 'char');
            %       testCase.fatalAssertInstanceOf('sin', ?function_handle);
            %       testCase.fatalAssertInstanceOf(BaseExample(), ?DerivedExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsInstanceOf
            %       fatalAssertThat
            %       fatalAssertClass
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyInstanceOf(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedBaseClass, ...
                varargin{:});
        end
        
        function fatalAssertClass(fatalAssertable, actual, expectedClass, varargin)
            % fatalAssertClass - Fatally assert the exact class of some value
            %
            %   fatalAssertClass(FATALASSERTABLE, ACTUAL, CLASSNAME) fatally asserts
            %   that ACTUAL is a MATLAB value whose class is the class specified by the
            %   CLASSNAME string.
            %
            %   fatalAssertClass(FATALASSERTABLE, ACTUAL, METACLASS) fatally asserts
            %   that ACTUAL is a MATLAB value whose class is the class specified
            %   specified by the meta.class instance METACLASS.
            %
            %   This method requires the instance to be an exact class match. See
            %   fatalAssertInstanceOf to fatalAssert inclusion in a class hierarchy.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsOfClass;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsOfClass(CLASSNAME));
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, IsOfClass(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsOfClass constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertClass(FATALASSERTABLE, ACTUAL, EXPECTEDCLASS, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Example classes
            %       classdef BaseExample
            %       end
            %       classdef DerivedExample < BaseExample
            %       end
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertClass(5, 'double', '5 should be a double');
            %       testCase.fatalAssertClass(@sin, ?function_handle);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertClass(5, 'char');
            %       testCase.fatalAssertClass('sin', ?function_handle);
            %       testCase.fatalAssertClass(DerivedExample(), ?BaseExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsOfClass
            %       fatalAssertThat
            %       fatalAssertInstanceOf
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyClass(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expectedClass, ...
                varargin{:});
        end
        
        function fatalAssertSubstring(fatalAssertable, actual, substring, varargin)
            % fatalAssertSubstring - Fatally assert a string contains an expected string
            %
            %   fatalAssertSubstring(FATALASSERTABLE, ACTUAL, SUBSTRING) fatally
            %   asserts that ACTUAL is a string that contains SUBSTRING. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL,
            %       ContainsSubstring(SUBSTRING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ContainsSubstring constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertSubstring(FATALASSERTABLE, ACTUAL, SUBSTRING, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSubstring('SomeLongString', 'Long');
            %       testCase.fatalAssertSubstring('SomeLongString', 'Long', ...
            %           'Long should be a substring');
            %
            %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertSubstring('SomeLongString', 'lonG');
            %       testCase.fatalAssertSubstring('SomeLongString', 'OtherString');
            %       testCase.fatalAssertSubstring('SomeLongString', 'SomeLongStringThatIsLonger');
            %
            %
            %   See also
            %       matlab.unittest.constraints.ContainsSubstring
            %       fatalAssertThat
            %       fatalAssertMatches
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySubstring(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, substring, ...
                varargin{:});
        end
        
        function fatalAssertMatches(fatalAssertable, actual, expression, varargin)
            % fatalAssertMatches - Fatally assert a string matches a regular expression
            %
            %   fatalAssertMatches(FATALASSERTABLE, ACTUAL, EXPRESSION) fatally asserts
            %   that ACTUAL is a string that matches the regular expression defined by
            %   EXPRESSION. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Matches;
            %       FATALASSERTABLE.fatalAssertThat(ACTUAL, Matches(EXPRESSION));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Matches constraint directly via
            %   fatalAssertThat.
            %
            %   FATALASSERTABLE is the instance which is used to pass or fail the fatal
            %   assertion in conjunction with the test running framework.
            %
            %   fatalAssertMatches(FATALASSERTABLE, ACTUAL, EXPRESSION, DIAGNOSTIC)
            %   also provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertMatches('Some String', 'Some [Ss]tring', ...
            %           'My result should have matched the expression');
            %       testCase.fatalAssertMatches('Another string', '(Some |An)other');
            %       testCase.fatalAssertMatches('Another 3 strings', '^Another \d+ strings?$');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.fatalAssertMatches('3 more strings', '\d+ strings?');
            %
            %   See also
            %       matlab.unittest.constraints.Matches
            %       fatalAssertThat
            %       fatalAssertSubstring
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyMatches(fatalAssertable.FatalAssertionDelegate, ...
                fatalAssertable.getNotificationData(), ...
                actual, expression, ...
                varargin{:});
        end
        
    end
    
    methods (Access=private)
        function notificationData = getNotificationData(fatalAssertable)
            notificationData = struct( ...
                'HasPassedListener',@()event.hasListener(fatalAssertable, 'FatalAssertionPassed'), ...
                'NotifyPassed',@(evd)fatalAssertable.notify('FatalAssertionPassed', evd), ...
                'NotifyFailed',@(evd)fatalAssertable.notify('FatalAssertionFailed', evd), ...
                'OnFailureDiagnostics',@()fatalAssertable.FatalAssertionOnFailureTasks.getDefaultQualificationDiagnostics,...
                'DiagnosticData',fatalAssertable.DiagnosticData);
        end
    end
    
    methods(Hidden, Access=protected) % Not directly instantiable
        function fatalAssertable = FatalAssertable(delegate)
            
            if nargin < 1
                delegate = matlab.unittest.internal.qualifications.FatalAssertionDelegate;
            end
            fatalAssertable.FatalAssertionDelegate = delegate;
            
        end
    end
    
    methods (Hidden) 
        function onFailure(fatalAssertable, task)
            fatalAssertable.FatalAssertionOnFailureTasks = [fatalAssertable.FatalAssertionOnFailureTasks, task];
        end
    end
end

% LocalWords:  evd ABSTOL RELTOL NOTEXPECTED evd ABSTOL RELTOL NOTEXPECTED evd
% LocalWords:  EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID ABSTOL RELTOL lh
% LocalWords:  NOTEXPECTED EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID
% LocalWords:  WARNINGID abc EXPECTEDSIZE EXPECTEDLENGTH somestring Substitutor
% LocalWords:  someotherstring EXPECTEDELEMENTCOUNT EXPECTEDBASECLASS
% LocalWords:  EXPECTEDCLASS lon tring