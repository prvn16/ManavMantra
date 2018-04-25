classdef Assumable < matlab.mixin.Copyable & matlab.unittest.internal.DiagnosticDataMixin
    % Assumable - Qualification which filters test content.
    %
    %   The Assumable class is the means by which matlab.unittest assumptions
    %   are produced. Apart from actions performed in the event of failures,
    %   the Assumable class has equivalent functionality to all matlab.unittest
    %   qualifications.
    %
    %   Upon an assumption failure, the Assumable class informs the testing
    %   framework of the failure by throwing an AssumptionFailedException. The
    %   test running framework then marks the test content as filtered and
    %   continues testing. Often, assumptions are used in order to assure that
    %   the test is run only when certain preconditions are satisfied, but such
    %   an event should not produce a test failure. It is important to note
    %   that the test content should be exception safe. That is, all fixture
    %   teardown should be performed via the addTeardown method or through the
    %   appropriate object destructors should an assumption failure occur. This
    %   is important to ensure that the failure does not effect subsequent
    %   testing due to stale fixtures. If the failure condition should produce
    %   a test failure, consider using assertions or verifications instead.
    %
    %   If an assumption failure is encountered inside of a TestCase method
    %   with the "Test" attribute, the entire method is marked as filtered, and
    %   subsequent Test methods are run. Likewise, if an assumption failure is
    %   encountered inside of a TestCase method with the "TestMethodSetup" or
    %   "TestMethodTeardown" attributes, the method which was to be run for
    %   that instance is marked as filtered. If an Assumption failure is
    %   encountered inside of a TestCase method with the "TestClassSetup" or
    %   "TestClassTeardown" attributes, the entire TestCase class is filtered.
    %
    %   Since filtering test content through the use of assumptions does not
    %   produce test failures, it has the possibility of creating dead test
    %   code. Avoiding this requires monitoring of filtered tests.
    %
    %   Assumable events:
    %       AssumptionFailed - Event triggered upon a failing assumption
    %       AssumptionPassed - Event triggered upon a passing assumption
    %
    %   Assumable methods:
    %       assumeFail - Produce an unconditional assumption failure
    %       assumeThat - Assume that a value meets a given constraint
    %       assumeTrue - Assume that a value is true
    %       assumeFalse - Assume that a value is false
    %       assumeEqual - Assume the equality of a value to an expected
    %       assumeNotEqual - Assume a value is not equal to an expected
    %       assumeSameHandle - Assume two values are handles to the same instance
    %       assumeNotSameHandle - Assume a value isn't a handle to some instance
    %       assumeError - Assume a function throws a specific exception
    %       assumeWarning - Assume a function issues a specific warning
    %       assumeWarningFree - Assume a function issues no warnings
    %       assumeEmpty - Assume a value is empty
    %       assumeNotEmpty - Assume a value is not empty
    %       assumeSize - Assume a value has an expected size
    %       assumeLength - Assume a value has an expected length
    %       assumeNumElements - Assume a value has an expected element count
    %       assumeGreaterThan - Assume a value is larger than some floor
    %       assumeGreaterThanOrEqual - Assume a value is equal or larger than some floor
    %       assumeLessThan - Assume a value is less than some ceiling
    %       assumeLessThanOrEqual - Assume a value is equal or smaller than some ceiling
    %       assumeReturnsTrue - Assume a function returns true when evaluated
    %       assumeInstanceOf - Assume a value "isa" expected type
    %       assumeClass - Assume the exact class of some value
    %       assumeSubstring - Assume a string contains an expected string
    %       assumeMatches - Assume a string matches a regular expression
    %
    %
    %   See also
    %       Assertable
    %       FatalAssertable
    %       Verifiable
    %       matlab.unittest.TestCase
    %
    
    % Copyright 2010-2017 The MathWorks, Inc.
    
    events (NotifyAccess=private)
        % AssumptionFailed - Event triggered upon a failing assumption.
        %   The AssumptionFailed event provides a means to observe and react to
        %   failing assumptions. Callback functions listening to the event
        %   receive information about the failing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssumptionFailed;
        
        % AssumptionPassed - Event triggered upon a passing assumption.
        %   The AssumptionPassed event provides a means to observe and react to
        %   passing assumptions. Callback functions listening to the event
        %   receive information about the passing qualification including
        %   the actual value, constraint applied, diagnostic result and
        %   stack information in the form of QualificationEventData
        %
        %   See also: matlab.unittest.qualifications.QualificationEventData
        AssumptionPassed;
    end
    
    properties(Access=private)
        AssumptionDelegate (1,1) matlab.unittest.internal.qualifications.AssumptionDelegate;
    end
    
    properties(Transient,Access=private)
        AssumptionOnFailureTasks matlab.unittest.internal.Task;
    end
    
    methods(Sealed)
        function assumeFail(assumable, varargin)
            % assumeFail - Produce an unconditional assumption failure
            %
            %   assumeFail(ASSUMABLE) produces an unconditional assumption failure when
            %   encountered. ASSUMABLE is the instance which is used to fail the
            %   assumption in conjunction with the test running framework.
            %
            %   assumeFail(ASSUMABLE, DIAGNOSTIC) also provides diagnostic information
            %   in DIAGNOSTIC for the failure. DIAGNOSTIC can be a string, a function
            %   handle, or any matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   An example of where this method might be used is in a placeholder for a
            %   test that is under development. This method can be used to cause an
            %   unconditional assumption failure in a test, reminding the user of the
            %   test that needs to be developed for the corresponding feature.
            %
            %   Examples:
            %
            %     classdef testFeature < matlab.unittest.TestCase
            %         methods(Test)
            %             function testDefaultBehavior(testCase)
            %                 testCase.assumeFail('Please add a test to validate the default behavior of the feature.');
            %             end
            %         end
            %     end
            %
            %   See also
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFail(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                varargin{:});
        end
        
        function assumeThat(assumable, actual, constraint, varargin)
            % assumeThat - Assume that a value meets a given constraint
            %
            %   assumeThat(ASSUMABLE, ACTUAL, CONSTRAINT) assumes that ACTUAL is a
            %   value that satisfies the CONSTRAINT provided. If the constraint is not
            %   satisfied, a assumption failure is produced utilizing only the
            %   diagnostic generated by the CONSTRAINT. ASSUMABLE is the instance which
            %   is used to pass or fail the assumption in conjunction with the test
            %   running framework.
            %
            %   assumeThat(ASSUMABLE, ACTUAL, CONSTRAINT, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any
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
            %       testCase.assumeThat(true, IsTrue);
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       testCase.assumeThat(5, IsEqualTo(5), '5 should be equal to 5');
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       import matlab.unittest.constraints.HasNaN;
            %       testCase.assumeThat([5 NaN], IsGreaterThan(10) | HasNaN, ...
            %           'The value was not greater than 10 or NaN');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       import matlab.unittest.constraints.AnyCellOf;
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       testCase.assumeThat( AnyCellOf({'cell','of','strings'}), ...
            %           ContainsSubstring('char'),'Test description');
            %
            %       import matlab.unittest.constraints.HasSize;
            %       testCase.assumeThat(zeros(10,4,2), HasSize([10,5,2]), ...
            %           @() disp('A function handle diagnostic.'));
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       testCase.assumeThat(5, IsEmpty);
            %
            %   See also
            %       matlab.unittest.constraints.Constraint
            %       matlab.unittest.constraints
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyThat(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, constraint, ...
                varargin{:});
        end
        
        function assumeTrue(assumable, actual, varargin)
            % assumeTrue - Assume that a value is true
            %
            %   assumeTrue(ASSUMABLE, ACTUAL) assumes that ACTUAL is a scalar logical
            %   with the value of true. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsTrue;
            %       ASSUMABLE.assumeThat(ACTUAL, IsTrue());
            %
            %   However, this method is optimized for performance and does not
            %   construct a new IsTrue constraint for each call. Sometimes such use can
            %   come at the expense of less diagnostic information. Use the
            %   assumeReturnsTrue method for a similar approach which may provide
            %   better diagnostic information.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsTrue constraint directly via assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeTrue(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.assumeTrue(true);
            %       testCase.assumeTrue(true, 'true should be true');
            %       % Optimized comparison that trades speed for less diagnostics
            %       testCase.assumeTrue(contains('string', 'ring'), ...
            %           'Could not find expected string');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeTrue(false);
            %       testCase.assumeTrue(1, 'A double value of 1 is not true');
            %       testCase.assumeTrue([true true true], ...
            %           'An array of logical trues are not the one true value');
            %
            %   See also
            %       matlab.unittest.constraints.IsTrue
            %       assumeThat
            %       assumeFalse
            %       assumeReturnsTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyTrue(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeFalse(assumable, actual, varargin)
            % assumeFalse - Assume that a value is false
            %
            %   assumeFalse(ASSUMABLE, ACTUAL) assumes that ACTUAL is a scalar logical
            %   with the value of false. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsFalse;
            %       ASSUMABLE.assumeThat(ACTUAL, IsFalse());
            %
            %   Unlike assumeTrue, this method may create a new constraint for
            %   each call. For performance critical uses, consider using assumeTrue.
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsFalse constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeFalse(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.assumeFalse(false);
            %       testCase.assumeFalse(false, 'false should be false');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeFalse(true);
            %       testCase.assumeFalse(0, 'A double with a value of 0 is not false');
            %       testCase.assumeFalse([false true false], ...
            %           'A mixed array of logicals is not the one false value');
            %       testCase.assumeFalse([false false false], ...
            %           'A false array is not the one false value');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsFalse
            %       assumeThat
            %       assumeTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyFalse(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeEqual(assumable, actual, expected, varargin)
            % assumeEqual - Assume the equality of a value to an expected
            %
            %   assumeEqual(ASSUMABLE, ACTUAL, EXPECTED) assumes that ACTUAL is
            %   strictly equal to EXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       ASSUMABLE.assumeThat(ACTUAL, IsEqualTo(EXPECTED));
            %
            %   assumeEqual(ASSUMABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL) assumes
            %   that ACTUAL is equal to EXPECTED within an absolute tolerance of
            %   ABSTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       ASSUMABLE.assumeThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL)));
            %
            %   assumeEqual(ASSUMABLE, ACTUAL, EXPECTED, 'RelTol', RELTOL) assumes
            %   that ACTUAL is equal to EXPECTED within a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       ASSUMABLE.assumeThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', RelativeTolerance(RELTOL)));
            %
            %   assumeEqual(ASSUMABLE, ACTUAL, EXPECTED, 'AbsTol', ABSTOL, 'RelTol', RELTOL)
            %   assumes that every element of ACTUAL is equal to EXPECTED within
            %   either an absolute tolerance of ABSTOL or a relative tolerance of
            %   RELTOL. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       import matlab.unittest.constraints.AbsoluteTolerance;
            %       import matlab.unittest.constraints.RelativeTolerance;
            %       ASSUMABLE.assumeThat(ACTUAL, IsEqualTo(EXPECTED, ...
            %           'Within', AbsoluteTolerance(ABSTOL) | RelativeTolerance(RELTOL)));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo, AbsoluteTolerance, and
            %   RelativeTolerance constraints directly via assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeEqual(ASSUMABLE, ACTUAL, EXPECTED, ..., DIAGNOSTIC) also provides
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
            %       testCase.assumeEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.assumeEqual(5, 5, '5 should be equal to 5');
            %       testCase.assumeEqual(1.5, 2, 'AbsTol', 1)
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeEqual(4.95, 5, '4.95 is not equal to 5');
            %       testCase.assumeEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.assumeEqual(int8(5), int16(5), 'Classes must match');
            %       testCase.assumeEqual(1.5, 2, 'RelTol', 0.1, ...
            %           'Difference between actual and expected exceeds relative tolerance')
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.AbsoluteTolerance
            %       matlab.unittest.constraints.RelativeTolerance
            %       assumeThat
            %       assumeNotEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEqual(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expected, ...
                varargin{:});
        end
        
        function assumeNotEqual(assumable, actual, notExpected, varargin)
            % assumeNotEqual - Assume a value is not equal to an expected
            %
            %   assumeNotEqual(ASSUMABLE, ACTUAL, NOTEXPECTED) assumes that ACTUAL is
            %   not equal to NOTEXPECTED. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEqualTo;
            %       ASSUMABLE.assumeThat(ACTUAL, ~IsEqualTo(NOTEXPECTED));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEqualTo constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeNotEqual(ASSUMABLE, ACTUAL, NOTEXPECTED, DIAGNOSTIC) also
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
            %       testCase.assumeNotEqual(4.95, 5, '4.95 should be different from 5');
            %       testCase.assumeNotEqual([5 5], 5, '[5 5] is not equal to 5');
            %       testCase.assumeNotEqual(int8(5), int16(5), 'Classes do not match');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeNotEqual({'cell', struct, 5}, {'cell', struct, 5});
            %       testCase.assumeNotEqual(5, 5);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEqualTo
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assumeThat
            %       assumeEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEqual(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, notExpected, ...
                varargin{:});
        end
        
        function assumeSameHandle(assumable, actual, expectedHandle, varargin)
            % assumeSameHandle - Assume two values are handles to the same instance
            %
            %   assumeSameHandle(ASSUMABLE, ACTUAL, EXPECTEDHANDLE) assumes that ACTUAL
            %   is the same size and contains the same instances as the EXPECTEDHANDLE
            %   handle array. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       ASSUMABLE.assumeThat(ACTUAL, IsSameHandleAs(EXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeSameHandle(ASSUMABLE, ACTUAL, EXPECTEDHANDLE, DIAGNOSTIC) also
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
            %       testCase.assumeSameHandle(h1, h1, 'They should be the same handle.');
            %       testCase.assumeSameHandle([h1 h1], [h1 h1]);
            %       testCase.assumeSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeSameHandle(h1, h2, 'handles were not the same');
            %       testCase.assumeSameHandle([h1 h1], h1);
            %       testCase.assumeSameHandle(h2, [h2 h2]);
            %       testCase.assumeSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       assumeThat
            %       assumeNotSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySameHandle(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedHandle, ...
                varargin{:});
        end
        
        function assumeNotSameHandle(assumable, actual, notExpectedHandle, varargin)
            % assumeNotSameHandle - Assume a value isn't a handle to some instance
            %
            %   assumeNotSameHandle(ASSUMABLE, ACTUAL, NOTEXPECTEDHANDLE) assumes that
            %   ACTUAL is a different size same size and/or does not contain the same
            %   instances as the NOTEXPECTEDHANDLE handle array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsSameHandleAs;
            %       ASSUMABLE.assumeThat(ACTUAL, ~IsSameHandleAs(NOTEXPECTEDHANDLE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsSameHandleAs constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeNotSameHandle(ASSUMABLE, ACTUAL, NOTEXPECTEDHANDLE, DIAGNOSTIC)
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
            %       testCase.assumeNotSameHandle(h1, h2, 'Handles were the same');
            %       testCase.assumeNotSameHandle([h1 h1], h1);
            %       testCase.assumeNotSameHandle(h2, [h2 h2]);
            %       testCase.assumeNotSameHandle([h1 h2], [h2 h1], 'Order is important');
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeNotSameHandle(h1, h1, 'They should not be the same handle.');
            %       testCase.assumeNotSameHandle([h1 h1], [h1 h1]);
            %       testCase.assumeNotSameHandle([h1 h2 h1], [h1 h2 h1]);
            %
            %   See also
            %       matlab.unittest.constraints.IsSameHandleAs
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assumeThat
            %       assumeSameHandle
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotSameHandle(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, notExpectedHandle, ...
                varargin{:});
        end
        
        function varargout = assumeError(assumable, actual, errorClassOrID, varargin)
            % assumeError - Assume a function throws a specific exception
            %
            %   assumeError(ASSUMABLE, ACTUAL, IDENTIFIER) assumes that ACTUAL is a
            %   function handle that throws an exception with an error identifier that
            %   is equal to the string IDENTIFIER.
            %
            %   assumeError(ASSUMABLE, ACTUAL, METACLASS)  assumes that ACTUAL is a
            %   function handle that throws an exception whose type is defined by the
            %   meta.class instance specified in  METACLASS. This method does not
            %   require the instance to be an exact class match, but rather it must be
            %   in the specified class hierarchy, and that hierarchy must include the
            %   MException class.
            %
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Throws;
            %       ASSUMABLE.assumeThat(ACTUAL, Throws(IDENTIFIER));
            %       ASSUMABLE.assumeThat(ACTUAL, Throws(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Throws constraint directly via assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeError(ASSUMABLE, ACTUAL, ERRORCLASSORID, DIAGNOSTIC) also
            %   provides diagnostic information in DIAGNOSTIC upon a failure.
            %   DIAGNOSTIC can be a string, a function handle, or any
            %   matlab.unittest.diagnostics.Diagnostic implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assumeError(ASSUMABLE, ACTUAL, ERRORCLASSORID, ...)
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
            %       testCase.assumeError(@() error('SOME:error:id','Error!'), 'SOME:error:id');
            %       testCase.assumeError(@testCase.assertFail, ...
            %           ?matlab.unittest.qualifications.AssumptionFailedException);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeError(5, 'some:id', '5 is not a function handle');
            %       testCase.assumeError(@testCase.verifyFail(), ...
            %           ?matlab.unittest.qualifications.AssumptionFailedException, ...
            %           'Verifications do not throw exceptions.');
            %       testCase.assumeError(@() error('SOME:id'), 'OTHER:id', 'Wrong id');
            %       testCase.assumeError(@() error('whoops'), ...
            %           ?matlab.unittest.qualifications.AssumptionFailedException, ...
            %           'Wrong type of exception thrown');
            %
            %   See also
            %       matlab.unittest.constraints.Throws
            %       assumeThat
            %       assumeWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyError(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, errorClassOrID, ...
                varargin{:});
        end
        
        function varargout = assumeWarning(assumable, actual, warningID, varargin)
            % assumeWarning - Assume a function issues a specific warning
            %
            %   assumeWarning(ASSUMABLE, ACTUAL, WARNINGID) assumes that ACTUAL is a
            %   function handle that issues a warning with a warning identifier that is
            %   equal to the string WARNINGID. The function call will ignore any other
            %   warnings that may also be issued by the function call, and only
            %   confirms that the warning specified was issued at least once. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IssuesWarnings;
            %       ASSUMABLE.assumeThat(ACTUAL, IssuesWarnings({WARNINGID}));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesWarnings constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeWarning(ASSUMABLE, ACTUAL, WARNINGID, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assumeWarning(ASSUMABLE, ACTUAL, WARNINGID, ...)
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
            %       testCase.assumeWarning(@() warning('SOME:warning:id','Warning!'), ...
            %           'SOME:warning:id');
            %
            %       % return function outputs
            %       [actualOut1, actualOut2] = testCase.assumeWarning(@helper, ... %HELPER defined below
            %           'SOME:warning:id');
            %        function varargout = helper()
            %           warning('SOME:warning:id','Warning!');
            %           varargout = {123, 'abc'};
            %        end
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assumeWarning(@true, 'SOME:warning:id', '@true did not issue any warning');
            %       testCase.assumeWarning(@() warning('SOME:other:id', 'Warning message'), 'SOME:warning:id',...
            %           'Did not issue specified warning');
            %
            %   See also
            %       matlab.unittest.constraints.IssuesWarnings
            %       assumeThat
            %       assumeError
            %       assumeWarningFree
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarning(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, warningID, ...
                varargin{:});
        end
        
        function varargout = assumeWarningFree(assumable, actual, varargin)
            % assumeWarningFree - Assume a function issues no warnings
            %
            %   assumeWarningFree(ASSUMABLE, ACTUAL) assumes that ACTUAL is a function
            %   handle that issues no warnings. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.IssuesNoWarnings;
            %       ASSUMABLE.assumeThat(ACTUAL, IssuesNoWarnings());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IssuesNoWarnings constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeWarningFree(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   [OUTPUT1, OUTPUT2, ...] = assumeWarningFree(ASSUMABLE, ACTUAL, ...)
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
            %       testCase.assumeWarningFree(@why);
            %       testCase.assumeWarningFree(@true, ...
            %           'Simple call to true issues no warnings');
            %       actualOutputFromFalse = testCase.assumeWarningFree(@false);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assumeWarningFree(5,'diagnostic');
            %
            %       % Issues a warning
            %       testCase.assumeWarningFree(@() warning('some:id', 'Message'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.IssuesNoWarnings
            %       assumeThat
            %       assumeWarning
            %       matlab.unittest.diagnostics.Diagnostic
            %
            [varargout{1:nargout}] = qualifyWarningFree(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeEmpty(assumable, actual, varargin)
            % assumeEmpty - Assume a value is empty
            %
            %   assumeEmpty(ASSUMABLE, ACTUAL) assumes that ACTUAL is an empty MATLAB
            %   value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       ASSUMABLE.assumeThat(ACTUAL, IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeEmpty(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.assumeEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.assumeEmpty('','empty string should be empty');
            %       testCase.assumeEmpty(MException.empty, 'empty MException should be empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeEmpty([2 3]);
            %       testCase.assumeEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       assumeThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyEmpty(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeNotEmpty(assumable, actual, varargin)
            % assumeNotEmpty - Assume a value is not empty
            %
            %   assumeNotEmpty(ASSUMABLE, ACTUAL) assumes that ACTUAL is a non-empty
            %   MATLAB value. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsEmpty;
            %       ASSUMABLE.assumeThat(ACTUAL, ~IsEmpty());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsEmpty constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeNotEmpty(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides diagnostic
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
            %       testCase.assumeNotEmpty([2 3]);
            %       testCase.assumeNotEmpty({[], [], []}, 'cell array of empties is not empty');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       % is not a function handle
            %       testCase.assumeNotEmpty(ones(2, 5, 0, 3), 'empty with any zero dimension');
            %       testCase.assumeNotEmpty('','empty string is empty');
            %       testCase.assumeNotEmpty(MException.empty, 'empty MException is empty');
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsEmpty
            %       matlab.unittest.constraints.BooleanConstraint.not
            %       assumeThat
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyNotEmpty(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeSize(assumable, actual, expectedSize, varargin)
            % assumeSize - Assume a value has an expected size
            %
            %   assumeSize(ASSUMABLE, ACTUAL, EXPECTEDSIZE) assumes that ACTUAL is a
            %   MATLAB array whose size is EXPECTEDSIZE. This method is functionally
            %   equivalent to:
            %
            %       import matlab.unittest.constraints.HasSize;
            %       ASSUMABLE.assumeThat(ACTUAL, HasSize(EXPECTEDSIZE));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasSize constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeSize(ASSUMABLE, ACTUAL, EXPECTEDSIZE, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
            %
            %   Examples:
            %       % Create a TestCase for interactive use
            %       testCase = matlab.unittest.TestCase.forInteractiveUse;
            %
            %       % Passing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeSize(ones(2, 5, 3), [2 5 3], 'ones produces correct array');
            %       testCase.assumeSize({'SomeString', 'SomeOtherString'}, [1 2]);
            %       testCase.assumeSize([1 2 3; 4 5 6], [2 3]);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeSize([2 3], [3 2], 'Incorrect size');
            %       testCase.assumeSize([1 2 3; 4 5 6], [6 1]);
            %       testCase.assumeSize(eye(2), [4 1]);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasSize
            %       assumeThat
            %       assumeLength
            %       assumeNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySize(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedSize, ...
                varargin{:});
        end
        
        function assumeLength(assumable, actual, expectedLength, varargin)
            % assumeLength - Assume a value has an expected length
            %
            %   assumeLength(ASSUMABLE, ACTUAL, EXPECTEDLENGTH) assumes that ACTUAL is
            %   a MATLAB array whose length is EXPECTEDLENGTH. The length of an array
            %   is defined as the largest dimension of that array. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasLength;
            %       ASSUMABLE.assumeThat(ACTUAL, HasLength(EXPECTEDLENGTH));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasLength constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeLength(ASSUMABLE, ACTUAL, EXPECTEDLENGTH, DIAGNOSTIC) also
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
            %       testCase.assumeLength(ones(2, 5, 3), 5);
            %       testCase.assumeLength(ones(2, 5, 3), 5, 'Test diagnostic');
            %       testCase.assumeLength({'somestring', 'someotherstring'}, 2);
            %       testCase.assumeLength([1 2 3; 4 5 6], 3);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeLength([2 3], 3);
            %       testCase.assumeLength([1 2 3; 4 5 6], 6);
            %       testCase.assumeLength(eye(2), 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasLength
            %       assumeThat
            %       assumeSize
            %       assumeNumElements
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLength(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedLength, ...
                varargin{:});
        end
        
        function assumeNumElements(assumable, actual, expectedElementCount, varargin)
            % assumeNumElements - Assume a value has an expected element count
            %
            %   assumeNumElements(ASSUMABLE, ACTUAL, EXPECTEDELEMENTCOUNT) assumes that
            %   ACTUAL is a MATLAB array with EXPECTEDELEMENTCOUNT number of elements.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.HasElementCount;
            %       ASSUMABLE.assumeThat(ACTUAL, HasElementCount(EXPECTEDELEMENTCOUNT));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the HasElementCount constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeNumElements(ASSUMABLE, ACTUAL, EXPECTEDELEMENTCOUNT, DIAGNOSTIC)
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
            %       testCase.assumeNumElements(eye(n), n^2);
            %       testCase.assumeNumElements(eye(n), n^2, 'eye should produce a square matrix');
            %       testCase.assumeNumElements({'SomeString', 'SomeOtherString'}, 2);
            %       testCase.assumeNumElements(3, 1);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeNumElements([1 2 3; 4 5 6], 5);
            %       s.Field1 = 1;
            %       s.Field2 = 2;
            %       testCase.assumeNumElements(s, 2, 'structure only has one element');
            %
            %
            %   See also
            %       matlab.unittest.constraints.HasElementCount
            %       assumeThat
            %       assumeSize
            %       assumeLength
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyNumElements(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedElementCount, ...
                varargin{:});
        end
        
        function assumeGreaterThan(assumable, actual, floor, varargin)
            % assumeGreaterThan - Assume a value is larger than some floor
            %
            %   assumeGreaterThan(ASSUMABLE, ACTUAL, FLOOR) assumes that all elements
            %   of ACTUAL are greater than all the elements of FLOOR. ACTUAL must be
            %   the same size as FLOOR unless either one is scalar, at which point
            %   scalar expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThan;
            %       ASSUMABLE.assumeThat(ACTUAL, IsGreaterThan(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThan constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeGreaterThan(ASSUMABLE, ACTUAL, FLOOR, DIAGNOSTIC) also provides
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
            %       testCase.assumeGreaterThan(3, 2, '3 should be greater than 2');
            %       testCase.assumeGreaterThan([5 6 7], 2);
            %       testCase.assumeGreaterThan(5, [1 2 3]);
            %       testCase.assumeGreaterThan([5 -3 2], [4 -9 0]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeGreaterThan(5, 9);
            %       testCase.assumeGreaterThan([1 2 3; 4 5 6], 4);
            %       testCase.assumeGreaterThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       assumeThat
            %       assumeGreaterThanOrEqual
            %       assumeLessThan
            %       assumeLessThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyGreaterThan(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function assumeGreaterThanOrEqual(assumable, actual, floor, varargin)
            % assumeGreaterThanOrEqual - Assume a value is equal or larger than some floor
            %
            %   assumeGreaterThanOrEqual(ASSUMABLE, ACTUAL, FLOOR) assumes that all
            %   elements of ACTUAL are greater than or equal to all the elements of
            %   FLOOR. ACTUAL must be the same size as FLOOR unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsGreaterThanOrEqualTo;
            %       ASSUMABLE.assumeThat(ACTUAL, IsGreaterThanOrEqualTo(FLOOR));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsGreaterThanOrEqualTo constraint directly
            %   via assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeGreaterThanOrEqual(ASSUMABLE, ACTUAL, FLOOR, DIAGNOSTIC) also
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
            %       testCase.assumeGreaterThanOrEqual(3, 2, '3 is greater than 2');
            %       testCase.assumeGreaterThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.assumeGreaterThanOrEqual([5 2 7], 2);
            %       testCase.assumeGreaterThanOrEqual([5 -3 2], [4 -3 0]);
            %       testCase.assumeGreaterThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeGreaterThanOrEqual(5, 9);
            %       testCase.assumeGreaterThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %   See also
            %       matlab.unittest.constraints.IsGreaterThan
            %       assumeThat
            %       assumeGreaterThan
            %       assumeLessThanOrEqual
            %       assumeLessThan
            %       matlab.unittest.diagnostics.Diagnostic
            %
            
            qualifyGreaterThanOrEqual(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, floor, ...
                varargin{:});
        end
        
        function assumeLessThan(assumable, actual, ceiling, varargin)
            % assumeLessThan - Assume a value is less than some ceiling
            %
            %   assumeLessThan(ASSUMABLE, ACTUAL, CEILING) assumes that all elements of
            %   ACTUAL are less than all the elements of CEILING. ACTUAL must be the
            %   same size as CEILING unless either one is scalar, at which point scalar
            %   expansion occurs. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThan;
            %       ASSUMABLE.assumeThat(ACTUAL, IsLessThan(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThan constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeLessThan(ASSUMABLE, ACTUAL, CEILING, DIAGNOSTIC) also provides
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
            %       testCase.assumeLessThan(2, 3, '2 is less than 3');
            %       testCase.assumeLessThan([5 6 7], 9);
            %       testCase.assumeLessThan([5 -3 2], [7 -1 8]);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeLessThan(9, 5);
            %       testCase.assumeLessThan([1 2 3; 4 5 6], 4);
            %       testCase.assumeLessThan(eye(2), eye(2));
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThan
            %       assumeThat
            %       assumeLessThanOrEqual
            %       assumeGreaterThan
            %       assumeGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThan(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function assumeLessThanOrEqual(assumable, actual, ceiling, varargin)
            % assumeLessThanOrEqual - Assume a value is equal or smaller than some ceiling
            %
            %   assumeLessThanOrEqual(ASSUMABLE, ACTUAL, CEILING) assumes that all
            %   elements of ACTUAL are less than or equal to all the elements of
            %   CEILING. ACTUAL must be the same size as CEILING unless either one is
            %   scalar, at which point scalar expansion occurs. This method is
            %   functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsLessThanOrEqualTo;
            %       ASSUMABLE.assumeThat(ACTUAL, IsLessThanOrEqualTo(CEILING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsLessThanOrEqualTo constraint directly
            %   via assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeLessThanOrEqual(ASSUMABLE, ACTUAL, CEILING, DIAGNOSTIC) also
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
            %       testCase.assumeLessThanOrEqual(2, 3, '2 is less than 3');
            %       testCase.assumeLessThanOrEqual(3, 3, '3 is equal to 3');
            %       testCase.assumeLessThanOrEqual([5 2 7], 7);
            %       testCase.assumeLessThanOrEqual([5 -3 2], [5 -3 8]);
            %       testCase.assumeLessThanOrEqual(eye(2), eye(2));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeLessThanOrEqual(9, 5);
            %       testCase.assumeLessThanOrEqual([1 2 3; 4 5 6], 4);
            %
            %
            %   See also
            %       matlab.unittest.constraints.IsLessThanOrEqual
            %       assumeThat
            %       assumeLessThan
            %       assumeGreaterThan
            %       assumeGreaterThanOrEqual
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyLessThanOrEqual(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ceiling, ...
                varargin{:});
        end
        
        function assumeReturnsTrue(assumable, actual, varargin)
            % assumeReturnsTrue - Assume a function returns true when evaluated
            %
            %   assumeReturnsTrue(ASSUMABLE, ACTUAL) assumes that ACTUAL is a function
            %   handle that returns a scalar logical whose value is true. It is a
            %   shortcut for quick custom comparison functionality that can be defined
            %   quickly, and possibly inline. It can be preferable over simply
            %   evaluating the function directly and using assumeTrue because the
            %   function handle will be shown in the diagnostics, thus providing more
            %   insight into the failure condition which is lost when using assumeTrue.
            %   This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.ReturnsTrue;
            %       ASSUMABLE.assumeThat(ACTUAL, ReturnsTrue());
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ReturnsTrue constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeReturnsTrue(ASSUMABLE, ACTUAL, DIAGNOSTIC) also provides
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
            %       testCase.assumeReturnsTrue(@true, '@true should return true');
            %       testCase.assumeReturnsTrue(@() isequal(1,1));
            %       testCase.assumeReturnsTrue(@() ~strcmp('a','b'));
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeReturnsTrue(@false);
            %       testCase.assumeReturnsTrue(@() strcmp('a',{'a','a'}));
            %       testCase.assumeReturnsTrue(@() exist('exist'));
            %
            %
            %   See also
            %       matlab.unittest.constraints.ReturnsTrue
            %       assumeThat
            %       assumeTrue
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyReturnsTrue(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, ...
                varargin{:});
        end
        
        function assumeInstanceOf(assumable, actual, expectedBaseClass, varargin)
            % assumeInstanceOf - Assume a value "isa" expected type
            %
            %   assumeInstanceOf(ASSUMABLE, ACTUAL, CLASSNAME) assumes that ACTUAL is a
            %   MATLAB value that is an instance of the class specified by the
            %   CLASSNAME string.
            %
            %   assumeInstanceOf(ASSUMABLE, ACTUAL, METACLASS) assumes that ACTUAL is a
            %   MATLAB value that is an instance of the class specified by
            %   the meta.class instance METACLASS.
            %
            %   This method does not require the instance to be an exact class match,
            %   but rather it must be in the specified class hierarchy. See assumeClass
            %   to assume the exact class. This method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsInstanceOf;
            %       ASSUMABLE.assumeThat(ACTUAL, IsInstanceOf(CLASSNAME));
            %       ASSUMABLE.assumeThat(ACTUAL, IsInstanceOf(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsInstanceOf constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeInstanceOf(ASSUMABLE, ACTUAL, EXPECTEDBASECLASS, DIAGNOSTIC) also
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
            %       testCase.assumeInstanceOf(5, 'double', '5 should be a double');
            %       testCase.assumeInstanceOf(@sin, ?function_handle);
            %       testCase.assumeInstanceOf(DerivedExample(), ?BaseExample);
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeInstanceOf(5, 'char');
            %       testCase.assumeInstanceOf('sin', ?function_handle);
            %       testCase.assumeInstanceOf(BaseExample(), ?DerivedExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsInstanceOf
            %       assumeThat
            %       assumeClass
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyInstanceOf(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedBaseClass, ...
                varargin{:});
        end
        
        function assumeClass(assumable, actual, expectedClass, varargin)
            % assumeClass - Assume the exact class of some value
            %
            %   assumeClass(ASSUMABLE, ACTUAL, CLASSNAME) assumes that ACTUAL is a
            %   MATLAB value whose class is the class specified by the CLASSNAME
            %   string.
            %
            %   assumeClass(ASSUMABLE, ACTUAL, METACLASS) assumes that ACTUAL is a
            %   MATLAB value whose class is the class specified by the
            %   meta.class instance METACLASS.
            %
            %   This method requires the instance to be an exact class match. See
            %   assumeInstanceOf to assume inclusion in a class hierarchy. This method
            %   is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.IsOfClass;
            %       ASSUMABLE.assumeThat(ACTUAL, IsOfClass(CLASSNAME));
            %       ASSUMABLE.assumeThat(ACTUAL, IsOfClass(METACLASS));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the IsOfClass constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeClass(ASSUMABLE, ACTUAL, EXPECTEDCLASS, DIAGNOSTIC) also provides
            %   diagnostic information in DIAGNOSTIC upon a failure. DIAGNOSTIC can be
            %   a string, a function handle, or any matlab.unittest.diagnostics.Diagnostic
            %   implementation.
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
            %       testCase.assumeClass(5, 'double', '5 should be a double');
            %       testCase.assumeClass(@sin, ?function_handle);
            %
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeClass(5, 'char');
            %       testCase.assumeClass('sin', ?function_handle);
            %       testCase.assumeClass(DerivedExample(), ?BaseExample);
            %
            %   See also
            %       matlab.unittest.constraints.IsOfClass
            %       assumeThat
            %       assumeInstanceOf
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyClass(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expectedClass, ...
                varargin{:});
        end
        
        function assumeSubstring(assumable, actual, substring, varargin)
            % assumeSubstring - Assume a string contains an expected string
            %
            %   assumeSubstring(ASSUMABLE, ACTUAL, SUBSTRING) assumes that ACTUAL is a
            %   string that contains SUBSTRING. This method is functionally equivalent
            %   to:
            %
            %       import matlab.unittest.constraints.ContainsSubstring;
            %       ASSUMABLE.assumeThat(ACTUAL, ContainsSubstring(SUBSTRING));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the ContainsSubstring constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeSubstring(ASSUMABLE, ACTUAL, SUBSTRING, DIAGNOSTIC) also provides
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
            %       testCase.assumeSubstring('SomeLongString', 'Long');
            %       testCase.assumeSubstring('SomeLongString', 'Long', ...
            %           'Long should be a substring');
            %
            %       % Failing scenarios %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeSubstring('SomeLongString', 'lonG');
            %       testCase.assumeSubstring('SomeLongString', 'OtherString');
            %       testCase.assumeSubstring('SomeLongString', 'SomeLongStringThatIsLonger');
            %
            %
            %   See also
            %       matlab.unittest.constraints.ContainsSubstring
            %       assumeThat
            %       assumeMatches
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifySubstring(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, substring, ...
                varargin{:});
        end
        
        function assumeMatches(assumable, actual, expression, varargin)
            % assumeMatches - Assume a string matches a regular expression
            %
            %   assumeMatches(ASSUMABLE, ACTUAL, EXPRESSION) assumes that ACTUAL is a
            %   string that matches the regular expression defined by EXPRESSION. This
            %   method is functionally equivalent to:
            %
            %       import matlab.unittest.constraints.Matches;
            %       ASSUMABLE.assumeThat(ACTUAL, Matches(EXPRESSION));
            %
            %   Please note this method is a convenience method. There exists more
            %   functionality when using the Matches constraint directly via
            %   assumeThat.
            %
            %   ASSUMABLE is the instance which is used to pass or fail the assumption
            %   in conjunction with the test running framework.
            %
            %   assumeMatches(ASSUMABLE, ACTUAL, EXPRESSION, DIAGNOSTIC) also provides
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
            %       testCase.assumeMatches('Some String', 'Some [Ss]tring', ...
            %           'My result should have matched the expression');
            %       testCase.assumeMatches('Another string', '(Some |An)other');
            %       testCase.assumeMatches('Another 3 strings', '^Another \d+ strings?$');
            %
            %       % Failing scenarios
            %       %%%%%%%%%%%%%%%%%%%%
            %       testCase.assumeMatches('3 more strings', '\d+ strings?');
            %
            %   See also
            %       matlab.unittest.constraints.Matches
            %       assumeThat
            %       assumeSubstring
            %       matlab.unittest.diagnostics.Diagnostic
            %
            qualifyMatches(assumable.AssumptionDelegate, ...
                assumable.getNotificationData(), ...
                actual, expression, ...
                varargin{:});
        end
    end
    
    methods (Access=private)
        function notificationData = getNotificationData(assumable)
            notificationData = struct( ...
                'HasPassedListener',@()event.hasListener(assumable, 'AssumptionPassed'), ...
                'NotifyPassed',@(evd)assumable.notify('AssumptionPassed', evd), ...
                'NotifyFailed',@(evd)assumable.notify('AssumptionFailed', evd),...
                'OnFailureDiagnostics',@()assumable.AssumptionOnFailureTasks.getAssumptionDiagnostics,...
                'DiagnosticData',assumable.DiagnosticData);
        end
    end
    
    methods(Hidden, Access=protected) % Not directly instantiable
        function assumable = Assumable(delegate)
            
            if nargin < 1
                delegate = matlab.unittest.internal.qualifications.AssumptionDelegate;
            end
            assumable.AssumptionDelegate = delegate;
            
        end
    end
    
    methods (Hidden)
        function onFailure(assumable, task)
            assumable.AssumptionOnFailureTasks = [assumable.AssumptionOnFailureTasks, task];
        end
    end
end

% LocalWords:  evd ABSTOL RELTOL NOTEXPECTED evd ABSTOL RELTOL NOTEXPECTED evd
% LocalWords:  EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID ABSTOL RELTOL lh
% LocalWords:  NOTEXPECTED EXPECTEDHANDLE NOTEXPECTEDHANDLE ERRORCLASSORID
% LocalWords:  WARNINGID abc EXPECTEDSIZE EXPECTEDLENGTH somestring Substitutor
% LocalWords:  someotherstring EXPECTEDELEMENTCOUNT EXPECTEDBASECLASS
% LocalWords:  EXPECTEDCLASS lon tring
