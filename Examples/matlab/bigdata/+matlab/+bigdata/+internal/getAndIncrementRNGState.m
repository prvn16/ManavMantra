function rngState = getAndIncrementRNGState(rs)
%getAndIncrementRNGState  get and update the BigData RNG state
%
%   rngState = getAndIncrementRNGState() returns the current RNG state
%   that should be used for the current tall array operation and
%   increments the state appropriately ready for the next operation.
%
%   rngState = getAndIncrementRNGState(rs) extracts a current RNG state 
%   from the specified RandStream object RS and advances it appropriately
%   ready for further use.
%
%   See also: tallrng

%   Copyright 2017 The MathWorks, Inc.

if nargin<1
    % Use the default stream
    rngState = tallrng();

    % We use a scheme where each partition runs on a separate stream and
    % each operation gets the next substream. We can therefore just
    % increment the substream by 1.
    newState = rngState;
    newState.Substream = newState.Substream + 1;

    % Store back ready for next time
    tallrng(newState);
    
else
    % Use a user-specified stream. If at the beginning of a substream then
    % we can just use it. If not, move to the next substream before
    % capturing the state. We can tell which by whether the state changes
    % when we set the substream to its current value.
    state = rs.State;
    rs.Substream = rs.Substream;
    if ~isequal(rs.State, state)
        % Not at beginning of substream, so move to next
        rs.Substream = rs.Substream + 1;
    end
    
    % Convert stream into state and move the user stream on
    rngState = matlab.bigdata.internal.randstream2RNGState(rs);
    rs.Substream = rs.Substream + 1;    
end
