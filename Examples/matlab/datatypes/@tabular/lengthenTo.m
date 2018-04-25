function t = lengthenTo(t,newLen)
% LENGTHEN Lengthen variables in a table that are too short.

%   Copyright 2012-2016 The MathWorks, Inc.

for j = 1:t.varDim.length
    if size(t.data{j},1) < newLen
        t.data{j} = t.lengthenVar(t.data{j}, newLen);
    end
end