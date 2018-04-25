function n = nnz(tv)
%NNZ Number of nonzero matrix elements.
%   NZ = NNZ(TV) is the number of non-zero elements in TV.

% Copyright 2015-2016 The MathWorks, Inc.

tv = tall.validateType(tv, mfilename, {'~table', '~timetable'}, 1);
n = aggregatefun(@nnz, @sum, tv);
n.Adaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();
end
