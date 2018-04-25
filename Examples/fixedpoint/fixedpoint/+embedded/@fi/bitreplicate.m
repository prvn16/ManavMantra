function y = bitreplicate(u,N)
% BITREPLICATE Combine stored integer bits of a fixed point word N times
%
% SYNTAX
%   C = BITREPLICATE(A, N)
%
% DESCRIPTION:
%   C = BITREPLICATE(A, N) returns a new fixed value with a concatenated bit
%       representation of input 'A' N times
%
%  See also EMBEDDED.FI/BITCONCAT, EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSLICEGET,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(2,2);

if ~isnumeric(N) || ~isscalar(N) || ~isreal(N)
    error(message('fixed:fi:InvalidInputNotRealScalar','N'));
end

if (N < 1)
    error(message('fixed:fi:invalidBitReplicationConstant'));
end

t = u;
for ii=2:N
    t = bitconcat(t, u);
end

y = t;
