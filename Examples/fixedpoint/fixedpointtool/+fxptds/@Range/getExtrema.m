function extremum = getExtrema(this)
    % This function is a Public API to get the extrema of the range as a
    % single vector rather than distinct values
    % Copyright 2016 The MathWorks, Inc.
    extremum = [this.minExtremum, this.maxExtremum];
end