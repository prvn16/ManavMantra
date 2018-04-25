function [weights,conn] = computeChamferMask(num_dims,method) %#codegen
%computeChamferMask Compute chamfer weights based on distance metric.
%   [weights,conn] = computeChamferMask(num_dims,method) calculates N
%   dimensional weight and connectivity matrices given the number of
%   dimensions and a specified distance metric.

%   Copyright 2011-2013 The MathWorks, Inc.

switch method
    case 'cityblock'
        conn = conndef(num_dims,'minimal');
        weights = ones(size(conn));
        
    case 'chessboard'
        conn = conndef(num_dims,'maximal');
        weights = ones(size(conn));
        
    case 'quasi-euclidean'
        conn = conndef(num_dims,'maximal');
        
        % For quasi-Euclidean, form a weights array whose values are the
        % distances between the corresponding elements and the center
        % element.
        kk = cell(1,num_dims);
        [kk{:}] = ndgrid(-1:1);
        weights = zeros(size(conn));
        for p = 1:num_dims
            % Although the Euclidean distance formula certainly involves
            % squaring each term, all terms here are either 0, 1, or -1,
            % so that's why the abs() term isn't squared below.
            weights = weights + abs(kk{p});
        end
        weights = sqrt(weights);
        
    otherwise
        error(message('images:computeChamferMask:unrecognizedMethodString', method));

end

conn    = logical(conn);