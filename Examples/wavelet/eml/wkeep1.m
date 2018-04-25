function y = wkeep1(x,len,varargin)
%MATLAB Code Generation Library Function

%   Limitations:
%   * Always returns a row vector unless x is a fixed-length or
%     variable-length column vector (m-by-1 or :-by-1).

%   Copyright 1995-2016 The MathWorks, Inc.
%#codegen

narginchk(2,4);
coder.internal.prefer_const(varargin);
nx = coder.internal.indexInt(length(x));
if nargin < 3
    opt = 'c';
elseif ischar(len)
    opt = lower(varargin{1});
else
    opt = varargin{1};
end
if nargin < 4
    side = '0';
else
    side = varargin{2};
end
[first,last] = wkeepFirstLastIndex(nx,len,opt,side);
y = x(first:last);



