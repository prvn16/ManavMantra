function Z = rdivide(X, Y)
%./ Right array divide.

% Copyright 2016 The MathWorks, Inc.

narginchk(2,2);
[X, Y] = tall.validateType(X, Y, mfilename, ...
                           {'numeric', 'logical', 'duration', 'char'}, 1:2);

% divisionOutputAdaptor throws up-front errors for invalid combinations
outAdaptor = divisionOutputAdaptor(X, Y);
Z = elementfun(@rdivide, X, Y);
Z.Adaptor = copySizeInformation(outAdaptor, Z.Adaptor);
end
