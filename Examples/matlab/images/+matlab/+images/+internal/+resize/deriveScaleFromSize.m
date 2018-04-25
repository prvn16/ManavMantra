% Copyright 2016 The MathWorks, Inc.

function scale = deriveScaleFromSize(params)
% Determine the scale factor from the specified output size.

if ~isempty(params.size_dim)
    % User specified output size in only one dimension. The other(s) were
    % automatically computed.  The scale factor should be calculated
    % only from the dimension specified, which is params.size_dim.
    
    scale = params.output_size(params.size_dim) / ...
        size(params.A, params.size_dim);
    scale = repmat(scale, 1, params.num_dims);
else
    A_size = size(params.A);
    scale = params.output_size ./ A_size(1:params.num_dims);
end
end