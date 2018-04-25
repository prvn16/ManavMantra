function t = tictocCallTime
% TICTOCCALLTIME Measure the time required to call tic/toc.
%   T = TICTOCCALLTIME returns the estimated time (in seconds) required to 
%   call tic and toc.
%
%   Copyright 2013 The MathWorks, Inc.

persistent ttct
if ~isempty(ttct)
    t = ttct;
    return
end

% Warm up tic/toc.
tic(); elapsed = toc(); %#ok<NASGU>
tic(); elapsed = toc(); %#ok<NASGU>
tic(); elapsed = toc(); %#ok<NASGU>

num_repeats = 11;
times = zeros(1, num_repeats);

for k = 1:num_repeats
   times(k) = tictocTimeExperiment();
end

t = min(times);
ttct = t;

function t = tictocTimeExperiment
% Call tic/toc 100 times and return the average time required.

elapsed = 0;
% Call tic/toc 100 times.
tic(); elapsed = elapsed +  toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();
tic(); elapsed = elapsed + toc();

t = elapsed / 100;

