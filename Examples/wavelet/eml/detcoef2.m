function varargout = detcoef2(o,c,s,n)
%MATLAB Code Generation Library Function

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

coder.internal.prefer_const(o,s,n);
coder.internal.assert(n >= 1 && size(s,1) >= 2 && ...
    n <= size(s,1) - 2 && n == floor(n), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
coder.internal.assert(ismatrix(s) && ...
    coder.internal.isConst(size(s,2)), ...
    'Wavelet:codegeneration:DetCoef2NDimsNotConst'); 
[first,add,sz] = calcLimitsAndSize(s,n);
opt = parseOption(o);
switch opt
    case {'h','v','d'}
        if opt == 'h'
            offset = first - 1;
        elseif opt == 'v'
            offset = first + add - 1;
        else % if opt == 'd'
            offset = first + 2*add - 1;
        end
        % varargout{1} = reshape(c(first:last),sz);
        varargout{1} = coder.nullcopy(zeros(sz,'like',c));
        for j = 1:add
            varargout{1}(j) = c(offset + j);
        end
    case {'c'}
        last = first + 3*add - 1;
        varargout{1} = c(first:last);
    case {'a'}
        offset1 = first - 1;
        offset2 = offset1 + add;
        offset3 = offset2 + add;
        % varargout{1} = reshape(c(first:last),sz);
        % varargout{2} = reshape(c((first:last) + add),sz);
        % varargout{3} = reshape(c((first:last) + 2*add),sz);
        varargout{1} = coder.nullcopy(zeros(sz,'like',c));
        varargout{2} = coder.nullcopy(zeros(sz,'like',c));
        varargout{3} = coder.nullcopy(zeros(sz,'like',c));
        for j = 1:add
            varargout{1}(j) = c(offset1 + j);
        end
        for j = 1:add
            varargout{2}(j) = c(offset2 + j);
        end
        for j = 1:add
            varargout{3}(j) = c(offset3 + j);
        end
end

%--------------------------------------------------------------------------

function [first,add,sz] = calcLimitsAndSize(s,n)
coder.inline('always');
coder.internal.prefer_const(s,n);
k = coder.internal.indexMinus(size(s,1),n);
first = coder.internal.indexInt(0);
for j = 2:k-1
    first = first + coder.internal.indexTimes(s(j,1),s(j,2));
end
first = 3*first;
first = first + coder.internal.indexTimes(s(1,1),s(1,2));
add = coder.internal.indexTimes(s(k,1),s(k,2));
if size(s,2) < 3
    first = first + 1;
else
    first = 3*first + 1;
    add   = 3*add;
end
sz = s(k,:);

%--------------------------------------------------------------------------

function opt = parseOption(o)
% Validate the option input and return opt = lower(o(1)).
coder.inline('always');
coder.internal.prefer_const(o);
ol = lower(o);
coder.internal.assert(ischar(o) && ( ...
    isequal(ol,'h') || isequal(ol,'v') || isequal(ol,'d') || ...
    isequal(ol,'a') || isequal(ol,'c') || ...
    strcmp(ol,'all') || strcmp(ol,'compact')), ...
    'Wavelet:FunctionArgVal:Invalid_ArgVal');
opt = ol(1);

%--------------------------------------------------------------------------
