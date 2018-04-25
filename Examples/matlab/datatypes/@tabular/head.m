function out = head(in, k)
%HEAD  Get first few rows of a table or a timetable.
%   B = HEAD(A) gets the first few rows of the table A and returns the
%   results in the table B.
%
%   B = HEAD(A,K) returns up to K rows from the beginning of the table A.
%   If A contains fewer than K rows, then the entire table is returned.
%
%   See also: TAIL, TABLE, TIMETABLE.

% Copyright 2016 The MathWorks, Inc.

if nargin<2
    k = 8;
else
    % Check that numrows is a non-negative integer-valued scalar
    validateattributes(k, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'head', 'k')
end

h = height(in);

if h < k
	out = in;
else
    out = subsrefParens(in,{1:k, ':'});
end
