function oldState = getSetGlobalRandState(newState)
%GETSETGLOBALRANDSTATE  Storage and retrieval of the global RNG state
%
%   state = matlab.bigdata.internal.getSetGlobalRandState() returns the
%   current global random number generator state used for BigData
%   calculations.
%
%   matlab.bigdata.internal.getSetGlobalRandState(state) sets the global
%   state used for BigData calculations to be a different stream object.
%
%   old = matlab.bigdata.internal.getSetGlobalRandState(new) changes
%   the global state and also returns the previous value.
%
%   Note that the state returned/accepted by this function is a simple
%   structure but is not designed for customer manipulation.
%
%   See also: tallrng

%   Copyright 2017 The MathWorks, Inc.

persistent globe;
mlock

if isempty(globe) % first time call
    oldState = matlab.bigdata.internal.createDefaultRandState();
    
    if nargin == 1
        % this handles the case when globe is being initialized to stream.
        globe = iUpdateGlobeOrError(newState);
    else
        globe = oldState;
    end
    
else % updating global rand stream
    oldState = globe;
    if nargin == 1
        globe = iUpdateGlobeOrError(newState);
    end
end

end

function globe = iUpdateGlobeOrError(state)
if ~isValidState(state)
    errID = 'MATLAB:RandStream:setglobalstream:InvalidInput';
    me = MException(message(errID));
    throwAsCaller(me);
end
globe = state;
end

function tf = isValidState(state)
requiredFields = {'Type','Seed','StreamIndex','Substream'};
tf = isstruct(state) ...
        && all(ismember(requiredFields, fieldnames(state)));
end