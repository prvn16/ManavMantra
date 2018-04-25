classdef ProfilerCollector < matlab.unittest.internal.plugins.CodeCoverageCollector
    % ProfilerCollector - A code coverage collector leveraging the profiler.
    
    % Copyright 2013-2015 The MathWorks, Inc.
    
    properties (Dependent, SetAccess=private)
        Collecting
        Results
    end
    
    methods
        function start(~)
            profile('resume');
        end
        
        function stop(~)
            callstats('pause');
        end
        
        function delete(~)
            profile('off');
        end
        
        function clearResults(~)
            profile('clear');
        end
        
        function bool = get.Collecting(~)
            status = profile('status');
            bool = strcmp(status.ProfilerStatus, 'on');
        end
        
        function results = get.Results(~)
            results = profile('info');
        end
    end
end

