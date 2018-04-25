function y = qmf(x,p)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

% Check arguments.
narginchk(1,2);
ONE = coder.internal.indexInt(1);
TWO = coder.internal.indexInt(2);
if nargin == 1
    first = TWO;
else
    ip = coder.internal.indexInt(p);
    coder.internal.assert(isnumeric(p) && isscalar(p) && p >= 0 && ...
        isequal(p,ip), ...
        'Wavelet:FunctionArgVal:Invalid_ArgVal');
    if eml_bitand(ip,ONE) == 0
        first = TWO;
    else
        first = ONE;
    end
end
% Compute quadrature mirror filter.
n = coder.internal.indexInt(numel(x));
y = coder.nullcopy(x);
for k = 1:n
    y(k) = x(n - k + 1);
end
for k = first:TWO:n
    y(k) = -y(k);
end
