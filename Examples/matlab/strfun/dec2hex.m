function h = dec2hex(d,n)
%DEC2HEX Convert decimal integer to its hexadecimal representation
%   DEC2HEX(D) returns a character array where each row is the
%   hexadecimal representation of each decimal integer in D.
%   D must contain non-negative integers. If D contains any 
%   integers greater than flintmax, DEC2HEX might not return 
%   exact representations of those integers.
%
%   DEC2HEX(D,N) produces a character array where each row
%   represents a hexadecimal number with at least N digits.
%
%   Example
%       dec2hex(2748) returns 'ABC'.
%
%   See also HEX2DEC, HEX2NUM, DEC2BIN, DEC2BASE, FLINTMAX.

%   Copyright 1984-2010 The MathWorks, Inc.

narginchk(1,2);

d = d(:); % Make sure d is a column vector.

if ~isreal(d) || any(d < 0) || any(d ~= fix(d))
    error(message('MATLAB:dec2hex:FirstArgIsInvalid'))
end
if any(d > flintmax)
    warning(message('MATLAB:dec2hex:TooLargeArg'));
end

numD = numel(d);

if nargin==1,
    n = 1; % Need at least one digit even for 0.
end

[f,e] = log2(double(max(d)));%#ok
n = max(n,ceil(e/4));
n0 = n;

if numD>1
    n = n*ones(numD,1);
end

bits32 = 2^32;

%For small enough numbers, we can do this the fast way.
if all(d<bits32),
    h = sprintf('%0*X',[n,d]');
else
    %Division acts differently for integers
    d = double(d);
    d1 = floor(d/bits32);
    d2 = rem(d,bits32);
    h = sprintf('%0*X%08X',[n-8,d1,d2]');
end

h = reshape(h,n0,numD)';
