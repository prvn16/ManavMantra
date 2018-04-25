classdef(Hidden) CodeCoverageCollectionPlugin < matlab.unittest.plugins.TestRunnerPlugin
    % This class is undocumented and may change in a future release.
    
    % CodeCoverageCollectionPlugin - A plugin for collecting code coverage.
    
    % Copyright 2013-2017 The MathWorks, Inc.
    
    properties (Hidden, SetAccess=private, GetAccess=protected)
        Collector
    end
    
    methods (Access=protected)
        function plugin = CodeCoverageCollectionPlugin(collector)
            plugin.Collector = collector;
        end
        
        function runTestSuite(plugin, pluginData)
            plugin.Collector.clearResults;
            runTestSuite@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
        end
        
        function evaluateMethod(plugin, pluginData)
            plugin.Collector.start;
            stopCollector = onCleanup(@()plugin.Collector.stop);
            evaluateMethod@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
        end
    end
    
    methods
        function set.Collector(plugin, collector)
            validateattributes(collector, {'matlab.unittest.internal.plugins.CodeCoverageCollector'}, ...
                {'scalar'}, '', 'Collector');
            plugin.Collector = collector;
        end
    end
end
