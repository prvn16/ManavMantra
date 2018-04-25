function time = benchFcnGpu(A, b, reps)

%   Copyright 2017 The MathWorks, Inc.

    time = inf;
    gpuX = backslash_mex(A, b);
    for itr = 1:reps
        tic;
        gpuX = backslash_mex(A, b);
        tcurr = toc;
        time = min(tcurr, time);
    end
end
