function newLimits = setAxesLimits(scatterData)
% Utility function for Color Thresholder app

%   Copyright 2016 The MathWorks, Inc.

% Set axes limits based on new projection
scatterLimits = [min(scatterData), max(scatterData)];
maxVal = max(abs(scatterLimits));

% For single or colocated points, if min and max are the same then set
% arbitrary limits
if maxVal < 0.001 % zero with some tolerance
    newLimits = [-1 1];
else
    newLimits = [-maxVal(1), maxVal(1)];
end

end