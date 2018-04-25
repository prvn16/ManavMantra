function y = wconv1(x,f,shape)
%MATLAB Code Generation Library Function

%   Limitations:
%   * Always returns a row vector unless x is a fixed-length or
%     variable-length column vector (m-by-1 or :-by-1).

%   Copyright 1995-2015 The MathWorks, Inc.
%#codegen

if nargin < 3
    shape = 'full';
end
if coder.internal.isConst(iscolumn(x)) && iscolumn(x)
    y = conv2(x,f(:),shape); 
else
    y = conv2(x(:)',f(:)',shape); 
end
