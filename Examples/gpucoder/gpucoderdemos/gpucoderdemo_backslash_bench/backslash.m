function [x] = backslash(A,b)
%#codegen

%   Copyright 2017 The MathWorks, Inc.

    coder.gpu.kernelfun();
    x = A\b;
end
