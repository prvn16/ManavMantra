function [] = genGpuCode(A, b)

%   Copyright 2017 The MathWorks, Inc.

    cfg = coder.gpuConfig('mex');
    evalc('codegen -config cfg -args {A,b} backslash');
end
