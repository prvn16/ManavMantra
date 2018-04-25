classdef TestSuiteRunPluginData < matlab.unittest.plugins.plugindata.PluginData
    % TestSuiteRunPluginData - Data about running a portion of a suite.
    %
    %   The TestSuiteRunPluginData class holds information about a portion of a
    %   test suite being run.
    %
    %   TestSuiteRunPluginData properties:
    %       Name         - Name corresponding to the portion of the suite being executed.
    %       TestSuite    - Specification of the Test methods being executed.
    %       TestResult   - The results of executing the portion of the suite.
    %
    %   See also: matlab.unittest.plugins.TestRunnerPlugin, matlab.unittest.TestSuite, matlab.unittest.TestResult
    %
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    
    properties (Dependent, SetAccess=immutable)
        % TestSuite - Specification of the Test methods being executed.
        %
        %   The TestSuite property is a matlab.unittest.TestSuite that specifies
        %   the Test methods executed within the scope of the plugin method.
        TestSuite = matlab.unittest.TestSuite.empty;
    end
    
    properties (Dependent, SetAccess={?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.TestSuiteRunPluginData})
        % TestResult - The results of executing the portion of the suite.
        %
        %   The TestResult property is a matlab.unittest.TestResult array that
        %   contains the results of executing the Test methods specified by the
        %   TestSuite property.
        TestResult = matlab.unittest.TestResult.empty;
    end
    
    properties (Hidden, Dependent, SetAccess={?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.TestSuiteRunPluginData})
        % This property is undocumented and may change in a future release.
        
        % CurrentIndex - Index into TestSuite of the currently executing Test method.
        %
        %   The CurrentIndex property is a scalar integer that represents the index
        %   into TestSuite (and also TestResult) of the Test method currently being
        %   executed. CurrentIndex is initially 1 and increases as content in the
        %   scope of the plugin method is executed.
        CurrentIndex;
    end
    
    properties (Hidden, Dependent, SetAccess=private)
        RepeatIndex;
    end

    properties (SetAccess=immutable, GetAccess=private)
        TestRunData;
        
        % Index into the full TestSuite array of where this subsuite starts.
        StartIndex;
        
        % Index into the full TestSuite array of where this subsuite ends.
        EndIndex;
    end
    
    methods (Access = {?matlab.unittest.TestRunner, ?matlab.unittest.plugins.plugindata.TestSuiteRunPluginData})
        function p = TestSuiteRunPluginData(name, dataHolder, endIdx)
            p@matlab.unittest.plugins.plugindata.PluginData(name);
            p.TestRunData = dataHolder;
            p.StartIndex = dataHolder.CurrentIndex;
            p.EndIndex = endIdx;
        end
    end
    
    methods
        function index = get.CurrentIndex(pluginData)
            index = pluginData.TestRunData.CurrentIndex - pluginData.StartIndex + 1;
        end
        
        function set.CurrentIndex(pluginData, index)
            pluginData.TestRunData.CurrentIndex = pluginData.StartIndex + index - 1;
        end
        
        function index = get.RepeatIndex(pluginData)
            index = pluginData.TestRunData.RepeatIndex;
        end
             
        function result = get.TestResult(pluginData)
            result = pluginData.obtainIndexedRange(pluginData.TestRunData.TestResult);
        end
        
        function set.TestResult(pluginData, result)
            pluginData.TestRunData.TestResult(pluginData.StartIndex:pluginData.EndIndex) = result;
        end
        
        function suite = get.TestSuite(pluginData)
            suite = pluginData.obtainIndexedRange(pluginData.TestRunData.TestSuite);
        end
    end
    
    methods (Access=private)
        function array = obtainIndexedRange(pluginData, array)
            % For performance, only index if needed
            if pluginData.StartIndex ~= 1 || pluginData.EndIndex ~= numel(array)
                array = array(pluginData.StartIndex:pluginData.EndIndex);
            end
            array = reshape(array,1,[]);
        end
    end
    
    methods(Access={?matlab.unittest.internal.plugins.TestResultEnhancerMixin, ...
                    ?matlab.unittest.plugins.plugindata.TestSuiteRunPluginData})
        function appendDetails(pluginData, propertyName, value, index, distributeLoop)
            pluginData.TestRunData.appendDetails(propertyName, value, index, distributeLoop);
        end
    end
end

% LocalWords:  plugindata subsuite unittest plugins
