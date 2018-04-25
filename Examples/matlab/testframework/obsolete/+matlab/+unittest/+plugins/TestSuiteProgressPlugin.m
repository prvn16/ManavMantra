classdef (Hidden) TestSuiteProgressPlugin < matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin
    
    % TestSuiteProgressPlugin is not recommended. Use TestRunProgressPlugin
    % instead. TestRunProgressPlugin provides the ability to run tests with
    % less detailed or more detailed progress information.
    % TestRunProgressPlugin.withVerbosity(2) provides the same detail as
    % TestSuiteProgressPlugin.
    
    % Copyright 2012-2014 The MathWorks, Inc.
    
    methods
        function plugin = TestSuiteProgressPlugin(varargin)
            plugin@matlab.unittest.plugins.testrunprogress.ConciseProgressPlugin(varargin{:});
        end
    end
end

% LocalWords:  testrunprogress
