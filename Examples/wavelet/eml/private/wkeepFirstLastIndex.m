function [first,last] = wkeepFirstLastIndex(nx,len,opt,side)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(3,4);
coder.internal.assert(len == floor(len), ...
    'Wavelet:FunctionArgVal:Invalid_LengthVal','Arg2');
ONE = coder.internal.indexInt(1);
first = ONE;
last = nx;
if len >= 0 && len < nx
    m = coder.internal.indexInt(len);
    if ischar(opt)
        switch lower(opt)
            case {'l','u'}
                first = ONE;
                last = m;
            case {'r','d'}
                first = nx - m + 1;
                last = nx;
            otherwise % case 'c'
                if nargin < 4
                    side = '0';
                end
                nxmm = nx - m;
                d = eml_rshift(nxmm,ONE); % d = (nx - m)/2;
                odd = eml_bitand(nxmm,ONE);
                switch side
                    case {'d','r','1',1}
                        first = 1 + d;
                        if odd
                            first = first + 1;
                        end
                        last = nx - d;
                    otherwise % case {'u','l','0',0}
                        first = 1 + d;
                        last = nx - d;
                        if odd
                            last = last - 1;
                        end
                end
        end
    elseif isnumeric(opt) && ~isempty(opt)
        % The opt input is the first index value.
        first = coder.internal.indexInt(opt(1));
        last = first + m - 1;
        coder.internal.assert(first == opt && ...
            first >= 1 && last <= nx, ...
            'Wavelet:FunctionArgVal:Invalid_ArgVal');
    end
end