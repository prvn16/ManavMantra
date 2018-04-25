function [tf, P] = islocalmax(A, varargin)
%ISLOCALMAX   Detect local maxima in data.
%   TF = ISLOCALMAX(A) returns a logical array whose elements are true when
%   a local maximum is detected in the corresponding element of A. If A is
%   a matrix or a table, ISLOCALMAX operates on each column separately. If
%   A is an N-D array, ISLOCALMAX operates along the first array dimension
%   whose size does not equal 1.
%
%   TF = ISLOCALMAX(A,DIM) specifies the dimension to operate along.
%
%   TF = ISLOCALMAX(...,'MinProminence',P) returns only those local maxima
%   whose prominence is at least P. The prominence of a local maximum is
%   the smaller of the largest decrease in value on the left side and on
%   the right side of the local maximum before encountering a larger local
%   maximum. For a vector X, the largest prominence is at most
%   MAX(X)-MIN(X).
%
%   TF = ISLOCALMAX(...,'FlatSelection',TYPE) specifies how local maxima
%   are indicated for flat regions containing repeated local maxima values.
%   Options are:
%
%       'center'  - (default) middle index of a flat region marked as true.
%       'first'   - first index of a flat region marked as true.
%       'last'    - last index of a flat region marked as true.
%       'all'     - all flat region indices marked as true.
%
%   TF = ISLOCALMAX(...,'MinSeparation',S) specifies S as the minimum
%   separation between local maxima. S is defined in units of the sample
%   points. When S > 0, ISLOCALMAX selects the largest local maximum and
%   ignores all other local maximum within S units of it. The process is
%   repeated until there are no more local maxima detected. By default, S =
%   0.
%
%   TF = ISLOCALMAX(...,'MaxNumExtrema',N) detects no more than the N most
%   prominent local maxima. By default, N is equal to SIZE(A,DIM).
%
%   TF = ISLOCALMAX(...,'SamplePoints',X) specifies the sample points X
%   representing the location of the data in A. X must be a numeric or
%   datetime vector, and must be sorted with unique elements. For example,
%   X can specify time stamps for the data in A. By default, ISLOCALMAX
%   uses data sampled uniformly at points X = [1 2 3 ... ].
%
%   TF = ISLOCALMAX(...,'DataVariables',DV) finds local maxima only in the
%   table variables specified by DV. The default is all table variables in
%   A. DV must be a table variable name, a cell array of table variable
%   names, a vector of table variable indices, a logical vector, or a
%   function handle that returns a logical scalar (such as @isnumeric). TF
%   has the same size as A. DV cannot be specified if A is not a table or a
%   timetable. Only numeric or logical data variables should be specified.
%
%   [TF,P] = ISLOCALMAX(A,...) also returns the prominence for each value
%   of A.  Points that are not local maxima have a prominence of 0.
%
%   EXAMPLE: Find local maxima in a vector of data.
%       x = 1:100;
%       A = (1-cos(2*pi*0.01*x)).*sin(2*pi*0.15*x);
%       tf = islocalmax(A);
%
%   EXAMPLE: Filter out less prominent local maxima.
%       A = peaks(256);
%       A = A(:, 150);
%       tf = islocalmax(A, 'MinProminence', 1);
%
%   EXAMPLE: Filter out local maxima too close to each other in time.
%       t = hours(linspace(0, 3, 15));
%       A = [2 4 6 4 3 7 5 6 5 10 4 -1 -3 -2 0];
%       S = minutes(45);
%       tf = islocalmax(A, 'MinSeparation', S, 'SamplePoints', t);
%
%   EXAMPLE: Detect center points of flat maxima regions.
%       x = 0:0.1:10;
%       A = min(0.75, sin(pi*x));
%       tf = islocalmax(A, 'FlatSelection', 'center');
%
%   See also ISLOCALMIN, ISCHANGE, ISOUTLIER
%   

% Copyright 2017 The MathWorks, Inc.

    if nargout > 1
        [tf, P] = matlab.internal.math.isLocalExtrema(A, true, varargin{:});
    else
        tf = matlab.internal.math.isLocalExtrema(A, true, varargin{:});
    end

end