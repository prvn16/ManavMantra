function out = createGathered(hostData, varargin)
%createGathered Private utility to create an already-gathered tall

% Copyright 2016 The MathWorks, Inc.

assert(~istall(hostData));
% Build a precise adaptor
adaptor = matlab.bigdata.internal.adaptors.getAdaptor(hostData);
adaptor = setKnownSize(adaptor, size(hostData));

out = tall(matlab.bigdata.internal.lazyeval.LazyPartitionedArray.createFromConstant(...
    hostData, varargin{:}), adaptor);
end
