function time = benchFcnMat(A, b, reps)

%   Copyright 2017 The MathWorks, Inc.

    time = inf;
    % We solve the linear system a few times and take the best run
    for itr = 1:reps
        tic;
        matX = backslash(A, b);
        tcurr = toc;
        time = min(tcurr, time);
    end
end
