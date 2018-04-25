function y = getlsb(x)
% GETLSB Get value of LSB
%
% SYNTAX
%   c = getlsb(a)
% 
% DESCRIPTION:
%   c = getlsb(a) returns the value of lsb
%
%   This command is equivalent to 
%
%       c = bitsliceget(a, 1, 1)
%   
% 
%  See also EMBEDDED.FI/GETMSB,
%           EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET, EMBEDDED.FI/BITCONCAT, 
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%           

%   Copyright 2007-2015 The MathWorks, Inc.

% Error checking
narginchk(1,1);

y = bitsliceget(x, 1, 1);