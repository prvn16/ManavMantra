function r = corr2(varargin)
%CORR2 2-D correlation coefficient.
%   R = CORR2(A,B) computes the correlation coefficient between A
%   and B, where A and B are 2-D gpuArrays of the same size.
%
%   Class Support
%   -------------
%   A and B must be real, 2-D gpuArrays. If either one of A or B is not a
%   gpuArray, it must be numeric or logical and non-sparse. Any data not
%   already on the GPU is moved to GPU memory. R is a scalar double
%   gpuArray.
%
%   Example
%   -------
%   I = gpuArray(imread('pout.tif'));
%   J = stdfilt(I);
%   R = corr2(I,J)
%
%   See also CORRCOEF, GPUARRAY/STD2, GPUARRAY.

%   Copyright 2013-2015 The MathWorks, Inc.

[a,b] = ParseInputs(varargin{:});

ma = sum(sum(a,'double'));
mb = sum(sum(b,'double'));
np = numel(a);

[ab,aa,bb] = arrayfun(@findDotProducts,a,b);

r = sum(sum(ab))/sqrt(sum(sum(aa))*sum(sum(bb)));

    function [ab_ij,aa_ij,bb_ij] = findDotProducts(a_ij,b_ij)
        %Nested function to compute (a-mean2(a)).*(b-mean2(b)),
        %(a-mean2(a))^2 and (b-mean2l(b))^2 element-wise.
        
        a_ij = double(a_ij) - ma/np;
        b_ij = double(b_ij) - mb/np;
        
        ab_ij = a_ij*b_ij;
        aa_ij = a_ij*a_ij;
        bb_ij = b_ij*b_ij;
    end
end

%--------------------------------------------------------
function [A,B] = ParseInputs(varargin)

narginchk(2,2);

A = varargin{1};
B = varargin{2};

if isa(A,'gpuArray')
    hValidateAttributes(A,...
        {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
        {'real','2d','nonsparse'},mfilename,'A',1);
    
else
    % GPU implementation does not support sparse matrices.
    validateattributes(A, {'logical' 'numeric'},...
                       {'real','2d','nonsparse'}, mfilename, 'A', 1);
end

if isa(B,'gpuArray')
    hValidateAttributes(B,...
        {'logical','uint8','int8','uint16','int16','uint32','int32','single','double'},...
        {'real','2d','nonsparse'},mfilename,'B',2);
                                          
else
    % GPU implementation does not support sparse matrices.
    validateattributes(B, {'logical' 'numeric'},...
                       {'real','2d','nonsparse'}, mfilename, 'B', 2);
end

if any(size(A)~=size(B))
    error(message('images:corr2:notSameSize'))
end
end
