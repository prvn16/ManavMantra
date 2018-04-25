classdef Verifiable < matlab.mixin.Copyable & matlab.unittest.internal.DiagnosticDataMixin
    % Verifiable - Qualification type for "soft" failure conditions.
    %
    %   The Verifiable class is the means by which matlab.unittest
    %   verifications are produced. Apart from actions performed in the event
    %   of failures, the Verifiable class has equivalent functionality to all
    %   matlab.unittest qualifications.
    %
    %   Upon a verification failure, the Verifiable class informs the testing
    %   framework of the failure, including all diagnostic information
    %   associated with the failure, but continues the execution of the
    %   currently running test with no stack unwinding. This is most useful
    %   when a failure at the verification point is not catastrophic to the
    %   remaining test content. Often, verifications are used for the primary
    %   verification of a <a href="http://xunitpatterns.com/Four%20Phase%20Test.html">Four-Phase Test</a>. Other qualification types such as
    %   assertions, fatal assertions, and assumptions are used when
    %   preconditions are violated or fixtures cannot be correctly setup, both
    %   of which render the remaining test content invalid.
    %
    %   The primary benefit of verifications is the fact that failures can be
    %   produced and recorded without throwing an exception. Because of this,
    %   even when failures occur one can be assured that all test content ran
    %   to completion. This facilitates a greater understanding of how close a
    %   given piece of software is to fulfilling the requirements of a given
    %   test suite. Qualification types that throw exceptions do not provide
    %   this insight, since once an exception is thrown there remains an
    %   arbitrary amount of code that was not reached nor exercised. Another
    %   benefit of verifications is that more testing coverage can be obtained
    %   in failure conditions. However, when verifications are overused they
    %   can produce extraneous noise for a single failure condition. If a
    %   failure condition will cause subsequent qualification points to also
    %   fail, then consider using assertions or fatal assertions instead.
    %
    %   Verifiable events:
    %       VerificationFailed - Event triggered upon a failing verification
    %       VerificationPassed - Event triggered upon a passing verification
    %
    %   Verifiable methods:
    %       verifyFail - Produce an unconditional verification failure
    %       verifyThat - Verify that a value meets a given constraint
    %       verifyTrue - Verify that a value is true
    %       verifyFalse - Verify that a value is false
    %       verifyEqual - Verify the equality of a value to an expected
    %       verifyNotEqual - Verify a value is not equal to an expected
    %       verifySameHandle - Verify two values are handles to the same instance
    %       verifyNotSameHandle - Verify a value isn't a handle to some instance
    %       verifyError - Verify a function throws a specific exception
    %       verifyWarning - Verify a function issues a specific warning
    %       verifyWarningFree - Verify a function issues no warnings
    %       verifyEmpty - Verify a value is empty
    %       verifyNotEmpty - Verify a value is not empty
    %       verifySize - Verify a value has an expected size
    %       verifyLength - Verify a value has an expected length
    %       verifyNumElements - Verify a value has an expected element count
    %       verifyGreaterThan - Verify a value is larger than some floor
    %       verifyGreaterThanOrEqual - Verify a value is equal or larger than some floor
    %       verifyLessThan - Verify a value is less than some ceiling
    %       verifyLessThanOrEqual - Verify a value is equal or smaller than some ceiling
    %       verifyReturnsTrue - Verify a function returns true when evaluated
    %       verifyInstanceOf - Verify a value "isa" expected type
    %       verifyClass - Verify the exact class of some value
    %       verifySubstring - Verify a string contains an expected string
    %       verifyMatches - Verify a string matches a regular expression
    %
    %
    %   See also
    %       Assertable
    %       Assumable
    %       FatalAssertable
    %       matlab.unittest.TestCase
    %
    
    % Copyright 2010-2017 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        % VerificationPassed - Event triggered upon a passing verification.
        %   The VerificationPassed event provides a means to observe and react to
        %   passing verifications. Callback functions listening to the event
        %   receive information about the passing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        VerificationPassed;
        
        % VerificationFailed - Event triggered upon a failing verification.
        %   The VerificationFailed event provides a means to observe and react to
        %   failing verifications. Callback functions listening to the event
        %   receive information about the failing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        VerificationFailed;
    end
    
    properties(Access=private)
        VerificationDelegate (1,1) matlab.unittest.internal.qualifications.VerificationDelegate;        
    end
    
     properties(Transient,Access=private)
          VerificationOnFailureTasks matlab.unittest.internal.Task;
     end
    
    methods(Sealed)
        function verifyFail(verifiable, varargin)
            % verifyFail - Produce an unconditional verification failure
            %
            %   verifyFail(VERIFIABLE) produces an unconditional verification failure
            %   when encountered. VERIFIABLE is the instance which is used to fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyFail(VERIFIABLE, DIAGNOSTIC) also provides diagnostic information
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
            %               testCase.verifyFail('This listener callback should not have executed');
            %           end
            %       end
            %
            %   See also
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFail(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                varargin{:});
        end
        
        function verifyThat(verifiable, actual, constraint, varargin)
            % verifyThat - Verify that a value meets a given constraint
            %
            %   verifyThat(VERIFIABLE, ACTUAL, CONSTRAINT) verifies that ACTUAL is a
            %   value that satisfies the CONSTRAINT provided. If the constraint is not
            %   satisfied, a verification failure is produced utilizing only the
            %   diagnostic generated by the CONSTRAINT. VERIFIABLE is the instance
            %   which is used to pass or fail the verification in conjunction with the
            %   test running framework.
            %
            %   verifyThat(VERIFIABLE, ACTUAL, CONSTRAINT, DIAGNOSTIC) also provides
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
            %       testCase.verifyThat(true, IsTrue);
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       testCase.verifyThat(5, IsEqualTo(5), '5 should be equal to 5');
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.HasNaN;
            %       testCase.verifyThat([5 NaN], IsGreaterThan(10) | HasNaN, ...
            %           'The value was not greater than 10 or NaN');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       import matlab.unittest.constraints.AnyCellOf;
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       testCase.verifyThat( AnyCellOf({'cell','of','strings'}), ...
            %           ContainsSubstring('char'),'Test description');
            %
            %       import matlab.unittest.constraints.HasSize;
            %       testCase.verifyThat(zeros(10,4,2), HasSize([10,5,2]), ...
            %           @() disp('A function handle diagnostic.'));
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       testCase.verifyThat(5, IsEmpty);
            %
            %   See also
            %       matlab.unittest.constraints.Constraint
            %       matlab.unittest.constraints
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyThat(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, constraint, ...
                varargin{:});
        end
        
        function verifyTrue(verifiable, actual, varargin)
            % verifyTrue - Verify that a value is true
            %
            %   verifyTrue(VERIFIABLE, ACTUAL) verifies that ACTUAL is a scalar logical
            %   with the value of true. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsTrue;
            %       VERIFIABLE.verifyThat(ACTUAL, IsTrue());
            %
            %   However, this method is optimized for performance and does not
            %   construct a new IsTrue constraint for each call. Sometimes such use can
            %   come at the expense of less diagnostic information. Use the
            %   verifyReturnsTrue method for a similar approach which may provide
            %   better diagnostic information.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsTrue constraint directly via verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyTrue(VERIFIABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.verifyTrue(true);
            %       testCase.verifyTrue(true, 'true should be true');
            %       % Optimized comparison that trades speed for less diagnostics
            %       testCase.verifyTrue(contains('string', 'ring'), ...
            %           'Could not find expected string');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyTrue(false);
            %       testCase.verifyTrue(1, 'A double value of 1 is not true');
            %       testCase.verifyTrue([true true true], ...
            %           'An array of logical trues are not the one true value');
            %
            %   See also
            %       matlab.unittest.constraints.IsTrue
            %       verifyThat
            %       verifyFalse
            %       verifyReturnsTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyTrue(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifyFalse(verifiable, actual, varargin)
            % verifyFalse - Verify that a value is false
            %
            %   verifyFalse(VERIFIABLE, ACTUAL) verifies that ACTUAL is a scalar
            %   logical with the value of false. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.IsFalse;
            %       VERIFIABLE.verifyThat(ACTUAL, IsFalse());
            %
            %   Unlike verifyTrue, this method may create a new constraint for
            %   each call. For performance critical uses, consider using verifyTrue.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsFalse constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyFalse(VERIFIABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.verifyFalse(false);
            %       testCase.verifyFalse(false, 'false should be false');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyFalse(true);
            %       testCase.verifyFalse(0, 'A double with a value of 0 is not false');
            %       testCase.verifyFalse([false true false], ...
            %           'A mixed array of logicals is not the one false value');
            %       testCase.verifyFalse([false false false], ...
            %           'A false array is not the one false value');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsFalse
            %       verifyThat
            %       verifyTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFalse(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifyEqual(verifiable, actual, expected, varargin)
            % verifyEqual - Verify the equality of a value to an expected
            %
            %   verifyEqual(VERIFIABLE, ACTUAL, EXPECTED) verifies that ACTUAL is
            %   strictly equal to EXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       VERIFIABLE.verifyThat(ACTUAL, IsEqualTo(EXPECTED));
            %
            %   verifyEqual(VERIFIABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL) verifies
            %   that ACTUAL is equal to EXPECTED within an absolute tolerance of
            %   ABSTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       VERIFIABLE.verifyThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL)));
            %
            %   verifyEqual(VERIFIABLE, ACTUAL, EXPECTED, 'RelTol', RELTOL) verifies
            %   that ACTUAL is equal to EXPECTED within a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       VERIFIABLE.verifyThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', RelativeTolerance(RELTOL)));
            %
            %   verifyEqual(VERIFIABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL, 'RelTol', RELTOL)
            %   verifies that every element of ACTUAL is equal to EXPECTED within
            %   either an absolute tolerance of ABSTOL or a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       VERIFIABLE.verifyThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL) | RelativeTolerance(RELTOL)));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo, AbsoluteTolerance, and
            %   RelativeTolerance constraints directly via verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyEqual(VERIFIABLE, ACTUAL, EXPECTED, ..., DIAGNOSTIC) also provides
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
            %       testCase.verifyEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.verifyEqual(5, 5, '5 should be equal to 5');
            %       testCase.verifyEqual(1.5, 2, 'AbsTol', 1)
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyEqual(4.95, 5, '4.95 is not equal to 5');
            %       testCase.verifyEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.verifyEqual(int8(5), int16(5), 'Classes must match');
            %       testCase.verifyEqual(1.5, 2, 'RelTol', 0.1, ...
            %           'Difference between actual and expected exceeds relative tolerance')
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.AbsoluteTolerance
            %       matlab.unittest.constraints.RelativeTolerance
            %       verifyThat
            %       verifyNotEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEqual(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expected, ...
                varargin{:});
        end
        
        function verifyNotEqual(verifiable, actual, notExpected, varargin)
            % verifyNotEqual - Verify a value is not equal to an expected
            %
            %   verifyNotEqual(VERIFIABLE, ACTUAL, NOTEXPECTED) verifies that ACTUAL is
            %   not equal to NOTEXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       VERIFIABLE.verifyThat(ACTUAL, ~IsEqualTo(NOTEXPECTED));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyNotEqual(VERIFIABLE, ACTUAL, NOTEXPECTED, DIAGNOSTIC) also
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
            %       testCase.verifyNotEqual(4.95, 5, '4.95 should be different from 5');
            %       testCase.verifyNotEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.verifyNotEqual(int8(5), int16(5), 'Classes do not match');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyNotEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.verifyNotEqual(5, 5);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       verifyThat
            %       verifyEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEqual(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, notExpected, ...
                varargin{:});
        end
        
        function verifySameHandle(verifiable, actual, expectedHandle, varargin)
            % verifySameHandle - Verify two values are handles to the same instance
            %
            %   verifySameHandle(VERIFIABLE, ACTUAL, EXPECTEDHANDLE) verifies that
            %   ACTUAL is the same size and contains the same instances as the
            %   EXPECTEDHANDLE handle array. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       VERIFIABLE.verifyThat(ACTUAL, IsSameHandleAs(EXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifySameHandle(VERIFIABLE, ACTUAL, EXPECTEDHANDLE, DIAGNOSTIC) also
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
            %       testCase.verifySameHandle(h1, h1, 'They should be the same handle.');
            %       testCase.verifySameHandle([h1 h1], [h1 h1]);
            %       testCase.verifySameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifySameHandle(h1, h2, 'handles were not the same');
            %       testCase.verifySameHandle([h1 h1], h1);
            %       testCase.verifySameHandle(h2, [h2 h2]);
            %       testCase.verifySameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       verifyThat
            %       verifyNotSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySameHandle(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedHandle, ...
                varargin{:});
        end
        
        function verifyNotSameHandle(verifiable, actual, notExpectedHandle, varargin)
            % verifyNotSameHandle - Verify a value isn't a handle to some instance
            %
            %   verifyNotSameHandle(VERIFIABLE, ACTUAL, NOTEXPECTEDHANDLE) verifies
            %   that ACTUAL is a different size same size and/or does not contain the
            %   same instances as the NOTEXPECTEDHANDLE handle array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       VERIFIABLE.verifyThat(ACTUAL, ~IsSameHandleAs(NOTEXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyNotSameHandle(VERIFIABLE, ACTUAL, NOTEXPECTEDHANDLE, DIAGNOSTIC)
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
            %       testCase.verifyNotSameHandle(h1, h2, 'Handles were the same');
            %       testCase.verifyNotSameHandle([h1 h1], h1);
            %       testCase.verifyNotSameHandle(h2, [h2 h2]);
            %       testCase.verifyNotSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyNotSameHandle(h1, h1, 'They should not be the same handle.');
            %       testCase.verifyNotSameHandle([h1 h1], [h1 h1]);
            %       testCase.verifyNotSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       verifyThat
            %       verifySameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotSameHandle(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, notExpectedHandle, ...
                varargin{:});
        end
        
        function varargout = verifyError(verifiable, actual, errorClassOrID, varargin)
            % verifyError - Verify a function throws a specific exception
            %
            %   verifyError(VERIFIABLE, ACTUAL, IDENTIFIER) verifies that ACTUAL is a
            %   function handle that throws an exception with an error identifier that
            %   is equal to the string IDENTIFIER.
            %
            %   verifyError(VERIFIABLE, ACTUAL, METACLASS)  verifies that ACTUAL is a
            %   function handle that throws an exception whose type is defined by the
            %   meta.class instance specified in  METACLASS. This method does not
            %   require the instance to be an exact class match, but rather it must be
            %   in the specified class hierarchy, and that hierarchy must include the
            %   MException class.
            %
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Throws;
            %       VERIFIABLE.verifyThat(ACTUAL, Throws(IDENTIFIER));
            %       VERIFIABLE.verifyThat(ACTUAL, Throws(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Throws constraint directly via verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyError(VERIFIABLE, ACTUAL, ERRORCLASSORID, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = verifyError(VERIFIABLE, ACTUAL, ERRORCLASSORID, ...)
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
            %       testCase.verifyError(@() error('SOME:error:id','Error!'), 'SOME:error:id');
            %       testCase.verifyError(@testCase.assertFail, ...
            %           ?matlab.unittest.qualifications.AssertionFailedException);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyError(5, 'some:id', '5 is not a function handle');
            %       testCase.verifyError(@testCase.verifyFail, ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Verifications do not throw exceptions.');
            %       testCase.verifyError(@() error('SOME:id'), 'OTHER:id', 'Wrong id');
            %       testCase.verifyError(@() error('whoops'), ...
            %           ?matlab.unittest.qualifications.AssertionFailedException, ...
            %           'Wrong type of exception thrown');
            %
            %   See also
            %       matlab.unittest.constraints.Throws
            %       verifyThat
            %       verifyWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyError(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, errorClassOrID, ...
                varargin{:});
        end
        
        function varargout = verifyWarning(verifiable, actual, warningID, varargin)
            % verifyWarning - Verify a function issues a specific warning
            %
            %   verifyWarning(VERIFIABLE, ACTUAL, WARNINGID) verifies that ACTUAL is a
            %   function handle that issues a warning with a warning identifier that is
            %   equal to the string WARNINGID. The function call will ignore any other
            %   warnings that may also be issued by the function call, and only
            %   confirms that the warning specified was issued at least once. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesWarnings;
            %       VERIFIABLE.verifyThat(ACTUAL, IssuesWarnings({WARNINGID}));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesWarnings constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyWarning(VERIFIABLE, ACTUAL, WARNINGID, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = verifyWarning(VERIFIABLE, ACTUAL, WARNINGID, ...)
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
            %       testCase.verifyWarning(@() warning('SOME:warning:id','Warning!'), ...
            %           'SOME:warning:id');
            %
            %       % return function outputs
            %       [actualOut1, actualOut2] = testCase.verifyWarning(@helper, ... %HELPER defined below
            %           'SOME:warning:id');
            %        function varargout = helper()
            %           warning('SOME:warning:id','Warning!');
            %           varargout = {123, 'abc'};
            %        end
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.verifyWarning(@true, 'SOME:warning:id', '@true did not issue any warning');
            %       testCase.verifyWarning(@() warning('SOME:other:id', 'Warning message'), 'SOME:warning:id',...
            %           'Did not issue specified warning');
            %
            %   See also
            %       matlab.unittest.constraints.IssuesWarnings
            %       verifyThat
            %       verifyError
            %       verifyWarningFree
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarning(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, warningID, ...
                varargin{:});
        end
        
        function varargout = verifyWarningFree(verifiable, actual, varargin)
            % verifyWarningFree - Verify a function issues no warnings
            %
            %   verifyWarningFree(VERIFIABLE, ACTUAL) verifies that ACTUAL is a
            %   function handle that issues no warnings. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesNoWarnings;
            %       VERIFIABLE.verifyThat(ACTUAL, IssuesNoWarnings());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesNoWarnings constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyWarningFree(VERIFIABLE, ACTUAL, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = verifyWarningFree(VERIFIABLE, ACTUAL, ...)
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
            %       testCase.verifyWarningFree(@why);
            %       testCase.verifyWarningFree(@true, ...
            %           'Simple call to true issues no warnings');
            %       actualOutputFromFalse = testCase.verifyWarningFree(@false);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.verifyWarningFree(5,'diagnostic');
            %
            %       % Issues a warning
            %       testCase.verifyWarningFree(@() warning('some:id', 'Message'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.IssuesNoWarnings
            %       verifyThat
            %       verifyWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarningFree(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifyEmpty(verifiable, actual, varargin)
            % verifyEmpty - Verify a value is empty
            %
            %   verifyEmpty(VERIFIABLE, ACTUAL) verifies that ACTUAL is an empty MATLAB
            %   value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       VERIFIABLE.verifyThat(ACTUAL, IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyEmpty(VERIFIABLE, ACTUAL, DIAGNOSTIC) also
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
            %       testCase.verifyEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.verifyEmpty('','empty string should be empty');
            %       testCase.verifyEmpty(MException.empty, 'empty MException should be empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyEmpty([2 3]);
            %       testCase.verifyEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       verifyThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEmpty(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifyNotEmpty(verifiable, actual, varargin)
            % verifyNotEmpty - Verify a value is not empty
            %
            %   verifyNotEmpty(VERIFIABLE, ACTUAL) verifies that ACTUAL is a non-empty
            %   MATLAB value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       VERIFIABLE.verifyThat(ACTUAL, ~IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyNotEmpty(VERIFIABLE, ACTUAL, DIAGNOSTIC) also
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
            %       testCase.verifyNotEmpty([2 3]);
            %       testCase.verifyNotEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.verifyNotEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.verifyNotEmpty('','empty string is empty');
            %       testCase.verifyNotEmpty(MException.empty, 'empty MException is empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       verifyThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEmpty(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifySize(verifiable, actual, expectedSize, varargin)
            % verifySize - Verify a value has an expected size
            %
            %   verifySize(VERIFIABLE, ACTUAL, EXPECTEDSIZE) verifies that ACTUAL is a
            %   MATLAB array whose size is EXPECTEDSIZE. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.HasSize;
            %       VERIFIABLE.verifyThat(ACTUAL, HasSize(EXPECTEDSIZE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasSize constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifySize(VERIFIABLE, ACTUAL, EXPECTEDSIZE, DIAGNOSTIC) also provides
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
            %       testCase.verifySize(ones(2, 5, 3), [2 5 3], 'ones produces correct array');
            %       testCase.verifySize({'SomeString', 'SomeOtherString'}, [1 2]);
            %       testCase.verifySize([1 2 3; 4 5 6], [2 3]);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifySize([2 3], [3 2], 'Incorrect size');
            %       testCase.verifySize([1 2 3; 4 5 6], [6 1]);
            %       testCase.verifySize(eye(2), [4 1]);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasSize
            %       verifyThat
            %       verifyLength
            %       verifyNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySize(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedSize, ...
                varargin{:});
        end
        
        function verifyLength(verifiable, actual, expectedLength, varargin)
            % verifyLength - Verify a value has an expected length
            %
            %   verifyLength(VERIFIABLE, ACTUAL, EXPECTEDLENGTH) verifies that ACTUAL
            %   is a MATLAB array whose length is EXPECTEDLENGTH. The length of an
            %   array is defined as the largest dimension of that array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasLength;
            %       VERIFIABLE.verifyThat(ACTUAL, HasLength(EXPECTEDLENGTH));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasLength constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyLength(VERIFIABLE, ACTUAL, EXPECTEDLENGTH, DIAGNOSTIC) also
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
            %       testCase.verifyLength(ones(2, 5, 3), 5);
            %       testCase.verifyLength(ones(2, 5, 3), 5, 'Test diagnostic');
            %       testCase.verifyLength({'somestring', 'someotherstring'}, 2);
            %       testCase.verifyLength([1 2 3; 4 5 6], 3);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyLength([2 3], 3);
            %       testCase.verifyLength([1 2 3; 4 5 6], 6);
            %       testCase.verifyLength(eye(2), 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasLength
            %       verifyThat
            %       verifySize
            %       verifyNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLength(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedLength, ...
                varargin{:});
        end
        
        function verifyNumElements(verifiable, actual, expectedElementCount, varargin)
            % verifyNumElements - Verify a value has an expected element count
            %
            %   verifyNumElements(VERIFIABLE, ACTUAL, EXPECTEDELEMENTCOUNT) verifies
            %   that ACTUAL is a MATLAB array with EXPECTEDELEMENTCOUNT number of
            %   elements. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasElementCount;
            %       VERIFIABLE.verifyThat(ACTUAL, HasElementCount(EXPECTEDELEMENTCOUNT));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasElementCount constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyNumElements(VERIFIABLE, ACTUAL, EXPECTEDELEMENTCOUNT, DIAGNOSTIC)
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
            %       testCase.verifyNumElements(eye(n), n^2);
            %       testCase.verifyNumElements(eye(n), n^2, 'eye should produce a square matrix');
            %       testCase.verifyNumElements({'SomeString', 'SomeOtherString'}, 2);
            %       testCase.verifyNumElements(3, 1);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyNumElements([1 2 3; 4 5 6], 5);
            %       s.Field1 = 1;
            %       s.Field2 = 2;
            %       testCase.verifyNumElements(s, 2, 'structure only has one element');
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasElementCount
            %       verifyThat
            %       verifySize
            %       verifyLength
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyNumElements(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedElementCount, ...
                varargin{:});
        end
        
        function verifyGreaterThan(verifiable, actual, floor, varargin)
            % verifyGreaterThan - Verify a value is larger than some floor
            %
            %   verifyGreaterThan(VERIFIABLE, ACTUAL, FLOOR) verifies that all elements of
            %   ACTUAL are greater than all the elements of FLOOR. ACTUAL must be the
            %   same size as FLOOR unless either one is scalar, at which point scalar
            %   expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       VERIFIABLE.verifyThat(ACTUAL, IsGreaterThan(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThan constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyGreaterThan(VERIFIABLE, ACTUAL, FLOOR, DIAGNOSTIC) also provides
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
            %       testCase.verifyGreaterThan(3, 2, '3 should be greater than 2');
            %       testCase.verifyGreaterThan([5 6 7], 2);
            %       testCase.verifyGreaterThan(5, [1 2 3]);
            %       testCase.verifyGreaterThan([5 -3 2], [4 -9 0]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyGreaterThan(5, 9);
            %       testCase.verifyGreaterThan([1 2 3; 4 5 6], 4);
            %       testCase.verifyGreaterThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       verifyThat
            %       verifyGreaterThanOrEqual
            %       verifyLessThan
            %       verifyLessThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyGreaterThan(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function verifyGreaterThanOrEqual(verifiable, actual, floor, varargin)
            % verifyGreaterThanOrEqual - Verify a value is equal or larger than some floor
            %
            %   verifyGreaterThanOrEqual(VERIFIABLE, ACTUAL, FLOOR) verifies that all
            %   elements of ACTUAL are greater than or equal to all the elements of
            %   FLOOR. ACTUAL must be the same size as FLOOR unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            %       VERIFIABLE.verifyThat(ACTUAL, IsGreaterThanOrEqualTo(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThanOrEqualTo constraint directly
            %   via verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyGreaterThanOrEqual(VERIFIABLE, ACTUAL, FLOOR, DIAGNOSTIC) also
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
            %       testCase.verifyGreaterThanOrEqual(3, 2, '3 is greater than 2');
            %       testCase.verifyGreaterThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.verifyGreaterThanOrEqual([5 2 7], 2);
            %       testCase.verifyGreaterThanOrEqual([5 -3 2], [4 -3 0]);
            %       testCase.verifyGreaterThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyGreaterThanOrEqual(5, 9);
            %       testCase.verifyGreaterThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       verifyThat
            %       verifyGreaterThan
            %       verifyLessThanOrEqual
            %       verifyLessThan
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyGreaterThanOrEqual(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function verifyLessThan(verifiable, actual, ceiling, varargin)
            % verifyLessThan - Verify a value is less than some ceiling
            %
            %   verifyLessThan(VERIFIABLE, ACTUAL, CEILING) verifies that all elements of
            %   ACTUAL are less than all the elements of CEILING. ACTUAL must be the
            %   same size as CEILING unless either one is scalar, at which point scalar
            %   expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThan;
            %       VERIFIABLE.verifyThat(ACTUAL, IsLessThan(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThan constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyLessThan(VERIFIABLE, ACTUAL, CEILING, DIAGNOSTIC) also provides
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
            %       testCase.verifyLessThan(2, 3, '2 is less than 3');
            %       testCase.verifyLessThan([5 6 7], 9);
            %       testCase.verifyLessThan([5 -3 2], [7 -1 8]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyLessThan(9, 5);
            %       testCase.verifyLessThan([1 2 3; 4 5 6], 4);
            %       testCase.verifyLessThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThan
            %       verifyThat
            %       verifyLessThanOrEqual
            %       verifyGreaterThan
            %       verifyGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThan(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function verifyLessThanOrEqual(verifiable, actual, ceiling, varargin)
            % verifyLessThanOrEqual - Verify a value is equal or smaller than some ceiling
            %
            %   verifyLessThanOrEqual(VERIFIABLE, ACTUAL, CEILING) verifies that all
            %   elements of ACTUAL are less than or equal to all the elements of
            %   CEILING. ACTUAL must be the same size as CEILING unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThanOrEqualTo;
            %       VERIFIABLE.verifyThat(ACTUAL, IsLessThanOrEqualTo(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThanOrEqualTo constraint directly
            %   via verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyLessThanOrEqual(VERIFIABLE, ACTUAL, CEILING, DIAGNOSTIC) also
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
            %       testCase.verifyLessThanOrEqual(2, 3, '2 is less than 3');
            %       testCase.verifyLessThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.verifyLessThanOrEqual([5 2 7], 7);
            %       testCase.verifyLessThanOrEqual([5 -3 2], [5 -3 8]);
            %       testCase.verifyLessThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyLessThanOrEqual(9, 5);
            %       testCase.verifyLessThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThanOrEqual
            %       verifyThat
            %       verifyLessThan
            %       verifyGreaterThan
            %       verifyGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThanOrEqual(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function verifyReturnsTrue(verifiable, actual, varargin)
            % verifyReturnsTrue - Verify a function returns true when evaluated
            %
            %   verifyReturnsTrue(VERIFIABLE, ACTUAL) verifies that ACTUAL is a
            %   function handle that returns a scalar logical whose value is true. It
            %   is a shortcut for quick custom comparison functionality that can be
            %   defined quickly, and possibly inline. It can be preferable over simply
            %   evaluating the function directly and using verifyTrue because the
            %   function handle will be shown in the diagnostics, thus providing more
            %   insight into the failure condition which is lost when using verifyTrue.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.ReturnsTrue;
            %       VERIFIABLE.verifyThat(ACTUAL, ReturnsTrue());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ReturnsTrue constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyReturnsTrue(VERIFIABLE, ACTUAL, DIAGNOSTIC) also
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
            %       testCase.verifyReturnsTrue(@true, '@true should return true');
            %       testCase.verifyReturnsTrue(@() isequal(1,1));
            %       testCase.verifyReturnsTrue(@() ~strcmp('a','b'));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyReturnsTrue(@false);
            %       testCase.verifyReturnsTrue(@() strcmp('a',{'a','a'}));
            %       testCase.verifyReturnsTrue(@() exist('exist'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.ReturnsTrue
            %       verifyThat
            %       verifyTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyReturnsTrue(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function verifyInstanceOf(verifiable, actual, expectedBaseClass, varargin)
            % verifyInstanceOf - Verify a value "isa" expected type
            %
            %   verifyInstanceOf(VERIFIABLE, ACTUAL, CLASSNAME) verifies that ACTUAL is
            %   a MATLAB value that is an instance of the class specified by the
            %   CLASSNAME string.
            %
            %   verifyInstanceOf(VERIFIABLE, ACTUAL, METACLASS) verifies that ACTUAL
            %   is a MATLAB value that is an instance of the class specified
            %   by the meta.class instance METACLASS.
            %
            %   This method does not require the instance to be an exact class match,
            %   but rather it must be in the specified class hierarchy. See verifyClass
            %   to verify the exact class. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       VERIFIABLE.verifyThat(ACTUAL, IsInstanceOf(CLASSNAME));
            %       VERIFIABLE.verifyThat(ACTUAL, IsInstanceOf(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsInstanceOf constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyInstanceOf(VERIFIABLE, ACTUAL, EXPECTEDBASECLASS, DIAGNOSTIC)
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
            %       testCase.verifyInstanceOf(5, 'double', '5 should be a double');
            %       testCase.verifyInstanceOf(@sin, ?function_handle);
            %       testCase.verifyInstanceOf(DerivedExample(), ?BaseExample);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyInstanceOf(5, 'char');
            %       testCase.verifyInstanceOf('sin', ?function_handle);
            %       testCase.verifyInstanceOf(BaseExample(), ?DerivedExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsInstanceOf
            %       verifyThat
            %       verifyClass
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyInstanceOf(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedBaseClass, ...
                varargin{:});
        end
        
        function verifyClass(verifiable, actual, expectedClass, varargin)
            % verifyClass - Verify the exact class of some value
            %
            %   verifyClass(VERIFIABLE, ACTUAL, CLASSNAME) verifies that ACTUAL is a
            %   MATLAB value whose class is the class specified by the CLASSNAME
            %   string.
            %
            %   verifyClass(VERIFIABLE, ACTUAL, METACLASS) verifies that ACTUAL is a
            %   MATLAB value whose class is the class specified by the
            %   meta.class instance METACLASS.
            %
            %   This method requires the instance to be an exact class match. See
            %   verifyInstanceOf to verify inclusion in a class hierarchy. This method
            %   is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsOfClass;
            %       VERIFIABLE.verifyThat(ACTUAL, IsOfClass(CLASSNAME));
            %       VERIFIABLE.verifyThat(ACTUAL, IsOfClass(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsOfClass constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyClass(VERIFIABLE, ACTUAL, EXPECTEDCLASS, DIAGNOSTIC) also
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
            %       testCase.verifyClass(5, 'double', '5 should be a double');
            %       testCase.verifyClass(@sin, ?function_handle);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyClass(5, 'char');
            %       testCase.verifyClass('sin', ?function_handle);
            %       testCase.verifyClass(DerivedExample(), ?BaseExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsOfClass
            %       verifyThat
            %       verifyInstanceOf
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyClass(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expectedClass, ...
                varargin{:});
        end
        
        function verifySubstring(verifiable, actual, substring, varargin)
            % verifySubstring - Verify a string contains an expected string
            %
            %   verifySubstring(VERIFIABLE, ACTUAL, SUBSTRING) verifies that
            %   ACTUAL is a string that contains SUBSTRING. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       VERIFIABLE.verifyThat(ACTUAL, ContainsSubstring(SUBSTRING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ContainsSubstring constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifySubstring(VERIFIABLE, ACTUAL, SUBSTRING, DIAGNOSTIC) also
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
            %       testCase.verifySubstring('SomeLongString', 'Long');
            %       testCase.verifySubstring('SomeLongString', 'Long', ...
            %           'Long should be a substring');
            %
            %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifySubstring('SomeLongString', 'lonG');
            %       testCase.verifySubstring('SomeLongString', 'OtherString');
            %       testCase.verifySubstring('SomeLongString', 'SomeLongStringThatIsLonger');
            %
            %
            %   See also
            %       matlab.unittest.constraints.ContainsSubstring
            %       verifyThat
            %       verifyMatches
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySubstring(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, substring, ...
                varargin{:});
        end
        
        function verifyMatches(verifiable, actual, expression, varargin)
            % verifyMatches - Verify a string matches a regular expression
            %
            %   verifyMatches(VERIFIABLE, ACTUAL, EXPRESSION) verifies that ACTUAL is a
            %   string that matches the regular expression defined by EXPRESSION. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Matches;
            %       VERIFIABLE.verifyThat(ACTUAL, Matches(EXPRESSION));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Matches constraint directly via
            %   verifyThat.
            %
            %   VERIFIABLE is the instance which is used to pass or fail the
            %   verification in conjunction with the test running framework.
            %
            %   verifyMatches(VERIFIABLE, ACTUAL, EXPRESSION, DIAGNOSTIC) also provides
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
            %       testCase.verifyMatches('Some String', 'Some [Ss]tring', ...
            %           'My result should have matched the expression');
            %       testCase.verifyMatches('Another string', '(Some |An)other');
            %       testCase.verifyMatches('Another 3 strings', '^Another \d+ strings?$');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.verifyMatches('3 more strings', '\d+ strings?');
            %
            %   See also
            %       matlab.unittest.constraints.Matches
            %       verifyThat
            %       verifySubstring
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyMatches(verifiable.VerificationDelegate, ...
                verifiable.getNotificationData(), ...
                actual, expression, ...
                varargin{:});
        end
    end
    
    methods (Access=private)
        function notificationData = getNotificationData(verifiable)
            notificationData = struct( ...
                'HasPassedListener',@()event.hasListener(verifiable, 'VerificationPassed'), ...
                'NotifyPassed',@(evd)verifiable.notify('VerificationPassed', evd), ...
                'NotifyFailed',@(evd)verifiable.notify('VerificationFailed', evd), ...
                'OnFailureDiagnostics',@()verifiable.VerificationOnFailureTasks.getVerificationDiagnostics,...
                'DiagnosticData',verifiable.DiagnosticData);
        end
    end
    
    methods(Hidden, Access=protected) % Not directly instantiable
        function verifiable = Verifiable(delegate)
            
            if nargin < 1
                delegate = matlab.unittest.internal.qualifications.VerificationDelegate;
            end
            verifiable.VerificationDelegate = delegate;
            
        end
    end
    
    methods (Hidden) 
        function onFailure(verifiable, task)
            verifiable.VerificationOnFailureTasks = [verifiable.VerificationOnFailureTasks, task];
        end
    end
end

% LocalWords:  xunitpatterns evd ABSTOL RELTOL NOTEXPECTED xunitpatterns evd
% LocalWords:  ABSTOL RELTOL NOTEXPECTED EXPECTEDHANDLE NOTEXPECTEDHANDLE
% LocalWords:  ERRORCLASSORID xunitpatterns evd ABSTOL RELTOL NOTEXPECTED
% LocalWords:  EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID WARNINGID abc
% LocalWords:  EXPECTEDSIZE EXPECTEDLENGTH somestring someotherstring
% LocalWords:  EXPECTEDELEMENTCOUNT EXPECTEDBASECLASS EXPECTEDCLASS lon tring