function tf = isEndMarker(sub)
%isEndMarker Return true if the input is an EndMarker object.

% Copyright 2017 The MathWorks, Inc.

tf = isa(sub, 'matlab.bigdata.internal.util.EndMarker');
end
