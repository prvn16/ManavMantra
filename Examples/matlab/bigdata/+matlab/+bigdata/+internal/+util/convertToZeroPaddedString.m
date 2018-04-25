function str = convertToZeroPaddedString(value, maxValue)
%CONVERTTOZEROPADDEDSTRING Convert a positive integer scalar to a string
%representation that is zero padded to fit all integers under maxValue.

assert(isnumeric(value) && isscalar(value) && value > 0);

if nargin < 2 || isempty(maxValue)
    str = char(string(value));
else
    assert(isnumeric(maxValue) && isscalar(maxValue) && maxValue > 0);
    
    numDigits = max(1, ceil(log10(maxValue + 1)));
    formatString = ['%0' char(string(numDigits)) 'i'];
    str = sprintf(formatString, value);
end
