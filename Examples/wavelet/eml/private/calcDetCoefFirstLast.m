function [first,last] = calcDetCoefFirstLast(longs)
%MATLAB Code Generation Private Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.inline('always');
coder.internal.prefer_const(longs);
nlongs = coder.internal.indexInt(length(longs));
maxlevel = nlongs - 2;
first = zeros(maxlevel,1,coder.internal.indexIntClass);
last = zeros(maxlevel,1,coder.internal.indexIntClass);
% first = cumsum(longs) + 1;
% first = first(end-2:-1:1);
% longs = longs(end-1:-1:2);
% last  = first+longs-1;
first(maxlevel) = coder.internal.indexInt(longs(1)) + 1;
last(maxlevel) = first(maxlevel) +  ...
    coder.internal.indexInt(longs(2)) - 1;
for j = maxlevel-1:-1:1
    first(j) = first(j + 1) +  ...
        coder.internal.indexInt(longs(maxlevel - j + 1));
    last(j) = first(j) + ...
        coder.internal.indexInt(longs(maxlevel - j + 2)) - 1;
end
