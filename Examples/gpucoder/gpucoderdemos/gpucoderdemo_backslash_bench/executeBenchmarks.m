function [timeCPU, timeGPU] = executeBenchmarks(clz, sizes, reps)

%   Copyright 2017 The MathWorks, Inc.

    fprintf(['Starting benchmarks with %d different %s-precision ' ...
         'matrices of sizes\nranging from %d-by-%d to %d-by-%d.\n'], ...
            length(sizes), clz, sizes(1), sizes(1), sizes(end), ...
            sizes(end));
    timeGPU = zeros(size(sizes));
    timeCPU = zeros(size(sizes));   
    for i = 1:length(sizes)
        n = sizes(i);
        fprintf('Size : %d\n', n);
        [A, b] = getData(n, clz);
        genGpuCode(A, b);
        timeCPU(i) = benchFcnMat(A, b, reps);
        fprintf('Time on CPU: %f sec\n', timeCPU(i));
        timeGPU(i) = benchFcnGpu(A, b, reps);
        fprintf('Time on GPU: %f sec\n', timeGPU(i));
        fprintf('\n');
    end
end
