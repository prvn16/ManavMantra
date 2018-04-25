classdef DetailedProgressPlugin < matlab.unittest.plugins.TestRunProgressPlugin
    % DetailedProgressPlugin - Plugin which outputs detailed test run progress.
    %
    %   The DetailedProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Hidden, Access=protected)
        RunTestSuitePluginData;
    end
    
    properties (Dependent, Access=private)
        CurrentDuration;
    end
    
    methods (Access=?matlab.unittest.plugins.TestRunProgressPlugin)
        function plugin = DetailedProgressPlugin(varargin)
            plugin = plugin@matlab.unittest.plugins.TestRunProgressPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            plugin.RunTestSuitePluginData = pluginData;
            runTestSuite@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
        end
        
        function setupSharedTestFixture(plugin, pluginData)
            plugin.Printer.printLine(plugin.Catalog.getString('SettingUp', pluginData.Name));
            
            t0 = plugin.CurrentDuration;
            setupSharedTestFixture@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);
            t1 = plugin.CurrentDuration;
            
            description = plugin.Catalog.getString('DoneSettingUpWithDuration', pluginData.Name, num2str(t1-t0));
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.Printer.printLine(description);
            plugin.Printer.printLine(plugin.ContentDelimiter);
            plugin.Printer.printLine('');
        end
        
        function teardownSharedTestFixture(plugin, pluginData)
            plugin.Printer.printLine(plugin.Catalog.getString('TearingDown', pluginData.Name));
            
            t0 = plugin.CurrentDuration;
            teardownSharedTestFixture@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            t1 = plugin.CurrentDuration;
            
            description = plugin.Catalog.getString('DoneTearingDownWithDuration', pluginData.Name, num2str(t1-t0));
            if ~isempty(pluginData.Description)
                description = sprintf('%s: %s', description, pluginData.Description);
            end
            plugin.Printer.printLine(description);
            plugin.Printer.printLine(plugin.ContentDelimiter);
            plugin.Printer.printLine('');
        end
        
        function runTestClass(plugin, pluginData)
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('Running', pluginData.Name), ' ');
            
            t0 = sum([pluginData.TestResult.Duration]);
            runTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            t1 = sum([pluginData.TestResult.Duration]);
            
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('DoneWithDuration', pluginData.Name, num2str(t1-t0)), ' ');
            plugin.Printer.printLine(plugin.ContentDelimiter);
            plugin.Printer.printLine('');
        end
        
        function setupTestClass(plugin, pluginData)
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('SettingUp', pluginData.Name), '  ');
            
            t0 = plugin.CurrentDuration;
            setupTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            t1 = plugin.CurrentDuration;
            
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('DoneSettingUpWithDuration', pluginData.Name, num2str(t1-t0)), '  ');
        end
        
        function teardownTestClass(plugin, pluginData)
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('TearingDown', pluginData.Name), '  ');
            
            t0 = plugin.CurrentDuration;
            teardownTestClass@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            t1 = plugin.CurrentDuration;
            
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('DoneTearingDownWithDuration', pluginData.Name, num2str(t1-t0)), '  ');
        end
        
        function runTest(plugin, pluginData)
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('Running', pluginData.Name), '   ');
            
            t0 = pluginData.TestResult.Duration;
            runTest@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            t1 = pluginData.TestResult.Duration;
            
            plugin.Printer.printIndentedLine(plugin.Catalog.getString('DoneWithDuration', pluginData.Name, num2str(t1-t0)), '   ');
        end
    end
    
    methods
        function t = get.CurrentDuration(plugin)
            t = plugin.RunTestSuitePluginData.TestResult(plugin.RunTestSuitePluginData.CurrentIndex).Duration;
        end
    end
end