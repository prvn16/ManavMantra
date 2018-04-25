function rs = rngState2Randstream(rngState)
%rngState2Randstream  create a RandStream from some BigData RNG state
%
%   rs = rngState2Randstream(rngState) creates a RandStream object RS using
%   the information from BigData RNG state RNGSTATE.
%
%   See also: tallrng

%   Copyright 2017 The MathWorks, Inc.

rs = RandStream.create(rngState.Type, ...
    'Seed', rngState.Seed, ...
    'NumStreams', rngState.StreamIndex, ...
    'StreamIndices',rngState.StreamIndex);
rs.Substream = rngState.Substream;

end