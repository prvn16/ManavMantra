function lut = makelut(varargin)
%MAKELUT Create lookup table for use with BWLOOKUP.
%   LUT = MAKELUT(FUN,N) returns a lookup table for use with APPLYLUT.  FUN
%   is a function that accepts an N-by-N matrix of 1s and 0s and returns a
%   scalar.  N can be either 2 or 3.  MAKELUT creates LUT by passing all
%   possible 2-by-2 or 3-by-3 neighborhoods to FUN, one at a time, and
%   constructing either a 16-element vector (for 2-by-2 neighborhoods) or a
%   512-element vector (for 3-by-3 neighborhoods).  The vector consists of
%   the output from FUN for each possible neighborhood.
%
%   FUN must be a FUNCTION_HANDLE.
%
%   Class Support
%   -------------
%   LUT is returned as a vector of class double.
%
%   Example
%   -------
%       f = @(x) (sum(x(:)) >= 2);
%       lut = makelut(f,2);
%
%   See also BWLOOKUP, FUNCTION_HANDLE.

%   Copyright 1993-2012 The MathWorks, Inc.

% Obsolete syntax:
%   LUT = MAKELUT(FUN,N,P1,P2,...) passes the additional parameters P1, P2,
%   ..., to FUN.
%

narginchk(2,inf);

fun = varargin{1};
n = varargin{2};
params = varargin(3:end);
fun = fcnchk(fun, length(params));

if (n == 2)
    lut = zeros(16,1);
    for k = 1:16
        a = reshape(fliplr(dec2bin(k-1,4) == '1'), 2, 2);
        lut(k) = feval(fun, a, params{:});
    end
    
elseif (n == 3)
    lut = zeros(512,1);
    for k = 1:512
        a = reshape(fliplr(dec2bin(k-1,9) == '1'), 3, 3);
        lut(k) = feval(fun, a, params{:});
    end
    
else
    error(message('images:makelut:invalidN'))
end
