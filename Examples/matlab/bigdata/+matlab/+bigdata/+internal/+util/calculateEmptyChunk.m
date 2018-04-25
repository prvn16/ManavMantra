%calculateEmptyChunk
% Calculate the empty equivalent to the provided chunk.
%

%   Copyright 2015 The MathWorks, Inc.

function emptyChunk = calculateEmptyChunk(chunk)

emptyChunk = chunk([], :);
if ~ismatrix(chunk)
    sz = size(chunk);
    emptyChunk = reshape(emptyChunk, [0, sz(2:end)]);
end
