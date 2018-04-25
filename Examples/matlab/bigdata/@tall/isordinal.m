function tf = isordinal(a)
%ISORDINAL True if the categories in a categorical array have a mathematical ordering.
%   TF = ISORDINAL(A)
%
%   See also CATEGORICAL/ISORDINAL, TALL.

%   Copyright 2017 The MathWorks, Inc.

a = tall.validateType(a, mfilename, {'categorical'}, 1);

tf = a.Adaptor.IsOrdinal;

end
