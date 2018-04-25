function maxTimeMapper(data, ~, intermKVStore)
% Copyright 2014 The MathWorks, Inc.

maxElaspedTime = max(data{:,:});
add(intermKVStore, 'MaxElaspedTime',maxElaspedTime);
end