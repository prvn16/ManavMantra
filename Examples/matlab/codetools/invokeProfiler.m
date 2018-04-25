function invokeProfiler
%INVOKEPROFILER Invoke the profiler and display the summary page in the window

% Copyright 2016 The MathWorks, Inc.

    stats = profile('info');
    if isempty(stats.FunctionTable) && ~callstats('has_run')
        com.mathworks.mde.profiler.Profiler.invoke;
    else
        profview(0, stats);
    end
end