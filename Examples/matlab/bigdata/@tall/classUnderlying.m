function c = classUnderlying(t)
%classUnderlying Class of underlying data in tall array.
%   C = classUnderlying(T) returns the class of the underlying data in tall
%   array T. C is a tall array containing a character vector. Use GATHER(C)
%   to collect the result into the MATLAB client session.
%
%   Example:
%      t = tall(rand(1,4));
%      c = classUnderlying(t)
%
%   See also: TALL, tall/isaUnderlying.

% Copyright 2016-2017 The MathWorks, Inc.

if isempty(t.Adaptor.Class)
    % Because CLASS returns a char-vector, we need to place it in a cell, and ask
    % getArrayMetadata to unpick it.
    c = getArrayMetadata(t, @class);
    c.Adaptor = setKnownSize(matlab.bigdata.internal.adaptors.getAdaptorForType('char'), ...
                             [1, NaN]);
else
    % We can simply form an already-gathered result.
    c = tall.createGathered(t.Adaptor.Class, getExecutor(t));
end
end
