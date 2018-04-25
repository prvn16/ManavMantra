% Unit Test Framework
%
% matlab.unittest is a MATLAB based implementation of the
% <a href="http://en.wikipedia.org/wiki/XUnit">xUnit paradigm</a>. It is implemented with an eye towards ease of use,
% extensibility, and modularity.
%
% TestCase Interface
% ------------------
%   The matlab.unittest.TestCase is the base class to be used in order to
%   define tests based on matlab.unittest. TestCase subclasses can
%   define test methods as well as methods designated to setup and tear down
%   test fixtures. The TestCase interface corresponds to the following
%   xUnit patterns:
%       * <a href="http://xunitpatterns.com/Testcase%20Class.html">Testcase Class</a>
%       * <a href="http://xunitpatterns.com/Testcase%20Object.html">Testcase Object</a>
%       * <a href="http://xunitpatterns.com/Test%20Method.html">Test Method</a>
%       * <a href="http://xunitpatterns.com/Four%20Phase%20Test.html">Four-Phase Test</a>
%
%   TestCase - Superclass of all test classes.
%
% TestSuite
% ----------
%   The TestSuite class is the fundamental interface for creating and
%   grouping tests together. The TestRunner operates on TestSuite arrays
%   which contain the information needed by the TestRunner to construct
%   instances of TestCase classes and run them. These arrays can be grouped
%   together through concatenation, and subsets of the suite can be created
%   through indexing operations.
%
%   TestSuite - Interface for grouping tests to run.
%   Test      - Specification of a single Test method.
%
% TestRunner
% ----------
%   The TestRunner is responsible for running test content defined in
%   TestCase subclasses and grouped together into TestSuite arrays. The
%   TestRunner class is the only supported class for running tests, but it
%   can be extended through the TestRunnerPlugin mechanism.
%
%   TestRunner               - Class used to run tests.
%   plugins                  - Plugins package.
%   plugins.TestRunnerPlugin - Plugin interface for extending the TestRunner.
%   
%
% TestResult
% ----------
%   The TestResult holds all of the information describing the result of a
%   test run. It is created by the TestRunner that runs a TestSuite, and
%   is the same size as the TestSuite being run.
%
%   TestResult - Result of a running a test suite.
%   
% Qualifications
% --------------
%   Qualifications are the means by which a test writer can select a
%   specific desired action upon qualification failures. Qualification
%   failures may or may not correspond to a test failure, and they may or
%   may not continue execution in the test when one is encountered. All
%   TestCase classes can themselves perform all of the qualifications
%   listed here.
%
%   qualifications - Qualifications package.
%   qualifications.Assertable - Qualification which fails and then filters test content.
%   qualifications.Assumable - Qualification which filters test content.
%   qualifications.FatalAssertable - Qualification which aborts test execution.
%   qualifications.Verifiable - Qualification which produces "soft" failure conditions.
%
% Constraints
% -----------
%   Constraints are the mechanism to specify business rules against which
%   to qualify a calculated value. Constraints are to be used in
%   conjunction with matlab.unittest qualifications through the
%   assertThat, assumeThat, fatalAssertThat, and verifyThat methods on
%   TestCase. Constraints encode whether or not any calculated (i.e.
%   actual) value satisfies the constraint. Also, they can provide
%   diagnostics for any value in the event the constraint is not satisfied
%   by the value.
%
%   constraints - Constraints package.
%   constraints.Constraint - Fundamental interface for matlab.unittest comparisons.
%   constraints.BooleanConstraint - Interface for boolean combinations of Constraints.
%   TestCase.assertThat - Assert that a value meets a given Constraint.
%   TestCase.assumeThat - Assume that a value meets a given Constraint.
%   TestCase.fatalAssertThat - Fatally assert that a value meets a given Constraint.
%   TestCase.verifyThat - Verify that a value meets a given Constraint.
%
%
% Diagnostics
% -----------
%   Diagnostics are the mechanism to communicate relevant information in
%   the event of a failure. Test writers can supply diagnostics when
%   performing qualifications. The framework also produces diagnostics
%   related to the nature of the qualification failure.
%
%   diagnostics - Diagnostics package.
%

% Copyright 2010-2013 The MathWorks, Inc.



% LocalWords:  wikipedia XUnit xunitpatterns
