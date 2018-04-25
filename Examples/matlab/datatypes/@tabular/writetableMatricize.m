function var = writetableMatricize(var)
% WRITETABLEMATRICIZE turns ND-arrays into 2D. Character arrays are handled
% here. Other types are delegated to matlab.internal.datatypes.matricize

% Copyright 2015 The MathWorks, Inc.
if ischar(var)
    % Turn ND char array into 3D
    var = var(:, :, :);
    % 'Matricize' 3D char into 2D
    [n,m,d] = size(var);
    if d > 1
        var = permute(var,[1 3:ndims(var) 2]);
        var = reshape(var, n*d, m); % unlike ':', reshape preserves memory by utilizing shared-data copy
    end
    var = reshape(num2cell(var,2), n, d);
else % delegate to table's matricize helper for non-char case
    var = matlab.internal.datatypes.matricize(var);
end
end