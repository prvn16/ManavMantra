classdef (Hidden) StopOnFailuresPluginEnabler < matlab.unittest.plugins.TestRunnerPlugin

    % Copyright 2016 The MathWorks, Inc.
    methods
        function plugin = enableDebug(~)
            % add StopOnFailuresPlugin 
            import matlab.unittest.plugins.StopOnFailuresPlugin
            plugin = StopOnFailuresPlugin;
        end
        
        function tf = supportsParallel(~)
            tf = true;
        end
    end
end