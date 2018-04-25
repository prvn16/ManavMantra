function rngState = randstream2RNGState(rs)
%randstream2RNGState  extract BigData RNG state from a randStream object
%
%   rngState = randstream2RNGState(rs) extracts the relevant bits of
%   RNG state from the specified RandStream object RS. The randstream is
%   left unmodified.
%
%   See also: tallrng

%   Copyright 2017 The MathWorks, Inc.
rngState = struct( ...
    'Type', RandStream.compatName(rs.Type), ...
    'Seed', rs.Seed, ...
    'StreamIndex', rs.StreamIndex, ...
    'Substream', rs.Substream );

end