function tf = isEquivalentToLiteralColon(subscript)
%isEquivalentToLiteralColon Check if input is equivalent to literal colon.
%
% If a subscript is an EndMarker, dispatch will go to its instance method
% EndMarker/isEquivalentToLiteralColon. So this implementation only need to
% worry about literal colon itself.

% Copyright 2017 The MathWorks, Inc.

tf = matlab.bigdata.internal.util.isColonSubscript(subscript);
end
