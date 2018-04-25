function bw = grayconnectedAlgo(X, r, c, tolerance) %#codegen
%grayconnectedAlgo   Algorithmic core of grayconnected.
%   BW = grayconnectedAlgo(X, R, C, TOLERANCE) performs the grayconnected
%   algorithm without any input checking. TOLERANCE and X must have the
%   same datatype. Use this function only if the inputs are guaranteed to
%   be valid and performance is a major concern.

% Copyright 2015 The MathWorks, Inc.

value = X(r, c);
minWindow = value - tolerance;
maxWindow = value + tolerance;

similarValuesImage = (X >= minWindow) & (X <= maxWindow);
bw = bwselect(similarValuesImage, c, r, 8);

end