classdef FinalizedResultPluginData < matlab.unittest.plugins.plugindata.PluginData
    % FinalizedResultPluginData - Data about finalized test results.
    %
    %   The FinalizedResultPluginData class holds information about a test
    %   result that is finalized
    %
    %   FinalizedResultPluginData properties:
    %       Index      - Location of the result relative to the entire suite.
    %       TestSuite  - Specification of the Test element.
    %       TestResult - Test result element that is finalized.
    %
    %   See also: matlab.unittest.plugins.TestRunnerPlugin
    
    % Copyright 2014-2015 The MathWorks, Inc.
    
    properties (SetAccess=immutable)
        % Index - Location of the result relative to the entire suite.
        %
        %   The index property is the scalar numeric value that gives the location
        %   of the finalized result in relation to the entire suite being run.
        Index;
        
        % TestSuite - Specification of the Test element.
        %
        %   The TestSuite property is a matlab.unittest.TestSuite scalar that
        %   specifies the Test method executed to produce the TestResult.
        TestSuite;
        
        % TestResult - Scalar result of executing a portion of the suite.
        %
        %   The TestResult property is a matlab.unittest.TestResult scalar that
        %   contains the finalized result of running a portion of the suite.
        TestResult;
    end
    
    methods (Access={?matlab.unittest.TestRunner,?matlab.unittest.plugins.plugindata.PluginData})
        function p = FinalizedResultPluginData(name, index, suite, result)
            p@matlab.unittest.plugins.plugindata.PluginData(name);
            p.Index = index;
            p.TestSuite = suite;
            p.TestResult = result;
        end
    end
end

% LocalWords:  plugindata
