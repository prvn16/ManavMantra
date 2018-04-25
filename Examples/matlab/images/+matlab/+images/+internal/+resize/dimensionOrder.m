% Copyright 2016 The MathWorks, Inc.

function order = dimensionOrder(scale)
% Return the desired dimension order for performing the resize.  The
% strategy is to perform the resize first along the dimension with the
% smallest scale factor.

[~, order] = sort(scale);
end