function out = end(~, ~, ~)
%END Last index in indexing expression
%   END serves as the last index in a tall array indexing expression.

% Copyright 2015 The MathWorks, Inc.

out = matlab.bigdata.internal.util.EndMarker();
end
