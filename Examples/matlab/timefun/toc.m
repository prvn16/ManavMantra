%TOC Read the stopwatch timer.
%   TIC and TOC functions work together to measure elapsed time.
%   TOC, by itself, displays the elapsed time, in seconds, since
%   the most recent execution of the TIC command.
%
%   T = TOC; saves the elapsed time in T as a double scalar.
%
%   TOC(TSTART) measures the time elapsed since the TIC command that
%   generated TSTART.
%
%   Example: Measure the minimum and average time to compute a sum
%            of Bessel functions.
%
%     REPS = 1000; minTime = Inf; nsum = 10;
%     tic;
%     for i=1:REPS
%       tstart = tic;
%       sum = 0; for j=1:nsum, sum = sum + besselj(j,REPS); end
%       telapsed = toc(tstart);
%       minTime = min(telapsed,minTime);
%     end
%     averageTime = toc/REPS;
%
%   See also TIC, CPUTIME.

%   Copyright 1984-2008 The MathWorks, Inc.
%   Built-in function.
