function p = makePacketLevels(j)
%MATLAB Code Generation Private Function

%   Generates p = repelem(1:j,2.^(1:j)) in a more direct fashion.

%   Copyright 2016 The MathWorks, Inc.
%#codegen
p = zeros(lengthPacketLevels(j),1);
p2 = 1;
idx = coder.internal.indexInt(0);
for k = 1:j
    p2 = p2*2;
    for i = 1:p2
        idx = idx + 1;
        p(idx) = k;
    end
end