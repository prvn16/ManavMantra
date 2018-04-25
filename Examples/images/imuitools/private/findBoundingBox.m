function [bbox] = findBoundingBox(x,y)
%findBoundingBox Finds the bounding box for a given set of coordinates.
%   BBOX = findBoundingBox(X,Y) returns a rectangle in BBOX defining the [X_MIN
%   Y_MIN WIDTH HEIGHT] of the coordinates specified in the vectors X and Y.

%   Copyright 2005 The MathWorks, Inc.
%   
  
x_min = min(x);
x_max = max(x);
y_min = min(y);
y_max = max(y);
bbox = [x_min y_min (x_max-x_min) (y_max-y_min)];
