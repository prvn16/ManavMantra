classdef TerseProgressPlugin < matlab.unittest.plugins.TestRunProgressPlugin
    % TerseProgressPlugin - Plugin which outputs minimal test run progress.
    % 
    %   The TerseProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    properties (Hidden, Constant)
        RowLength = 50;
    end
    
    properties (Access=private)
        MethodCount = 0;
        NeedNewline = false;
    end
    
    methods (Access=?matlab.unittest.plugins.TestRunProgressPlugin)
        function plugin = TerseProgressPlugin(varargin)
            plugin = plugin@matlab.unittest.plugins.TestRunProgressPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function runTestSuite(plugin, pluginData)
            plugin.MethodCount = 0;
            plugin.NeedNewline = false;
            
            runTestSuite@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            
            plugin.Printer.printEmptyLine;
        end
        
        function runTest(plugin, pluginData)
            runTest@matlab.unittest.plugins.TestRunProgressPlugin(plugin, pluginData);
            
            if plugin.NeedNewline
                plugin.Printer.printEmptyLine;
                plugin.NeedNewline = false;
            end
            
            plugin.MethodCount = mod(plugin.MethodCount + 1, plugin.RowLength);
            plugin.NeedNewline = plugin.MethodCount == 0;
            
            plugin.Printer.print('.');
        end
    end
end

