function stdc = wnoisest(c,varargin)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(1,3)
coder.internal.prefer_const(varargin);
coder.internal.assert(iscell(c) || isnumeric(c), ...
    'Wavelet:FunctionArgVal:Invalid_ArgFirst');
if nargin == 1
    if isnumeric(c)
        stdc = median(abs(c),2).';
    else
        nblev = length(c);
        stdc = zeros(1,nblev);
        for k = 1:nblev
            stdc(k) = median(abs(c{k}));
        end
    end
    stdc = stdc/0.6745;  
elseif nargin == 2
    ccell = detcoef(c,varargin{1},'cells');
    stdc = wnoisest(ccell);
else % if nargin == 3
    [first,last] = calcDetCoefFirstLast(varargin{1});
    nblev = length(varargin{2});
    stdc = coder.nullcopy(zeros(1,nblev,'like',real(c)));
    for j = 1:nblev
        k = varargin{2}(j);
        stdc(j) = median(abs(c(first(k):last(k))))/0.6745;
    end
end
    