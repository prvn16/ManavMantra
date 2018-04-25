function y = filter2(b,x,shape)
%FILTER2 Two-dimensional digital filter.
%   Y = FILTER2(B,X) filters the data in X with the 2-D FIR
%   filter in the matrix B.  The result, Y, is computed 
%   using 2-D correlation and is the same size as X. 
%
%   Y = FILTER2(B,X,SHAPE) returns Y computed via 2-D
%   correlation with size specified by SHAPE:
%     'same'  - (default) returns the central part of the 
%               correlation that is the same size as X.
%     'valid' - returns only those parts of the correlation
%               that are computed without the zero-padded
%               edges, size(Y) < size(X).
%     'full'  - returns the full 2-D correlation, 
%               size(Y) > size(X).
%
%   FILTER2 uses CONV2 to do most of the work.  2-D correlation
%   is related to 2-D convolution by a 180 degree rotation of the
%   filter matrix.
%
%   Class support for inputs B,X:
%      float: double, single
%
%   See also FILTER, CONV2.

%   Copyright 1984-2012 The MathWorks, Inc. 

if nargin < 3
    shape = 'same';
end
if ~isa(x,'float')
    x = double(x);
end
if ~isa(b,'float')
    b = double(b);
end

stencil = rot90(b,2);

if isvector(stencil) || numel(stencil) > numel(x)
    % The filter is bigger than the input.  This is a nontypical
    % case, and it may be counterproductive to check the
    % separability of the stencil.
    y = conv2(x,stencil,shape);
else
    separable = false;
    % Stencil is considered to be not separable if the following test fails
    % for any reason, like non-finite stencil, empty stencil, etc.
    try %#ok<TRYNC>
        [u,s,v] = svd(stencil,'econ'); % Check rank (separability) of stencil
        if s(2,2) <= length(stencil)*eps(s(1,1)) %only need to check if rank > 1
            separable = true;
        end
    end
    if separable
        % Separable stencil
        hcol = u(:,1) * sqrt(s(1));
        hrow = conj(v(:,1)) * sqrt(s(1));
        y = conv2(hcol, hrow, x, shape);
        if all(round(stencil(:)) == stencil(:)) && all(round(x(:)) == x(:))
            % Output should be integer
            y = round(y);
        end
    else
        % Nonseparable stencil
        y = conv2(x,stencil,shape);
    end
end
