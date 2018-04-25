classdef TestContentOperatorList < handle
    
    % Copyright 2017 The MathWorks, Inc.
    
    properties (SetAccess=private)
        Plugins = matlab.unittest.plugins.TestRunnerPlugin.empty(1,0);
        HasQualifyingPlugin = false;
    end
    
    properties (Access=private)
        Iterator;
    end
    
    methods
        function list = TestContentOperatorList(baseOperator)
            import matlab.unittest.internal.TestContentOperatorIterator;
            
            methods = allPluginMethodNames;
            for idx = 1:numel(methods)
                list.Iterator.(methods{idx}) = TestContentOperatorIterator(baseOperator);
            end
        end
        
        function bool = hasPluginThatImplements(list, methodName)
            bool = list.Iterator.(methodName).HasPlugin;
        end
        
        function addPlugin(list, plugin)
            validateattributes(plugin, {'matlab.unittest.plugins.TestRunnerPlugin'}, {'scalar'}, '', 'plugin');
            
            list.Plugins(end+1) = plugin;
            
            list.HasQualifyingPlugin = list.HasQualifyingPlugin || ...
                isa(plugin, 'matlab.unittest.plugins.QualifyingPlugin');
            
            pluginMethodNames = findPluginMethodsOverriddenBy(plugin);
            for i = 1:numel(pluginMethodNames)
                list.Iterator.(pluginMethodNames{i}).addPlugin(plugin);
            end
        end
        
        function iter = getIteratorFor(list, methodName)
            iter = list.Iterator.(methodName);
            iter.reset;
        end
    end
end

function overriddenMethods = findPluginMethodsOverriddenBy(plugin)
pluginClass = metaclass(plugin);
methodList = pluginClass.MethodList;
methodNames = {methodList.Name};
[~, idx] = find(allPluginMethodNames == methodNames);
mask = [methodList(idx).DefiningClass] ~= ?matlab.unittest.plugins.TestRunnerPlugin;
overriddenMethods = methodNames(idx(mask));
end

function names = allPluginMethodNames
names = [ ...
    "runTestSuite"; ...
    "runTestClass"; ...
    "runTest"; ...
    "runTestMethod"; ...
    "createSharedTestFixture"; ...
    "createTestClassInstance"; ...
    "createTestMethodInstance"; ...
    "setupSharedTestFixture"; ...
    "teardownSharedTestFixture"; ...
    "setupTestClass"; ...
    "teardownTestClass"; ...
    "createTestRepeatLoopInstance"; ...
    "teardownTestRepeatLoop"; ...
    "setupTestMethod"; ...
    "teardownTestMethod"; ...
    "evaluateMethod"; ...
    "reportFinalizedResult"];
end
