function [yout] = gpuSimpleTest(xin)

%   Copyright 2017 The MathWorks, Inc.

coder.allowpcode('plain');
yout = coder.nullcopy(zeros(size(xin)));
coder.gpu.kernelfun();

for idx=1:100
    yout(idx) = xin(idx) * 2;
end

yout = yout + 5;

end
