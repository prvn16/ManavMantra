function [Ac,output_column_size,output_size] = toColumns(A,num_input_components,num_output_components,input_space)
%toColumns Reshape to form column-oriented color array
%
%   [Ac,output_column_size,output_size] = images.color.internal.toColumns(A,...
%       num_input_components,num_output_components,input_space)
%
%   Forms a column-oriented color array for processing by the evaluate
%   method of a color converter object.
%
%   If the input, A, is a matrix of colors, one row per column and one
%   column per color component, then Ac is the same as A.
%
%   If the input is an M-by-N-by-Q color image, then Ac is formed by
%   reshaping A to be an (M*N)-by-Q matrix.
%
%   If the input is an M-by-N-by-Q-by-F color image stack, then Ac is
%   formed by reshaping A to be an (M*N)-by-Q-by-F array.
%
%   Q is checked against num_input_components; an error is thrown if they
%   do not match.
%
%   input_space is used to resolve a potential size ambiguity by assuming
%   there is a single color component if and only input_space is 'gray'.
%
%   output_column_size is the three-element vector [num_colors Q num_frames].
%
%   output_size is the size to be used to reshape the final output from the
%   evaluate method of the color converter. For example, if the input is
%   an M-by-N-by-Q-by-F color image stack, then output_size is
%   [M N num_output_components F].
%
%   Example 1
%   ---------
%   Input A is 300-by-200-by-3 and we are converting from RGB to CMYK. Ac
%   is 60000-by-3, out_col_size is [60000 4 1], and out_size is [300 200 4].
%
%       A = ones(300,200,3);
%       [Ac,out_col_size,out_size] = images.color.internal.toColumns(A,3,4,'rgb');
%
%   Example 2
%   ---------
%   Input A is a 10-by-3 matrix of 10 colors. Ac equals A, out_col_size is
%   [10 3 1], and out_size is [10 3].
%
%       A = ones(10,3);
%       [Ac,out_col_size,out_size] = images.color.internal.toColumns(A,'any','any','generic');
%
%   Example 3
%   ---------
%   Input A is a 100-by-150-by-10 stack of gray-scale images. Ac is 150000-by-1,
%   out_col_size is [150000 1 1], out_size is [100 150 10 1].
%
%       A = ones(100,150,10);
%       [Ac,out_col_size,out_size] = images.color.internal.toColumns(A,'any','any','gray');
%
%   Example 4
%   ---------
%   Input A is a 300-by-200-by-3-by-20 stack of RGB images. Ac is 60000-by-3-by-20,
%   out_col_size is [60000 3 20], out_size is [300 200 3 20].
%
%       A = ones(300,200,3,20);
%       [Ac,out_col_size,out_size] = images.color.internal.toColumns(A,3,3,'rgb');
%
%   See also images.color.ColorConverter

%   Copyright 2014 The MathWorks, Inc.


if strcmp(input_space,'gray')
    color_dim = ndims(A) + 1;
else
    if ismatrix(A)
        color_dim = 2;
    else
        color_dim = 3;
    end
end

if ~strcmp(num_input_components,'any') && (num_input_components ~= size(A,color_dim))
    throwAsCaller(MException(message('images:color:inputSizeMismatch')));
end

ndims_A = max(ndims(A),color_dim);
size_A = zeros(1,ndims_A);

for k = 1:ndims_A
    size_A(k) = size(A,k);
end

M = prod(size_A(1:(color_dim-1)));
Q = size_A(color_dim);
P = prod(size_A((color_dim+1):ndims_A));

Ac = reshape(A,M,Q,P);

output_size = size_A;

if strcmp(num_output_components,'any')
    num_output_components = Q;
end

Qout = num_output_components;
output_size(color_dim) = Qout;

output_column_size = [M Qout P];

