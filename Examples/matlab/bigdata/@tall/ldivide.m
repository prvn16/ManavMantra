function Z = ldivide(X, Y)
%.\ Left array divide.

% Copyright 2016 The MathWorks, Inc.

narginchk(2,2);
[X, Y] = tall.validateType(X, Y, mfilename, ...
    {'numeric', 'logical', 'duration', 'char'}, 1:2);
% divisionOutputAdaptor throws up-front errors for invalid combinations
outAdaptor = divisionOutputAdaptor(Y, X);
Z = elementfun(@ldivide, X, Y);
Z.Adaptor = copySizeInformation(outAdaptor, Z.Adaptor);
end
