function Xgv = ndgridvectors(V)
% NDGRIDVECTORS vectors for creating a default NDGRID 
%   Xgv = NDGRIDVECTORS(V) creates cell array of grid vectors Xgv. Where 
%   Xgv{i} = 1:size(V,i). The gridvectors Xgv can be passed to NDGRID to give 
%   [X1, X2, X3,...Xn] = NDGRID(Xgv{:}), such that the size of X1, X2, X3,...Xn
%   equals the size of V.
%

%   Copyright 2011 The MathWorks, Inc.
if isvector(V)
    Xgv{1} = 1:numel(V);
else
    ndimsv = ndims(V);
    Xgv = cell(1,ndimsv);
    sizev = size(V);
    for i = 1:ndimsv
        Xgv{i} = 1:sizev(i);
    end
end

