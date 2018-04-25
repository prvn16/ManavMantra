function [varargout] = checkmonotonic(varargin)
% CHECKMONOTONIC modifies a gridded data set to make it monotonic increasing
%   [X1,X2,X3,. . .Xn, V] = CHECKMONOTONIC(X1,X2,X3,. . .V) for a grid 
%   defined by X1,X2,X3,. . .Xn, and corresponding grid point values V.
%   Flips Xi along dimension i to ensure Xi is X monotonic increasing. The
%   corresponding values in the i'th dimension are flipped accordingly.

%   Copyright 2012-2013 The MathWorks, Inc.
n1 = nargin-1;
varargout = cell(1,nargin);
V = varargin{end};
for i=1:n1
    [varargout{i}, V] = makemonotonic(varargin{i},V,i);
end
if nargout == 2
    varargout = {varargout(1:end-1),V};
else
    varargout{end} = V;
end

function [X, V] = makemonotonic(X, V, idim)   
% MAKEMONOTONIC flips grid coordinates to make them monotonic increasing
%   [X, V] = MAKEMONOTONIC(XGV,X,V,IDIM) Given an array of grid coordinates X
%   and corresponding values V. Flip X and V along the IDIM dimension of the 
%   array in order to make X monotonic increasing. XGV is a grid vector that
%   was replicated to create X.
%
if isvector(X) 
   if length(X) > 1 && X(1) > X(2)
       X = X(end:-1:1);
       V = flip(V,idim);
   end
else
    if size(X,idim) > 1
        sizeX = size(X);
        if X(1) > X(prod(sizeX(1:(idim-1)))+1)
            X = flip(X,idim);
            V = flip(V,idim);
        end
    end
end
