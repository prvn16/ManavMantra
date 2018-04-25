function B = permute(A,order)
%PERMUTE Permute array dimensions.
%   B = PERMUTE(A,ORDER) rearranges the dimensions of A so that they
%   are in the order specified by the vector ORDER. Permuting the tall
%   dimension (dimension 1) is not allowed.
%
%   See also tall/IPERMUTE.

% Copyright 2015-2016 The MathWorks, Inc.

if ~(isnumeric(order) && ~isobject(order))
    error(message('MATLAB:permute:badIndexType'));
end
if ~isreal(order) || any(order<1 | order~=round(order))
    error(message('MATLAB:permute:badIndex'));
end
if numel(unique(order)) ~= numel(order)
    error(message('MATLAB:permute:repeatedIndex'));
end
if order(1)~=1 || any(order(2:end)==1)
    error(message('MATLAB:bigdata:array:PermuteTallDim'));
end

% Do it!
B = slicefun(@(x) permute(x, order), A);
% It's tricky to compute the dimensionality here as PERMUTE might increase the
% number of dimensions etc., so settle for the size set up by SLICEFUN:
B.Adaptor = copySizeInformation(A.Adaptor, B.Adaptor);
end
