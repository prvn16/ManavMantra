%TIC Start a stopwatch timer.
%   TIC and TOC functions work together to measure elapsed time.
%   TIC, by itself, saves the current time that TOC uses later to
%   measure the time elapsed between the two.
%
%   TSTART = TIC saves the time to an output argument, TSTART. The
%   numeric value of TSTART is only useful as an input argument
%   for a subsequent call to TOC.
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
%   See also TOC, CPUTIME.

%   Copyright 1984-2008 The MathWorks, Inc.
%   Built-in function.
