function [varargout] = stripnansforspline(varargin)
% STRIPNANSFORSPLINE strips columns containing NaNs from the input dataset
%   [X1,X2,X3,. . . V] = STRIPNANSFORSPLINE(X1,X2,X3,. . Xn, V) given a grid
%   defined by X1,X2,X3,... Xn and an array of corresponding values V.
%   STRIPNANSFORSPLINE deletes the NaN-containing columns of V from the N'th
%   dimension. The columns of the corresponding coordinates are also stripped
%   to match. This alternative to inpainting removes NaNs from V. The spline
%   interpolation methods in INTERP1, INTERP2, INTERP3, and INTERPN require
%   V to be free of NaN values.

%   Copyright 2011 The MathWorks, Inc.

Xgrid = {varargin{1:(end-1)}};
V = varargin{end};
if iscolumn(V)
    V = V.';
end
numd = ndims(V);
if isvector(V)
    numd = 1;
end
sizev = size(V);
fullgrid = ~any(cellfun(@isvector,Xgrid));
if numd > 2
    V = reshape(V,prod(sizev(1:(numd-1))),sizev(numd));
    if fullgrid
        for i = 1:numd
            Xgrid{i} = reshape(Xgrid{i},prod(sizev(1:(numd-1))),sizev(numd));
        end
    end
end
nanv = find(sum(isnan(V),1));
if ~isempty(nanv)
    V(:,nanv) = [];
    if fullgrid
        for i = 1:numd
            Xgrid{i}(:,nanv) = [];
        end
    else % Gridvectors
        if numd == 2
            Xgrid{2}(nanv) = [];  % NaNs stripped from Columns
        else
            Xgrid{numd}(nanv) = [];
        end
    end
end
if numd > 2
    ncol = size(V,2);
    sizev(numd) = ncol;
    V = reshape(V,sizev);
    if fullgrid
        for i = 1:numd
            Xgrid{i} = reshape(Xgrid{i},sizev);
        end
    end
end
if nargout == 2
    varargout = {Xgrid,V};
else
    varargout = {Xgrid{:},V};
end
