function exponents = computeHistogramBin(values)
%% COMPUTEHISTOGRAMBIN function computes the log2 histogram bin 
% for a given value

%   Copyright 2017 The MathWorks, Inc.

    [sf, exponents] = log2(abs(values));
    sfIndices = find(sf <= 1 & sf > 0);
    exponents(sfIndices) = exponents(sfIndices) - 1;
end