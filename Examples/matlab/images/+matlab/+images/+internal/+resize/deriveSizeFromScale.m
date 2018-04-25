% Copyright 2016 The MathWorks, Inc.

function output_size = deriveSizeFromScale(params)
% Determine the output size from the specified scale factor.
    A_size = size(params.A);
    while numel(A_size) < params.num_dims
       A_size = [A_size 1];
    end
    output_size = ceil(params.scale .* A_size(1:params.num_dims));
end