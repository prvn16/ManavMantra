function y = quantizenumeric(x,signed,wordlength,fractionlength,roundmode,overflowmode)
% QUANTIZENUMERIC Quantize numeric data
%
%    Y = QUANTIZENUMERIC(X,S,W,F,R) quantizes the value X using
%    signedness S, word length W, fraction length F and roundmode R. The 
%    overflowmode is 'saturate'.
%
%    Y = QUANTIZENUMERIC(X,S,W,F,R,O) quantizes the value X using
%    signedness S, word lnegth W, fraction length F, roundmode R and
%    overflowmode O.
%
%    The allowed roundmodes are:
%     'ceil'       - Round towards positive infinity (same as 'ceiling').
%     'ceiling'    - Round towards positive infinity (same as 'ceil').
%     'convergent' - Convergent rounding.
%     'fix'        - Round towards zero (same as 'zero').
%     'floor'      - Round towards negative infinity.
%     'nearest'    - Round towards nearest.  Ties round toward +inf.
%     'round'      - Round towards nearest.  Ties round up in absolute value. 
%     'zero'       - Round towards zero (same as 'fix').
%
%    The allowed overflow modes are:
%     'saturate' and 'wrap'.
%
%    Example:
%
%    x = randn(1,100)*pi;
%    y = quantizenumeric(x,1,16,14,'nearest');
%
%   See also FI, QUANTIZER

%   Copyright 2009-2017 The MathWorks, Inc.

if nargin > 4
    roundmode = convertStringsToChars(roundmode);
end

if nargin > 5
    overflowmode = convertStringsToChars(overflowmode);
end

narginchk(5,6);

if isequal(nargin,5)
    y = embedded.fi.quantizenumeric(x,signed,wordlength,fractionlength,roundmode);
else % nargin == 6
    y = embedded.fi.quantizenumeric(x,signed,wordlength,fractionlength,roundmode,overflowmode);
end
