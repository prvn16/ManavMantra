function n = lengthPacketLevels(j)
%MATLAB Code Generation Private Function

%   n = sum(2.^(1:j))

%   Copyright 2016 The MathWorks, Inc.
%#codegen
coder.internal.prefer_const(j);
coder.extrinsic('cumsum');
table = coder.const(genTable);
maxj = coder.const(coder.internal.indexInt(length(table)));
if j < 1
    n = coder.internal.indexInt(1);
elseif j > maxj
    n = table(maxj);
else
    n = table(j);
end

%--------------------------------------------------------------------------

function table = genTable
% table = cumsum(2.^(1:nbits)), where nbits is the number of bits in the
% indexIntClass minus 2.
N = coder.internal.int_nbits(coder.internal.indexIntClass) - 2;
table = zeros(1,N,coder.internal.indexIntClass);
table(1) = 2;
p2 = coder.internal.indexInt(2);
for k = 2:N
    p2 = p2*2;
    table(k) = table(k - 1) + p2;
end

%--------------------------------------------------------------------------
