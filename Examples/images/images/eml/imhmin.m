function J = imhmin(I, H, varargin) %#codegen
%IMHMIN H-minima transform.

%   Copyright 2015 The MathWorks, Inc.

validateattributes(I, {'numeric'}, {'real' 'nonsparse'},...
    'imhmin', 'I', 1);
validateattributes(H, {'numeric'}, {'real' 'scalar' 'nonnegative'}, ...
    'imhmin', 'H', 2);

Ic  = imcomplement(I);
Ih  = imhmax(Ic, H, varargin{:});
J   = imcomplement(Ih);
