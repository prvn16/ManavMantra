function y = bitconcat(varargin) %#ok
% BITCONCAT Combine stored integer bits of fixed point words
%
% SYNTAX
%   Y = BITCONCAT(A, B)
%   Y = BITCONCAT([A, B, C])
%   Y = BITCONCAT(A, B, C, D, ...)
%
% DESCRIPTION:
%   Y = BITCONCAT(A, B) returns a new fixed value with a concatenated bit
%       representation of input operands 'A' and 'B'.
%
%   1)	Output type is always unsigned with wordlength equal to sum of
%       input fixed point word lengths.
%   2)	Scaling has no bearing on the result type and value.
%   3)	The two's complement representation of inputs are concatenated to
%       form the stored integer value of the output.
%   4)	Mix and match of signed and unsigned inputs are allowed. Signed bit
%       is treated like any other bit.
%   5)	Input operands 'A' and 'B' can be vectors but should be of same
%       size. If the operands are vectors then concatenation will be
%       performed element-wise.
%   6)  complex inputs are not supported.
%   7)  Accepts varargin number of inputs for concatenation
%
%  See also EMBEDDED.FI/BITSLICEGET, EMBEDDED.FI/BITGET, EMBEDDED.FI/BITSET,
%           EMBEDDED.FI/BITAND, EMBEDDED.FI/BITOR, EMBEDDED.FI/BITXOR
%           EMBEDDED.FI/BITANDREDUCE, EMBEDDED.FI/BITORREDUCE,
%           EMBEDDED.FI/BITXORREDUCE
%

%   Copyright 2007-2013 The MathWorks, Inc.

narginchk(1,Inf);
error(message('fixed:fi:inputArgsNotFis'));
