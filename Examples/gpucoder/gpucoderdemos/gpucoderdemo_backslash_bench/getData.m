function [A, b] = getData(n, clz)

%   Copyright 2017 The MathWorks, Inc.

    fprintf('Creating a matrix of size %d-by-%d.\n', n, n);
    A = rand(n, n, clz) + 100*eye(n, n, clz);
    b = rand(n, 1, clz);
end

