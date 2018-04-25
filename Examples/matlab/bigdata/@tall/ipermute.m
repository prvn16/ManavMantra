function B = ipermute(A,order)
%IPERMUTE Inverse permute array dimensions.
%   A = IPERMUTE(B,ORDER) is the inverse of PERMUTE. IPERMUTE rearranges
%   the dimensions of B so that PERMUTE(A,ORDER) will produce B. Permuting
%   the tall dimension (dimension 1) is not allowed.
%
%   See also tall/PERMUTE.

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
B = slicefun(@(x) ipermute(x, order), A);
% It's tricky to compute the dimensionality here as IPERMUTE might increase the
% number of dimensions etc., so settle for the size set up by SLICEFUN.
B.Adaptor = copySizeInformation(A.Adaptor, B.Adaptor);
end
