classdef Scope
    % Scope - Specification of a scope of test execution
    %
    %   The matlab.unittest.Scope enumeration provides a means to specify a
    %   scope of test execution.

    % Copyright 2016 The MathWorks, Inc.
    enumeration
        % TestMethod - Scope for TestMethodSetup, Test, and TestMethodTeardown methods
        TestMethod
        
        % TestClass - Scope for TestClassSetup and TestClassTeardown methods
        TestClass
        
        % SharedTestFixture - Scope for shared test fixture setup and teardown methods
        SharedTestFixture
    end
end