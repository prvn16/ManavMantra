function [lo1,hi1,lo2,hi2] = wfiltersConst(wname,type)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.inline('always');
coder.internal.prefer_const(wname);
coder.internal.assert(coder.internal.isConst(wname), ...
    'Wavelet:codegeneration:WnameMustBeConstant');
coder.extrinsic('wfilters');
if nargin == 2
    coder.internal.prefer_const(type);
    coder.internal.assert(coder.internal.isConst(type), ...
        'Wavelet:codegeneration:WFiltersTypeNonConstant');
    [lo1,hi1] = coder.const(@wfilters,wname,type);
else
    [lo1,hi1,lo2,hi2] = coder.const(@wfilters,wname);
end