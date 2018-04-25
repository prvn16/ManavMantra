function y = flipdim(x,dim)
%FLIPDIM Flip tall matrix along specified dimension.
%   FLIPDIM is not recommended. Use FLIP instead.
% 
%   FLIPDIM(X,DIM)
%
%   Limitations:
%   DIM must be greater than one.
%
%   See also FLIP, TALL.

%   Copyright 2017 The MathWorks, Inc.

% Do some error checking up-front since FLIPDIM and FLIP do this
% differently
if nargin~=2
    error(message('MATLAB:flipdim:nargin'));
end
tall.checkNotTall(upper(mfilename), 2, dim); % DIM cannot be tall
dim = floor(dim);
if (dim <= 0) 
    error(message('MATLAB:flipdim:DimNotPos'));
end
y = flip(x,dim);

end
