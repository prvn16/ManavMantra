function bins = getBinsForData(~, data)
% GETBINSFORDATA Get power-of-2 exponent of data

% Leave the data floating point (do not round)
% The bins are the exponent of log2.

%   Copyright 2012-2017 The MathWorks, Inc.

[~, bins] = log2(data);

