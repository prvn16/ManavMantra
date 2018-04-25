function out = tail(in, k)
%TAIL  Get last few rows of a table or a timetable.
%   B = TAIL(A) gets the last few rows of the table A and returns the
%   results in the table B.
%
%   B = TAIL(A,K) returns up to K rows from the end of the table A.
%   If A contains fewer than K rows, then the entire table is returned.
%
%   See also: HEAD, TABLE, TIMETABLE.

% Copyright 2016 The MathWorks, Inc.

if nargin<2
    k = 8;
else
    % Check that numrows is a non-negative integer-valued scalar
    validateattributes(k, ...
        {'numeric'}, {'real','scalar','nonnegative','integer'}, ...
        'tail', 'k')
end

h = height(in);

if h < k
	out = in;
else
    out = subsrefParens(in,{h-k+1:h, ':'});
end
