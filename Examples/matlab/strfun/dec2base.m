function s = dec2base(d,b,nin)
%DEC2BASE Convert decimal integer to its base B representation
%   DEC2BASE(D,B) returns the representation of D as a character vector in
%   base B.  D must be a non-negative integer array smaller than
%   flintmax and B must be an integer between 2 and 36.
%
%   DEC2BASE(D,B,N) produces a representation with at least N digits.
%
%   Examples
%       dec2base(23,3) returns '212'
%       dec2base(23,3,5) returns '00212'
%
%   See also BASE2DEC, DEC2HEX, DEC2BIN, FLINTMAX.

%   Copyright 1984-2016 The MathWorks, Inc.

% Original by Douglas M. Schwarz, Eastman Kodak Company, 1996.
narginchk(2,3);

d = d(:);
if ~(isnumeric(d) || ischar(d)) || any(d ~= floor(d)) || any(d < 0) || any(d > flintmax)
    error(message('MATLAB:dec2base:FirstArg'));
end
if ~isscalar(b) || ~(isnumeric(b) || ischar(b)) || b ~= floor(b) || b < 2 || b > 36
    error(message('MATLAB:dec2base:SecondArg'));
end
if nargin == 3
    if ~isscalar(nin) || ~(isnumeric(nin) || ischar(nin)) || nin ~= floor(nin) || nin < 0
        error(message('MATLAB:dec2base:ThirdArg'));
    end
end
d = double(d);
b = double(b);
n = max(1,round(log2(max(d)+1)/log2(b)));
while any(b.^n <= d)
    n = n + 1;
end
if nargin == 3
    n = max(n,nin);
end
s(:,n) = rem(d,b);
% any(d) must come first as it short circuits for empties
while any(d) && n >1
    n = n - 1;
    d = floor(d/b);
    s(:,n) = rem(d,b);
end
symbols = '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
s = reshape(symbols(s + 1),size(s));
