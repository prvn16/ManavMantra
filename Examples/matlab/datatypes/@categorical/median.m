function b = median(a,varargin)
%MEDIAN Median value of a categorical array.
%   B = MEDIAN(A) returns the median of the elements in the ordinal
%   categorical array A. For vectors, B is a categorical array containing 
%   the median element, with the same categories as A. For matrices, B is 
%   a categorical vector containing the median value of each column of A.  
%   For N-D arrays, B is the median value of the elements along the first 
%   non-singleton dimension of A.
%
%   A must be an ordinal categorical array.
%
%   If A contains an even number of elements along the working dimension,
%   the median value is the category midway between the two middle data
%   values, or is the larger of the two categories midway between the two
%   middle data values.
%
%   B = MEDIAN(A,DIM) takes the median along the dimension DIM of A.
%   B = MEDIAN(..., MISSING) specifies how undefined elements are treated.
%
%      'includeundefined' - the median of a vector containing any undefined elements
%                           is also undefined. This is the default.  'includenan' is
%                           equivalent to 'includeundefined'
%      'omitundefined'    - elements of T containing undefined elements are ignored.
%                           If all elements are undefined, then the result is
%                           undefined. 'omitnan' is equivalent to 'omitundefined'.
%
%   See also MEAN, MIN, MAX, MODE.

% Copyright 2014-2017 The MathWorks, Inc.

narginchk(1, 3);

% Convert 'omitundefined to 'omitnan' if it is the last argument.
% Rely on core median to throw errors for incorrect inputs.
if nargin > 1
    [~,varargin{end}] = validateMissingOption(varargin{end});
end

% Check to make sure the categorical is ordinal
if ~isordinal(a)
    error(message('MATLAB:categorical:median:NotOrdinal'));
end

acodes = a.codes;

% Rely on built-in's NaN handling if input contains any <undefined> elements.
acodes = categorical.castCodesForBuiltins(acodes);

% Rely on median's behavior with dim vs. without, especially for empty input
try
    if nargin == 1
        bcodes = median(acodes);
    else
        bcodes = median(acodes,varargin{:});
    end
catch ME
    throw(ME);
end

if isfloat(bcodes)
    % Cast back to integer codes, including NaN -> <undefined>
    bcodes = categorical.castCodes(bcodes,length(a.categoryNames));
end
b = a; % preserve subclass
b.codes = bcodes;
