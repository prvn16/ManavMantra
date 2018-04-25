function tf = isNonTallScalarString(arg)
% True is the input is an in-memory scalar string or char row vector. Note
% that both '' and "" are also accepted.

% Copyright 2017 The MathWorks, Inc.

tf = ~istall(arg) ...
    && ((ischar(arg) && (isequal(arg,'') || isrow(arg))) ...
    || (isstring(arg) && isscalar(arg)));
