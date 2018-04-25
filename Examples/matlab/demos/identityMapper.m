function identityMapper(data, info, intermKVStore)
% Mapper function for the MapReduce TSQR example.
%
% This mapper function simply copies the data and add them to the
% intermKVStore as intermediate values.

% Copyright 2014 The MathWorks, Inc.

x = data.Value{:,:};
add(intermKVStore,'Identity', x);