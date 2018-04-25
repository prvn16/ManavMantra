function C = idivide(A, B, opt)
%IDIVIDE Integer division with rounding option.

% Copyright 2016-2017 The MathWorks, Inc.

if nargin < 3
    opt = 'fix';
else
    tall.checkNotTall(upper(mfilename), 2, opt);
    validateattributes(opt, {'char','string'}, {'row'}, mfilename, 'OPT', 3);
end

% Rules of IDIVIDE mean that only integer types and double are permitted. (Other
% types are not explicitly excluded by MATLAB's IDIVIDE, but at least one
% argument must be integer, and integers can be combined only with other
% integers of the same class, or scalar doubles).
[A, B] = tall.validateType(A, B, upper(mfilename), {'integer', 'double'}, 1:2);

C = elementfun(@(a, b) idivide(a, b, opt), A, B);
Cclz = calculateArithmeticOutputType(tall.getClass(A), tall.getClass(B));
C = setKnownType(C, Cclz);
end
