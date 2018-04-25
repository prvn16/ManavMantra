function tf = issorted(tt,rowsFlag,varargin)
%ISSORTED TRUE for a sorted timeable.
%   ISSORTED(T) returns TRUE if rows of the timetable T are sorted by increasing
%   time (in other words, if T and SORTROWS(T) are identical) and FALSE if not.
%
%   ISSORTED(T) is equivalent to ISSORTEDROWS(T), but ISSORTEDROWS accepts
%   additional inputs that support more generality when testing if a timetable
%   is sorted. For example, ISSORTEDROWS allows testing if a timetable is
%   sorted by a data variable rather than by its row times, or if a timetable
%   is sorted in descending order.
%
%   See also ISSORTEDROWS, SORTROWS, UNIQUE, ISMEMBER, INTERSECT, SETDIFF, SETXOR, UNION.

%   Copyright 2016-2017 The MathWorks, Inc.

if nargin > 1
    if nargin > 2 || ~strcmpi(rowsFlag,'rows') % only 'rows' is accepted
        error(message('MATLAB:timetable:issorted:DimArgNotAccepted'));
    end
end

tf = issorted(tt.rowDim.labels);

