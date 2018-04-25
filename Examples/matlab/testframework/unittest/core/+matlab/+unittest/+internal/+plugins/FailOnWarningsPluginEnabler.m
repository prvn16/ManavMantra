classdef (Hidden) FailOnWarningsPluginEnabler < matlab.unittest.plugins.TestRunnerPlugin
    
    % Copyright 2016 The MathWorks, Inc.
    methods
        function plugin = enableStrict(~)
            % add FailOnWarningsPlugin
            import matlab.unittest.plugins.FailOnWarningsPlugin
            plugin = FailOnWarningsPlugin;
        end
        
        function tf = supportsParallel(~)
            tf = true;
        end
    end
end