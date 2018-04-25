classdef VerboseProgressPlugin < matlab.unittest.plugins.testrunprogress.DetailedProgressPlugin
    % VerboseProgressPlugin - Plugin which outputs verbose test run progress.
    % 
    %   The VerboseProgressPlugin can be added to the TestRunner to show
    %   progress of the test run to the Command Window when running test
    %   suites.
    
    % Copyright 2013-2016 The MathWorks, Inc.
    
    methods (Access=?matlab.unittest.plugins.TestRunProgressPlugin)
        function plugin = VerboseProgressPlugin(varargin)
            plugin = plugin@matlab.unittest.plugins.testrunprogress.DetailedProgressPlugin(varargin{:});
        end
    end
    
    methods (Access=protected)
        function evaluateMethod(plugin, pluginData)
            name = pluginData.Name;
            method = pluginData.Method;
            
            if metaclass(method) <= ?matlab.unittest.meta.method
                if method.Test
                    str = plugin.Catalog.getString('EvaluatingWithType','Test',name);
                elseif method.TestMethodSetup
                    str = plugin.Catalog.getString('EvaluatingWithType','TestMethodSetup',name);
                elseif method.TestMethodTeardown
                    str = plugin.Catalog.getString('EvaluatingWithType','TestMethodTeardown',name);
                elseif method.TestClassSetup
                    str = plugin.Catalog.getString('EvaluatingWithType','TestClassSetup',name);
                elseif method.TestClassTeardown
                    str = plugin.Catalog.getString('EvaluatingWithType','TestClassTeardown',name);
                end
            else
                if pluginData.AddedTeardown
                    str = plugin.Catalog.getString('EvaluatingAddTeardown',name);
                else
                    str = plugin.Catalog.getString('Evaluating',name);
                end
            end
            
            plugin.Printer.printIndentedLine(str);
            
            evaluateMethod@matlab.unittest.plugins.testrunprogress.DetailedProgressPlugin(plugin, pluginData);
        end
    end
end


% LocalWords:  testrunprogress func
