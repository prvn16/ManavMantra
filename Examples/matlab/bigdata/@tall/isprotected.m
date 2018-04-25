function tf = isprotected(a)
%ISPROTECTED True if the categories in a categorical array are protected.
%   TF = ISPROTECTED(A)
%
%   See also CATEGORICAL/ISPROTECTED, TALL.

%   Copyright 2017 The MathWorks, Inc.

a = tall.validateType(a, mfilename, {'categorical'}, 1);

tf = a.Adaptor.IsProtected;

end
