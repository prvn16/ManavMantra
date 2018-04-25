function paSubscript = verifyNumericSubscript(paSubscript, dim, maxValue)
% Verify that a numeric subscript of the given dimension dim is value.

% Copyright 2017 The MathWorks, Inc.

paSubscript = elementfun(@iVerifyNumericSubscript, paSubscript, dim, maxValue);

end

function idx = iVerifyNumericSubscript(idx, dim, maxValue)
% Implementation.

% In a number of cases, we can replicate the error of core MATLAB by
% indexing an empty.
if ~isreal(idx) || iscell(idx) || any(idx <= 0 | mod(idx, 1) ~= 0)
    sample = [];
    sample(idx);
end

% We only need to explicitly test for exceeding the maximum size.
if any(idx > maxValue)
    msg = message('MATLAB:matrix:indexExceedsDimsPositionSize', dim, maxValue);
    error(message('MATLAB:badsubscript', getString(msg)));
end

% Just in-case idx is any other numeric type.
idx = double(idx);
end
