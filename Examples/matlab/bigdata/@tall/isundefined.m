function tf = isundefined(tc)
%isundefined True for elements of a tall categorical array that are undefined.
%   TF = ISUNDEFINED(A)
%
%   See also CATEGORICAL/ISUNDEFINED

%   Copyright 2016 The MathWorks, Inc.

tc = tall.validateType(tc, upper(mfilename), {'categorical'}, 1);
tf = elementfun(@isundefined, tc);
tf = setKnownType(tf, 'logical');
end
