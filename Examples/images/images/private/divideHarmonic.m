function NN = divideHarmonic(base, limit, W)
% Controls how blockproc divides the work between workers in parallel mode.
% As seen in parallel_function.  We opt to limit the amount of data a
% single worker can take to 1% for the sake of the waitbar responsiveness
% in long running calls to blockproc.

%   Copyright 2011 The MathWorks, Inc.

N = limit - base;
% Iterate for the while loop
i = 0;

min_factor = 30;      % each worker will have at MOST this many invocations
max_factor = 100 / W; % each invocation will deliver at MOST 1% of the data

% Minimum chunk size such that there are no more than min_factor * W interates.
minChunk = max(ceil(N/(min_factor*W)), 1);
maxChunk = max(ceil(N/(max_factor*W)), 1);
curr = 0;
% Output size guess - heuristic - assert that N>0 & W>0
outputSize = ceil(min_factor*W);
% Allocate output array - ensure that it is the correct class
NN = zeros(1, outputSize, class(base));
while curr < N
    i = i+1;
    curr = curr + min(max(ceil((N - curr)/W), minChunk), maxChunk);
    NN(i) = curr;
end
% Force end point to be N as required - NOTE NN(i-1) is
% necessarily less than N by the loop condition so we are able to
% guarantee that NN is monotonically increasing.
NN(i) = N;
% And trim to expected output
NN = base + NN(1:i);

