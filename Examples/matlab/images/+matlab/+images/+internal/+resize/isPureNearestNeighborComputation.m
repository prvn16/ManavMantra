% Copyright 2016 The MathWorks, Inc.

function tf = isPureNearestNeighborComputation(weights)
% True if there is only one column of weights, and if the weights are
% all one.  For this case, the resize can be done using a quick
% indexing operation.

one_weight_per_pixel = size(weights, 2) == 1;
tf = one_weight_per_pixel && all(weights == 1);
end