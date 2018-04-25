% forInteractiveUse - Create a TestCase to use interactively.
%   TESTCASE = TestCase.forInteractiveUse creates a TestCase instance that
%   is configured for experimentation at the MATLAB command prompt.
%   TESTCASE is a matlab.unittest.TestCase instance that reacts to
%   qualification failures and successes by printing messages to standard
%   output (the screen) for both passing and failing conditions.
%
%   TESTCASE = TestCase.forInteractiveUse(TESTCLASS) creates an instance
%   of the specified class configured for experimentation at the MATLAB
%   Command Prompt.
%
%   Examples:
%       import matlab.unittest.TestCase;
%
%       % Create a TestCase configured for interactive use at the MATLAB
%       % Command Prompt.
%       testCase = TestCase.forInteractiveUse;
%
%       % Produce a passing verification.
%       testCase.verifyTrue(true, 'true should be true');
%
%       % Produce a failing verification.
%       testCase.verifyTrue(false);
%
%       % Create an interactive instance of MyTestClass
%       testCase = TestCase.forInteractiveUse(?MyTestClass);

%  Copyright 2013-2016 The MathWorks, Inc.

% LocalWords:  TESTCLASS
