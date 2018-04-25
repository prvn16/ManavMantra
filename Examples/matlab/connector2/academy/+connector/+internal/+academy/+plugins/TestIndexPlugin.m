classdef TestIndexPlugin < matlab.unittest.plugins.TestRunnerPlugin
    
    properties
        SuitePluginData
    end
        
    properties(Dependent)
        CurrentIndex
    end
    
    methods(Access=protected)        
    
        function runTestClass(plugin, pluginData)
            plugin.SuitePluginData = pluginData; 
            runTestClass@matlab.unittest.plugins.TestRunnerPlugin(plugin, pluginData);         
        end
        
    end
    
    methods
        function idx = get.CurrentIndex(plugin)
            idx = plugin.SuitePluginData.CurrentIndex;
        end
    end
    
end
