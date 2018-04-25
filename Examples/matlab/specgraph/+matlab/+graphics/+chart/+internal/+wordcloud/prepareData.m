function [args, invalidData] = prepareData(args)
% This internal helper function may be removed in a future release.

%prepareData prepare word cloud data
%   [args, invalidData] = prepareData(args) takes structure args
%   with data inputs and validates the inputs are compatible (returning
%   true in invalidData if there was a problem) and returns the sorted data
%   trimmed of zero and inf size values.
%   Data inputs are assumed to be vertically oriented.

% Copyright 2016-2017 The MathWorks, Inc.

num_words = length(args.words);
num_weights = length(args.weights);
invalidData = num_words ~= num_weights;
if ~invalidData
    args = sortAndTrimData(args);
end
end

function args = sortAndTrimData(args)

% filter for finite and positive weights
bad = ~isfinite(args.weights) | (args.weights <= 0);
args.weights(bad) = [];
args.words(bad) = [];
args.ignored = bad;

% sort everything descending order
[args.weights,inds] = sort(args.weights,'descend');
args.inds = inds;
args.words = args.words(inds);
end
