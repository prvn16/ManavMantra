function C = bsxfun(fun, A, B)
%BSXFUN Binary Singleton Expansion Function
%   C = BSXFUN(@FUN,A,B)
%
%   See also: BSXFUN, TALL.

% Copyright 2016 The MathWorks, Inc.

if ~isa(fun, 'function_handle')
    error(message('MATLAB:bsxfun:nonFunctionHandle'));
end

% Note that BSXFUN requires numeric output, so we don't need any additional
% checks.
C = slicefun(@(a,b) bsxfun(fun, a, b), A, B);
end
