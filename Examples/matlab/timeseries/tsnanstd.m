function y = tsnanstd(varargin)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

% Call tsnanvar(x,flag,dim) with as many inputs as needed
y = sqrt(tsnanvar(varargin{:}));
    
