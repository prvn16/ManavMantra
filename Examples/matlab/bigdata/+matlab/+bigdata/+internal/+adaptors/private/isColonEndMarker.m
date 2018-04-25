function tf = isColonEndMarker(sub)
%isEndMarker Return true if the input is an EndMarker that can be expressed
% in colon form once resolved.

% Copyright 2017 The MathWorks, Inc.

tf = isEndMarker(sub) && isscalar(sub);
end
