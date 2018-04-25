classdef Assertable < matlab.mixin.Copyable & matlab.unittest.internal.DiagnosticDataMixin
    % Assertable - Qualification which fails and then filters test content.
    %
    %   The Assertable class is the means by which matlab.unittest assertions
    %   are produced. Apart from actions performed in the event of failures,
    %   the Assertable class has equivalent functionality to all
    %   matlab.unittest qualifications.
    %
    %   Upon an assertion failure, the Assertable class informs the testing
    %   framework of the failure by throwing an AssertionFailedException. This
    %   is most useful when a failure at the assertion point renders the
    %   remainder of the current test method invalid, yet does not prevent
    %   proper execution of other test methods. Often, assertions are used in
    %   order to assure that preconditions of the current test are not violated
    %   or that fixtures are setup correctly, provided that all test fixtures
    %   can be adequately torn down in the event of a failure. It is important
    %   to note that the test content should be exception safe. That is, all
    %   fixture teardown should be performed via the addTeardown method or
    %   through the appropriate object destructors should a failure occur. This
    %   is important to ensure that the failure does not effect subsequent
    %   testing due to stale fixtures. If the fixture teardown cannot be made
    %   exception safe or is unrecoverable in the event of failure, consider
    %   using fatal assertions instead.
    %
    %   The primary benefit of assertions is to allow remaining test methods to
    %   receive coverage when preconditions are violated in a given test and
    %   all fixture state is restorable. They also reduce the noise level of
    %   failures by not exercising subsequent verifications which only fail due
    %   to such precondition failures. In the event of a failure, however, the
    %   full content of the test method which failed is marked as incomplete by
    %   the test running framework. Therefore, if the failure does not effect
    %   the preconditions of the test or problems with fixture setup or
    %   teardown, consider using verifications, which give the added
    %   information for such failures that the full test content was run.
    %
    %   Assertable events:
    %       AssertionFailed - Event triggered upon a failing assertion
    %       AssertionPassed - Event triggered upon a passing assertion
    %
    %   Assertable methods:
    %       assertFail - Produce an unconditional assertion failure
    %       assertThat - Assert that a value meets a given constraint
    %       assertTrue - Assert that a value is true
    %       assertFalse - Assert that a value is false
    %       assertEqual - Assert the equality of a value to an expected
    %       assertNotEqual - Assert a value is not equal to an expected
    %       assertSameHandle - Assert two values are handles to the same instance
    %       assertNotSameHandle - Assert a value isn't a handle to some instance
    %       assertError - Assert a function throws a specific exception
    %       assertWarning - Assert a function issues a specific warning
    %       assertWarningFree - Assert a function issues no warnings
    %       assertEmpty - Assert a value is empty
    %       assertNotEmpty - Assert a value is not empty
    %       assertSize - Assert a value has an expected size
    %       assertLength - Assert a value has an expected length
    %       assertNumElements - Assert a value has an expected element count
    %       assertGreaterThan - Assert a value is larger than some floor
    %       assertGreaterThanOrEqual - Assert a value is equal or larger than some floor
    %       assertLessThan - Assert a value is less than some ceiling
    %       assertLessThanOrEqual - Assert a value is equal or smaller than some ceiling
    %       assertReturnsTrue - Assert a function returns true when evaluated
    %       assertInstanceOf - Assert a value "isa" expected type
    %       assertClass - Assert the exact class of some value
    %       assertSubstring - Assert a string contains an expected string
    %       assertMatches - Assert a string matches a regular expression
    %
    %
    %   See also
    %       Assumable
    %       FatalAssertable
    %       Verifiable
    %       matlab.unittest.TestCase
    %
    
    % Copyright 2010-2017 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        % AssertionFailed - Event triggered upon a failing assertion.
        %   The AssertionFailed event provides a means to observe and react to
        %   failing assertions. Callback functions listening to the event
        %   receive information about the failing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssertionFailed;
        
        % AssertionPassed - Event triggered upon a passing assertion.
        %   The AssertionPassed event provides a means to observe and react to
        %   passing assertions. Callback functions listening to the event
        %   receive information about the passing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssertionPassed;
    end
    
    properties(Access=private)
        AssertionDelegate (1,1) matlab.unittest.internal.qualifications.AssertionDelegate;
    end
    
    properties(Transient,Access=private)
        AssertionOnFailureTasks matlab.unittest.internal.Task;
    end
    
    methods(Sealed)
        function assertFail(assertable, varargin)
            % assertFail - Produce an unconditional assertion failure
            %
            %   assertFail(ASSERTABLE) produces an unconditional assertion failure when
            %   encountered. ASSERTABLE is the instance which is used to fail the
            %   assertion in conjunction with the test running framework.
            %
            %   assertFail(ASSERTABLE, DIAGNOSTIC) also provides diagnostic information
            %   in DIAGNOSTIC for the failure. DIAGNOSTIC can be a string, a function
            %   handle, or any matlab.unittest.diagnostics.Diagnostic implementation.
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
            %               testCase.assertFail('This listener callback should not have executed');
            %           end
            %       end
            %
            %   See also
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFail(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                varargin{:});
        end
        
        function assertThat(assertable, actual, constraint, varargin)
            % assertThat - Assert that a value meets a given constraint
            %
            %   assertThat(ASSERTABLE, ACTUAL, CONSTRAINT) asserts that ACTUAL is a
            %   value that satisfies the CONSTRAINT provided. If the constraint is not
            %   satisfied, a assertion failure is produced utilizing only the
            %   diagnostic generated by the CONSTRAINT. ASSERTABLE is the instance
            %   which is used to pass or fail the assertion in conjunction with the
            %   test running framework.
            %
            %   assertThat(ASSERTABLE, ACTUAL, CONSTRAINT, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation. When using this signature, both the diagnostic
            %   information contained within DIAGNOSTIC is used in addition to the
            %   diagnostic information provided by the CONSTRAINT.
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
            %       testCase.assertThat(true, IsTrue);
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       testCase.assertThat(5, IsEqualTo(5), '5 should be equal to 5');
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.HasNaN;
            %       testCase.assertThat([5 NaN], IsGreaterThan(10) | HasNaN, ...
            %           'The value was not greater than 10 or NaN');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       import matlab.unittest.constraints.AnyCellOf;
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       testCase.assertThat( AnyCellOf({'cell','of','strings'}), ...
            %           ContainsSubstring('char'),'Test description');
            %
            %       import matlab.unittest.constraints.HasSize;
            %       testCase.assertThat(zeros(10,4,2), HasSize([10,5,2]), ...
            %           @() disp('A function handle diagnostic.'));
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       testCase.assertThat(5, IsEmpty);
            %
            %   See also
            %       matlab.unittest.constraints.Constraint
            %       matlab.unittest.constraints
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyThat(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, constraint, ...
                varargin{:});
        end
        
        function assertTrue(assertable, actual, varargin)
            % assertTrue - Assert that a value is true
            %
            %   assertTrue(ASSERTABLE, ACTUAL) asserts that ACTUAL is a scalar logical
            %   with the value of true. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsTrue;
            %       ASSERTABLE.assertThat(ACTUAL, IsTrue());
            %
            %   However, this method is optimized for performance and does not
            %   construct a new IsTrue constraint for each call. Sometimes such use can
            %   come at the expense of less diagnostic information. Use the
            %   assertReturnsTrue method for a similar approach which may provide
            %   better diagnostic information.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsTrue constraint directly via assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertTrue(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
            %   information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be a string, a
            %   function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
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
            %       testCase.assertTrue(true);
            %       testCase.assertTrue(true, 'true should be true');
            %       % Optimized comparison that trades speed for less diagnostics
            %       testCase.assertTrue(contains('string', 'ring'), ...
            %           'Could not find expected string');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertTrue(false);
            %       testCase.assertTrue(1, 'A double value of 1 is not true');
            %       testCase.assertTrue([true true true], ...
            %           'An array of logical trues are not the one true value');
            %
            %   See also
            %       matlab.unittest.constraints.IsTrue
            %       assertThat
            %       assertFalse
            %       assertReturnsTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyTrue(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertFalse(assertable, actual, varargin)
            % assertFalse - Assert that a value is false
            %
            %   assertFalse(ASSERTABLE, ACTUAL) asserts that ACTUAL is a scalar logical
            %   with the value of false. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsFalse;
            %       ASSERTABLE.assertThat(ACTUAL, IsFalse());
            %
            %   Unlike assertTrue, this method may create a new constraint for
            %   each call. For performance critical uses, consider using assertTrue.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsFalse constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertFalse(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
            %   information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be a string, a
            %   function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
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
            %       testCase.assertFalse(false);
            %       testCase.assertFalse(false, 'false should be false');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertFalse(true);
            %       testCase.assertFalse(0, 'A double with a value of 0 is not false');
            %       testCase.assertFalse([false true false], ...
            %           'A mixed array of logicals is not the one false value');
            %       testCase.assertFalse([false false false], ...
            %           'A false array is not the one false value');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsFalse
            %       assertThat
            %       assertTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFalse(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertEqual(assertable, actual, expected, varargin)
            % assertEqual - Assert the equality of a value to an expected
            %
            %   assertEqual(ASSERTABLE, ACTUAL, EXPECTED) asserts that ACTUAL is
            %   strictly equal to EXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       ASSERTABLE.assertThat(ACTUAL, IsEqualTo(EXPECTED));
            %
            %   assertEqual(ASSERTABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL) asserts
            %   that ACTUAL is equal to EXPECTED within an absolute tolerance of
            %   ABSTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       ASSERTABLE.assertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL)));
            %
            %   assertEqual(ASSERTABLE, ACTUAL, EXPECTED, 'RelTol', RELTOL) asserts
            %   that ACTUAL is equal to EXPECTED within a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       ASSERTABLE.assertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', RelativeTolerance(RELTOL)));
            %
            %   assertEqual(ASSERTABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL, 'RelTol', RELTOL)
            %   asserts that every element of ACTUAL is equal to EXPECTED within
            %   either an absolute tolerance of ABSTOL or a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       ASSERTABLE.assertThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL) | RelativeTolerance(RELTOL)));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo, AbsoluteTolerance, and
            %   RelativeTolerance constraints directly via assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertEqual(ASSERTABLE, ACTUAL, EXPECTED, ..., DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.assertEqual(5, 5, '5 should be equal to 5');
            %       testCase.assertEqual(1.5, 2, 'AbsTol', 1)
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertEqual(4.95, 5, '4.95 is not equal to 5');
            %       testCase.assertEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.assertEqual(int8(5), int16(5), 'Classes must match');
            %       testCase.assertEqual(1.5, 2, 'RelTol', 0.1, ...
            %           'Difference between actual and expected exceeds relative tolerance')
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.AbsoluteTolerance
            %       matlab.unittest.constraints.RelativeTolerance
            %       assertThat
            %       assertNotEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEqual(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expected, ...
                varargin{:});
        end
        
        function assertNotEqual(assertable, actual, notExpected, varargin)
            % assertNotEqual - Assert a value is not equal to an expected
            %
            %   assertNotEqual(ASSERTABLE, ACTUAL, NOTEXPECTED) asserts that ACTUAL is
            %   not equal to NOTEXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       ASSERTABLE.assertThat(ACTUAL, ~IsEqualTo(NOTEXPECTED));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertNotEqual(ASSERTABLE, ACTUAL, NOTEXPECTED, DIAGNOSTIC) also
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
            %       testCase.assertNotEqual(4.95, 5, '4.95 should be different from 5');
            %       testCase.assertNotEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.assertNotEqual(int8(5), int16(5), 'Classes do not match');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertNotEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.assertNotEqual(5, 5);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assertThat
            %       assertEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEqual(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, notExpected, ...
                varargin{:});
        end
        
        function assertSameHandle(assertable, actual, expectedHandle, varargin)
            % assertSameHandle - Assert two values are handles to the same instance
            %
            %   assertSameHandle(ASSERTABLE, ACTUAL, EXPECTEDHANDLE) asserts that
            %   ACTUAL is the same size and contains the same instances as the
            %   EXPECTEDHANDLE handle array. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       ASSERTABLE.assertThat(ACTUAL, IsSameHandleAs(EXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertSameHandle(ASSERTABLE, ACTUAL, EXPECTEDHANDLE, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
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
            %       testCase.assertSameHandle(h1, h1, 'They should be the same handle.');
            %       testCase.assertSameHandle([h1 h1], [h1 h1]);
            %       testCase.assertSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertSameHandle(h1, h2, 'handles were not the same');
            %       testCase.assertSameHandle([h1 h1], h1);
            %       testCase.assertSameHandle(h2, [h2 h2]);
            %       testCase.assertSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       assertThat
            %       assertNotSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySameHandle(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedHandle, ...
                varargin{:});
        end
        
        function assertNotSameHandle(assertable, actual, notExpectedHandle, varargin)
            % assertNotSameHandle - Assert a value isn't a handle to some instance
            %
            %   assertNotSameHandle(ASSERTABLE, ACTUAL, NOTEXPECTEDHANDLE) asserts that
            %   ACTUAL is a different size same size and/or does not contain the same
            %   instances as the NOTEXPECTEDHANDLE handle array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       ASSERTABLE.assertThat(ACTUAL, ~IsSameHandleAs(NOTEXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertNotSameHandle(ASSERTABLE, ACTUAL, NOTEXPECTEDHANDLE, DIAGNOSTIC)
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
            %       testCase.assertNotSameHandle(h1, h2, 'Handles were the same');
            %       testCase.assertNotSameHandle([h1 h1], h1);
            %       testCase.assertNotSameHandle(h2, [h2 h2]);
            %       testCase.assertNotSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertNotSameHandle(h1, h1, 'They should not be the same handle.');
            %       testCase.assertNotSameHandle([h1 h1], [h1 h1]);
            %       testCase.assertNotSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assertThat
            %       assertSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotSameHandle(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, notExpectedHandle, ...
                varargin{:});
        end
        
        function varargout = assertError(assertable, actual, errorClassOrID, varargin)
            % assertError - Assert a function throws a specific exception
            %
            %   assertError(ASSERTABLE, ACTUAL, IDENTIFIER) asserts that ACTUAL is a
            %   function handle that throws an exception with an error identifier that
            %   is equal to the string IDENTIFIER.
            %
            %   assertError(ASSERTABLE, ACTUAL, METACLASS)  asserts that ACTUAL is a
            %   function handle that throws an exception whose type is defined by the
            %   meta.class instance specified in  METACLASS. This method does not
            %   require the instance to be an exact class match, but rather it must be
            %   in the specified class hierarchy, and that hierarchy must include the
            %   MException class.
            %
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Throws;
            %       ASSERTABLE.assertThat(ACTUAL, Throws(IDENTIFIER));
            %       ASSERTABLE.assertThat(ACTUAL, Throws(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Throws constraint directly via assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertError(ASSERTABLE, ACTUAL, ERRORCLASSORID, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assertError(ASSERTABLE, ACTUAL, ERRORCLASSORID, ...)
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
            %       testCase.assertError(@() error('SOME:error:id','Error!'), 'SOME:error:id');
            %       testCase.assertError(@testCase.assertFail, ...
            %           ?matlab.unittest.qualifications.AssertionFailedException);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertError(5, 'some:id', '5 is not a function handle');
            %       testCase.assertError(@testCase.verifyFail(), ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Verifications do not throw exceptions.');
            %       testCase.assertError(@() error('SOME:id'), 'OTHER:id', 'Wrong id');
            %       testCase.assertError(@() error('whoops'), ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Wrong type of exception thrown');
            %
            %   See also
            %       matlab.unittest.constraints.Throws
            %       assertThat
            %       assertWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyError(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, errorClassOrID, ...
                varargin{:});
        end
        
        function varargout = assertWarning(assertable, actual, warningID, varargin)
            % assertWarning - Assert a function issues a specific warning
            %
            %   assertWarning(ASSERTABLE, ACTUAL, WARNINGID) asserts that ACTUAL is a
            %   function handle that issues a warning with a warning identifier that is
            %   equal to the string WARNINGID. The function call will ignore any other
            %   warnings that may also be issued by the function call, and only
            %   confirms that the warning specified was issued at least once. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesWarnings;
            %       ASSERTABLE.assertThat(ACTUAL, IssuesWarnings({WARNINGID}));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesWarnings constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertWarning(ASSERTABLE, ACTUAL, WARNINGID, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assertWarning(ASSERTABLE, ACTUAL, WARNINGID, ...)
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
            %       testCase.assertWarning(@() warning('SOME:warning:id','Warning!'), ...
            %           'SOME:warning:id');
            %
            %       % return function outputs
            %       [actualOut1, actualOut2] = testCase.assertWarning(@helper, ... %HELPER defined below
            %           'SOME:warning:id');
            %        function varargout = helper()
            %           warning('SOME:warning:id','Warning!');
            %           varargout = {123, 'abc'};
            %        end
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assertWarning(@true, 'SOME:warning:id', '@true did not issue any warning');
            %       testCase.assertWarning(@() warning('SOME:other:id', 'Warning message'), 'SOME:warning:id',...
            %           'Did not issue specified warning');
            %
            %   See also
            %       matlab.unittest.constraints.IssuesWarnings
            %       assertThat
            %       assertError
            %       assertWarningFree
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarning(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, warningID, ...
                varargin{:});
        end
        
        function varargout = assertWarningFree(assertable, actual, varargin)
            % assertWarningFree - Assert a function issues no warnings
            %
            %   assertWarningFree(ASSERTABLE, ACTUAL) asserts that ACTUAL is a function
            %   handle that issues no warnings. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.IssuesNoWarnings;
            %       ASSERTABLE.assertThat(ACTUAL, IssuesNoWarnings());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesNoWarnings constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertWarningFree(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assertWarningFree(ASSERTABLE, ACTUAL, ...)
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
            %       testCase.assertWarningFree(@why);
            %       testCase.assertWarningFree(@true, ...
            %           'Simple call to true issues no warnings');
            %       actualOutputFromFalse = testCase.assertWarningFree(@false);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assertWarningFree(5,'diagnostic');
            %
            %       % Issues a warning
            %       testCase.assertWarningFree(@() warning('some:id', 'Message'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.IssuesNoWarnings
            %       assertThat
            %       assertWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarningFree(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertEmpty(assertable, actual, varargin)
            % assertEmpty - Assert a value is empty
            %
            %   assertEmpty(ASSERTABLE, ACTUAL) asserts that ACTUAL is an empty MATLAB
            %   value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       ASSERTABLE.assertThat(ACTUAL, IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertEmpty(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
            %   information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be a string, a
            %   function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.assertEmpty('','empty string should be empty');
            %       testCase.assertEmpty(MException.empty, 'empty MException should be empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertEmpty([2 3]);
            %       testCase.assertEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       assertThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEmpty(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertNotEmpty(assertable, actual, varargin)
            % assertNotEmpty - Assert a value is not empty
            %
            %   assertNotEmpty(ASSERTABLE, ACTUAL) asserts that ACTUAL is a non-empty
            %   MATLAB value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       ASSERTABLE.assertThat(ACTUAL, ~IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertNotEmpty(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
            %   information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be a string, a
            %   function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertNotEmpty([2 3]);
            %       testCase.assertNotEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assertNotEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.assertNotEmpty('','empty string is empty');
            %       testCase.assertNotEmpty(MException.empty, 'empty MException is empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assertThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEmpty(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertSize(assertable, actual, expectedSize, varargin)
            % assertSize - Assert a value has an expected size
            %
            %   assertSize(ASSERTABLE, ACTUAL, EXPECTEDSIZE) asserts that ACTUAL is a
            %   MATLAB array whose size is EXPECTEDSIZE. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.HasSize;
            %       ASSERTABLE.assertThat(ACTUAL, HasSize(EXPECTEDSIZE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasSize constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertSize(ASSERTABLE, ACTUAL, EXPECTEDSIZE, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertSize(ones(2, 5, 3), [2 5 3], 'ones produces correct array');
            %       testCase.assertSize({'SomeString', 'SomeOtherString'}, [1 2]);
            %       testCase.assertSize([1 2 3; 4 5 6], [2 3]);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertSize([2 3], [3 2], 'Incorrect size');
            %       testCase.assertSize([1 2 3; 4 5 6], [6 1]);
            %       testCase.assertSize(eye(2), [4 1]);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasSize
            %       assertThat
            %       assertLength
            %       assertNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySize(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedSize, ...
                varargin{:});
        end
        
        function assertLength(assertable, actual, expectedLength, varargin)
            % assertLength - Assert a value has an expected length
            %
            %   assertLength(ASSERTABLE, ACTUAL, EXPECTEDLENGTH) asserts that ACTUAL is
            %   a MATLAB array whose length is EXPECTEDLENGTH. The length of an array
            %   is defined as the largest dimension of that array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasLength;
            %       ASSERTABLE.assertThat(ACTUAL, HasLength(EXPECTEDLENGTH));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasLength constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertLength(ASSERTABLE, ACTUAL, EXPECTEDLENGTH, DIAGNOSTIC) also
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
            %       testCase.assertLength(ones(2, 5, 3), 5);
            %       testCase.assertLength(ones(2, 5, 3), 5, 'Test diagnostic');
            %       testCase.assertLength({'somestring', 'someotherstring'}, 2);
            %       testCase.assertLength([1 2 3; 4 5 6], 3);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertLength([2 3], 3);
            %       testCase.assertLength([1 2 3; 4 5 6], 6);
            %       testCase.assertLength(eye(2), 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasLength
            %       assertThat
            %       assertSize
            %       assertNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLength(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedLength, ...
                varargin{:});
        end
        
        function assertNumElements(assertable, actual, expectedElementCount, varargin)
            % assertNumElements - Assert a value has an expected element count
            %
            %   assertNumElements(ASSERTABLE, ACTUAL, EXPECTEDELEMENTCOUNT) asserts
            %   that ACTUAL is a MATLAB array with EXPECTEDELEMENTCOUNT number of
            %   elements. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasElementCount;
            %       ASSERTABLE.assertThat(ACTUAL, HasElementCount(EXPECTEDELEMENTCOUNT));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasElementCount constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertNumElements(ASSERTABLE, ACTUAL, EXPECTEDELEMENTCOUNT, DIAGNOSTIC)
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
            %       testCase.assertNumElements(eye(n), n^2);
            %       testCase.assertNumElements(eye(n), n^2, 'eye should produce a square matrix');
            %       testCase.assertNumElements({'SomeString', 'SomeOtherString'}, 2);
            %       testCase.assertNumElements(3, 1);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertNumElements([1 2 3; 4 5 6], 5);
            %       s.Field1 = 1;
            %       s.Field2 = 2;
            %       testCase.assertNumElements(s, 2, 'structure only has one element');
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasElementCount
            %       assertThat
            %       assertSize
            %       assertLength
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyNumElements(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedElementCount, ...
                varargin{:});
        end
        
        function assertGreaterThan(assertable, actual, floor, varargin)
            % assertGreaterThan - Assert a value is larger than some floor
            %
            %   assertGreaterThan(ASSERTABLE, ACTUAL, FLOOR) asserts that all elements
            %   of ACTUAL are greater than all the elements of FLOOR. ACTUAL must be
            %   the same size as FLOOR unless either one is scalar, at which point
            %   scalar expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       ASSERTABLE.assertThat(ACTUAL, IsGreaterThan(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThan constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertGreaterThan(ASSERTABLE, ACTUAL, FLOOR, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertGreaterThan(3, 2, '3 should be greater than 2');
            %       testCase.assertGreaterThan([5 6 7], 2);
            %       testCase.assertGreaterThan(5, [1 2 3]);
            %       testCase.assertGreaterThan([5 -3 2], [4 -9 0]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertGreaterThan(5, 9);
            %       testCase.assertGreaterThan([1 2 3; 4 5 6], 4);
            %       testCase.assertGreaterThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       assertThat
            %       assertGreaterThanOrEqual
            %       assertLessThan
            %       assertLessThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyGreaterThan(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function assertGreaterThanOrEqual(assertable, actual, floor, varargin)
            % assertGreaterThanOrEqual - Assert a value is equal or larger than some floor
            %
            %   assertGreaterThanOrEqual(ASSERTABLE, ACTUAL, FLOOR) asserts that all
            %   elements of ACTUAL are greater than or equal to all the elements of
            %   FLOOR. ACTUAL must be the same size as FLOOR unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            %       ASSERTABLE.assertThat(ACTUAL, IsGreaterThanOrEqualTo(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThanOrEqualTo constraint directly
            %   via assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertGreaterThanOrEqual(ASSERTABLE, ACTUAL, FLOOR, DIAGNOSTIC) also
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
            %       testCase.assertGreaterThanOrEqual(3, 2, '3 is greater than 2');
            %       testCase.assertGreaterThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.assertGreaterThanOrEqual([5 2 7], 2);
            %       testCase.assertGreaterThanOrEqual([5 -3 2], [4 -3 0]);
            %       testCase.assertGreaterThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertGreaterThanOrEqual(5, 9);
            %       testCase.assertGreaterThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       assertThat
            %       assertGreaterThan
            %       assertLessThanOrEqual
            %       assertLessThan
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyGreaterThanOrEqual(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function assertLessThan(assertable, actual, ceiling, varargin)
            % assertLessThan - Assert a value is less than some ceiling
            %
            %   assertLessThan(ASSERTABLE, ACTUAL, CEILING) asserts that all elements
            %   of ACTUAL are less than all the elements of CEILING. ACTUAL must be the
            %   same size as CEILING unless either one is scalar, at which point scalar
            %   expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThan;
            %       ASSERTABLE.assertThat(ACTUAL, IsLessThan(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThan constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertLessThan(ASSERTABLE, ACTUAL, CEILING, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertLessThan(2, 3, '2 is less than 3');
            %       testCase.assertLessThan([5 6 7], 9);
            %       testCase.assertLessThan([5 -3 2], [7 -1 8]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertLessThan(9, 5);
            %       testCase.assertLessThan([1 2 3; 4 5 6], 4);
            %       testCase.assertLessThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThan
            %       assertThat
            %       assertLessThanOrEqual
            %       assertGreaterThan
            %       assertGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThan(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function assertLessThanOrEqual(assertable, actual, ceiling, varargin)
            % assertLessThanOrEqual - Assert a value is equal or smaller than some ceiling
            %
            %   assertLessThanOrEqual(ASSERTABLE, ACTUAL, CEILING) asserts that all
            %   elements of ACTUAL are less than or equal to all the elements of
            %   CEILING. ACTUAL must be the same size as CEILING unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThanOrEqualTo;
            %       ASSERTABLE.assertThat(ACTUAL, IsLessThanOrEqualTo(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThanOrEqualTo constraint directly
            %   via assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertLessThanOrEqual(ASSERTABLE, ACTUAL, CEILING, DIAGNOSTIC) also
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
            %       testCase.assertLessThanOrEqual(2, 3, '2 is less than 3');
            %       testCase.assertLessThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.assertLessThanOrEqual([5 2 7], 7);
            %       testCase.assertLessThanOrEqual([5 -3 2], [5 -3 8]);
            %       testCase.assertLessThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertLessThanOrEqual(9, 5);
            %       testCase.assertLessThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThanOrEqual
            %       assertThat
            %       assertLessThan
            %       assertGreaterThan
            %       assertGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThanOrEqual(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function assertReturnsTrue(assertable, actual, varargin)
            % assertReturnsTrue - Assert a function returns true when evaluated
            %
            %   assertReturnsTrue(ASSERTABLE, ACTUAL) asserts that ACTUAL is a function
            %   handle that returns a scalar logical whose value is true. It is a
            %   shortcut for quick custom comparison functionality that can be defined
            %   quickly, and possibly inline. It can be preferable over simply
            %   evaluating the function directly and using assertTrue because the
            %   function handle will be shown in the diagnostics, thus providing more
            %   insight into the failure condition which is lost when using assertTrue.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.ReturnsTrue;
            %       ASSERTABLE.assertThat(ACTUAL, ReturnsTrue());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ReturnsTrue constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertReturnsTrue(ASSERTABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertReturnsTrue(@true, '@true should return true');
            %       testCase.assertReturnsTrue(@() isequal(1,1));
            %       testCase.assertReturnsTrue(@() ~strcmp('a','b'));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertReturnsTrue(@false);
            %       testCase.assertReturnsTrue(@() strcmp('a',{'a','a'}));
            %       testCase.assertReturnsTrue(@() exist('exist'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.ReturnsTrue
            %       assertThat
            %       assertTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyReturnsTrue(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assertInstanceOf(assertable, actual, expectedBaseClass, varargin)
            % assertInstanceOf - Assert a value "isa" expected type
            %
            %   assertInstanceOf(ASSERTABLE, ACTUAL, CLASSNAME) asserts that ACTUAL is
            %   a MATLAB value that is an instance of the class specified by the
            %   CLASSNAME string.
            %
            %   assertInstanceOf(ASSERTABLE, ACTUAL, METACLASS) asserts that ACTUAL is
            %   a MATLAB value that is an instance of the class specified by
            %   the meta.class instance METACLASS.
            %
            %   This method does not require the instance to be an exact class match,
            %   but rather it must be in the specified class hierarchy. See assertClass
            %   to assert the exact class. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       ASSERTABLE.assertThat(ACTUAL, IsInstanceOf(CLASSNAME));
            %       ASSERTABLE.assertThat(ACTUAL, IsInstanceOf(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsInstanceOf constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertInstanceOf(ASSERTABLE, ACTUAL, EXPECTEDBASECLASS, DIAGNOSTIC)
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
            %       testCase.assertInstanceOf(5, 'double', '5 should be a double');
            %       testCase.assertInstanceOf(@sin, ?function_handle);
            %       testCase.assertInstanceOf(DerivedExample(), ?BaseExample);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertInstanceOf(5, 'char');
            %       testCase.assertInstanceOf('sin', ?function_handle);
            %       testCase.assertInstanceOf(BaseExample(), ?DerivedExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsInstanceOf
            %       assertThat
            %       assertClass
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyInstanceOf(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedBaseClass, ...
                varargin{:});
        end
        
        function assertClass(assertable, actual, expectedClass, varargin)
            % assertClass - Assert the exact class of some value
            %
            %   assertClass(ASSERTABLE, ACTUAL, CLASSNAME) asserts that ACTUAL is a
            %   MATLAB value whose class is the class specified by the CLASSNAME
            %   string.
            %
            %   assertClass(ASSERTABLE, ACTUAL, METACLASS) asserts that ACTUAL is a
            %   MATLAB value whose class is the class specified by the
            %   meta.class instance METACLASS.
            %
            %   This method requires the instance to be an exact class match. See
            %   assertInstanceOf to assert inclusion in a class hierarchy. This method
            %   is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsOfClass;
            %       ASSERTABLE.assertThat(ACTUAL, IsOfClass(CLASSNAME));
            %       ASSERTABLE.assertThat(ACTUAL, IsOfClass(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsOfClass constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertClass(ASSERTABLE, ACTUAL, EXPECTEDCLASS, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
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
            %       testCase.assertClass(5, 'double', '5 should be a double');
            %       testCase.assertClass(@sin, ?function_handle);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertClass(5, 'char');
            %       testCase.assertClass('sin', ?function_handle);
            %       testCase.assertClass(DerivedExample(), ?BaseExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsOfClass
            %       assertThat
            %       assertInstanceOf
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyClass(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expectedClass, ...
                varargin{:});
        end
        
        function assertSubstring(assertable, actual, substring, varargin)
            % assertSubstring - Assert a string contains an expected string
            %
            %   assertSubstring(ASSERTABLE, ACTUAL, SUBSTRING) asserts that ACTUAL is a
            %   string that contains SUBSTRING. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       ASSERTABLE.assertThat(ACTUAL, ContainsSubstring(SUBSTRING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ContainsSubstring constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertSubstring(ASSERTABLE, ACTUAL, SUBSTRING, DIAGNOSTIC) also
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
            %       testCase.assertSubstring('SomeLongString', 'Long');
            %       testCase.assertSubstring('SomeLongString', 'Long', ...
            %           'Long should be a substring');
            %
            %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertSubstring('SomeLongString', 'lonG');
            %       testCase.assertSubstring('SomeLongString', 'OtherString');
            %       testCase.assertSubstring('SomeLongString', 'SomeLongStringThatIsLonger');
            %
            %
            %   See also
            %       matlab.unittest.constraints.ContainsSubstring
            %       assertThat
            %       assertMatches
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySubstring(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, substring, ...
                varargin{:});
        end
        
        function assertMatches(assertable, actual, expression, varargin)
            % assertMatches - Assert a string matches a regular expression
            %
            %   assertMatches(ASSERTABLE, ACTUAL, EXPRESSION) asserts that ACTUAL is a
            %   string that matches the regular expression defined by EXPRESSION. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Matches;
            %       ASSERTABLE.assertThat(ACTUAL, Matches(EXPRESSION));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Matches constraint directly via
            %   assertThat.
            %
            %   ASSERTABLE is the instance which is used to pass or fail the assertion
            %   in conjunction with the test running framework.
            %
            %   assertMatches(ASSERTABLE, ACTUAL, EXPRESSION, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertMatches('Some String', 'Some [Ss]tring', ...
            %           'My result should have matched the expression');
            %       testCase.assertMatches('Another string', '(Some |An)other');
            %       testCase.assertMatches('Another 3 strings', '^Another \d+ strings?$');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assertMatches('3 more strings', '\d+ strings?');
            %
            %   See also
            %       matlab.unittest.constraints.Matches
            %       assertThat
            %       assertSubstring
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyMatches(assertable.AssertionDelegate, ...
                assertable.getNotificationData(), ...
                actual, expression, ...
                varargin{:});
        end
    end
    
    methods (Access=private)
        function notificationData = getNotificationData(assertable)
            notificationData = struct( ...
                'HasPassedListener',@()event.hasListener(assertable, 'AssertionPassed'), ...
                'NotifyPassed',@(evd)assertable.notify('AssertionPassed', evd), ...
                'NotifyFailed',@(evd)assertable.notify('AssertionFailed', evd),...
                'OnFailureDiagnostics',@()assertable.AssertionOnFailureTasks.getDefaultQualificationDiagnostics,...
                'DiagnosticData',assertable.DiagnosticData);
        end
    end
    
    methods(Hidden, Access=protected) % Not directly instantiable
        function assertable = Assertable(delegate)
            
            if nargin < 1
                delegate = matlab.unittest.internal.qualifications.AssertionDelegate;
            end
            assertable.AssertionDelegate = delegate;
            
        end
    end
    
    methods (Hidden) 
        function onFailure(assertable, task)
            assertable.AssertionOnFailureTasks = [assertable.AssertionOnFailureTasks, task];
        end
    end
end

% LocalWords:  evd ABSTOL RELTOL NOTEXPECTED evd ABSTOL RELTOL NOTEXPECTED evd
% LocalWords:  EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID ABSTOL RELTOL
% LocalWords:  NOTEXPECTED EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID
% LocalWords:  WARNINGID abc EXPECTEDSIZE EXPECTEDLENGTH somestring assertable
% LocalWords:  someotherstring EXPECTEDELEMENTCOUNT EXPECTEDBASECLASS lh
% LocalWords:  EXPECTEDCLASS lon tring Substitutor