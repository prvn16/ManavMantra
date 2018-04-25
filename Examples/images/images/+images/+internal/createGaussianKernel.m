function h = createGaussianKernel(sigma, hsize)%#codegen
%CREATEGAUSSIANKERNEL creates a 1/2/3-D Gaussian kernel
%	h = createGaussianKernel(sigma, hsize) creates a Gaussian kernel h with 
%	standard deviation sigma of size hsize. Dimensionality of the kernel
%	is determined by number of elements in hsize.
%
%	Note that this function is intended for use by internal clients only.

%   Copyright 2014-2015 The MathWorks, Inc.

filterRadius = (hsize-1)/2;
filterDims = numel(hsize);

if filterDims == 1
	% 1-D Gaussian kernel for separable filtering
	X = (-filterRadius(1):filterRadius(1))';
	arg = (X.*X)/(sigma(1)*sigma(1));

elseif filterDims == 2
	% 2-D Gaussian kernel
	[X,Y] = meshgrid(-filterRadius(2):filterRadius(2), -filterRadius(1):filterRadius(1));
	arg = (X.*X)/(sigma(2)*sigma(2)) + (Y.*Y)/(sigma(1)*sigma(1));

elseif filterDims == 3
	% 3-D Gaussian kernel
    [X,Y,Z] = ndgrid(-filterRadius(1):filterRadius(1), -filterRadius(2):filterRadius(2), -filterRadius(3):filterRadius(3));
    arg = (X.*X)/(sigma(2)*sigma(2)) + (Y.*Y)/(sigma(1)*sigma(1)) + (Z.*Z)/(sigma(3)*sigma(3));
else
	assert(false, 'hsize must be a 1-, 2- or 3-element vector.')
end

h = exp( -arg/2 );

% Suppress near-zero components	
h(h<eps*max(h(:))) = 0;

% Normalize
sumH = sum(h(:));
if sumH ~=0
    h = h./sumH;
end


end