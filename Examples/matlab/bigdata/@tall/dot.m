function tc = dot(ta,tb,dim)
%DOT Vector dot product for tall arrays.
%   C = DOT(A,B)
%   C = DOT(A,B,DIM)
%
%   Limitations:
%   A and B must have the same size, even if A and B are vectors.
%
%   See also DOT.

%   Copyright 2016-2017 The MathWorks, Inc.

narginchk(2,3);
[ta, tb] = validateSameTallSize(ta, tb);
[ta, tb] = lazyValidate(ta, tb, {@(x,y)isequal(size(x),size(y)), ...
    'MATLAB:dot:InputSizeMismatch'});
ta = tall.validateType(ta, mfilename, {'double','single','char','logical'}, 1);
tb = tall.validateType(tb, mfilename, {'double','single','char','logical'}, 2);
if nargin == 2
    tc = sum(conj(ta).*tb);
else
    tall.checkNotTall(upper(mfilename), 2, dim);
    if ~isnumeric(dim)
        error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
    end
    tc = sum(conj(ta).*tb,dim);
end
end

