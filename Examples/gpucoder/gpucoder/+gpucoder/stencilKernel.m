function im1 = stencilKernel(func, im, window, shape, varargin)
%
% GPU coder stencil function
%   -------------
%   B = stencilKernel(FUNC,A,[M N], SHAPE, PARAM1, PARAM2...) 
%   applies the function FUNC to each [M, N] sliding window of the input A.
%   Function FUNC is called for each [M,N] sub-matrix of A and
%   computes an element of output B. The index of this element corresponds
%   to the center of the [M, N] window.
%
%       C = FUNC(X, PARAM1, PARAM2, ...)
%
%   FUNC must be a FUNCTION_HANDLE.
%
%   X is the [M,N] sub-matrix of the original input A. X may be zero-padded
%   when necessary, for instance at the boundaries of input A. X and window 
%   may also be 1-D.
%
%   C is a scalar valued output of FUNC. 
%   It is the output computed for the center element of the [M,N] array X 
%   and is assigned to corresponding element of the output array B.
%
%   PARAM1, PARAM2 are optional arguments. These need to be passed if FUNC 
%   requires needs any additional parameters in addition to input window.
%
%   The window [M,N] must be <=  the size of A, with same shape as A.
%   If A is 1-D row vector, the window should be [1, N].
%   If A is 1-D column vector, the window should be [N, 1].
%
%   SHAPE determines the size of the output array B.
%   -------------
%   It may be one of possible  values:
%     'same'  - output B is the same size as A.
%     'full'  - size of B > size of A  i.e. if A is of size (x,y)
%               size of B = [x + floor(M/2), y + floor(N/2)]
%     'valid' - returns only those parts 
%               that are computed without the zero-padded edges of A.
%               size of B = [x - floor(M/2), y - floor(N/2)]
%
%   Class Support
%   -------------
%   The input A must be a vector or matrix with a numeric type supported by FUN.
%   The class of B is the same as the class of A. 
%
%   Code generation
%   -------------
%   Code generation is only supported for fixed size outputs. 
%   Hence shape and window need to be compile time constants since they
%   determine the size of output. 
% 
%   Example: Mean filtering of a matrix A where A = imread('cameraman.tif')
%   
%   function B = test(A)  %#codegen
%       B = gpucoder.stencilKernel(@my_mean,A,[3 3],'same');
%       function out = my_mean(A)
% 	      out = cast(mean(A(:)), class(A));
%       end
%   end 

%   Copyright 2016 The MathWorks, Inc.

%#codegen
if coder.target('MATLAB')
    im1 = gpucoder.internal.stencil_sim(func, im, window, shape, varargin{:});
else	
    im1 = gpucoder.internal.stencil_codegen(func, im, window, shape, varargin{:});
end
