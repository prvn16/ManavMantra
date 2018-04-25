function [packetlevels,F] = calcModwptPLandF(J,fulltree)
%MATLAB Code Generation Private Function

%   Calculates the second and third outputs of modwpt and modwptdetails.

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.inline('always');
coder.internal.prefer_const(J,fulltree);
ZERO = coder.internal.indexInt(0);
ONE = coder.internal.indexInt(1);
idx = ZERO;
if fulltree
    packetlevels = makePacketLevels(J);
    F = coder.nullcopy(zeros(size(packetlevels)));
    kstart = ONE;
else
    p2 = eml_lshift(ONE,J);
    packetlevels = coder.nullcopy(zeros(p2,1));
    packetlevels(:) = J;
    F = coder.nullcopy(zeros(size(packetlevels)));
    kstart = J;
end
for k = kstart:J
    p2 = eml_lshift(ONE,k);
    df = 1/double(p2*2);
    idx = idx + 1;
    F(idx) = df/2;
    for i = 2:p2
        idx = idx + 1;
        F(idx) = F(idx - 1) + df;
    end
end
