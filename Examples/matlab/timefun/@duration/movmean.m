function y = movmean(varargin)
%MOVMEAN   Moving mean value.
%   Y = MOVMEAN(X,K) for a vector X and positive integer scalar K computes
%   a centered moving average by sliding a window of length K along X. Each
%   element of Y is the local mean of the corresponding values of X inside
%   the window, with Y the same size as X. When K is even, the window is
%   centered about the current and previous elements of X. The sliding
%   window is truncated at the endpoints where there are fewer than K
%   elements from X to fill the window.
%   
%   For N-D arrays, MOVMEAN operates along the first array dimension whose
%   size does not equal 1.
%
%   Y = MOVMEAN(X,[NB NF]) for a vector X and nonnegative integers NB and
%   NF computes a moving average along the length of X, returning the local
%   mean of the previous NB elements, the current element, and the next NF
%   elements of X.
%
%   Y = MOVMEAN(...,DIM) operates along dimension DIM of X.
%
%   Y = MOVMEAN(...,MISSING) specifies how NaN (Not-a-Number) values are
%   treated and can be one of the following:
%
%       'includenan'   - (default) the mean of any window containing NaN
%                        values is also NaN.
%       'omitnan'      - the mean of any window containing NaN values is
%                        the mean of all its non-NaN elements. If all
%                        elements are NaN, the result is NaN.
%
%   Y = MOVMEAN(...,'Endpoints',ENDPT) controls how the mean is calculated
%   at the endpoints of X, where there are not enough elements to fill the
%   window. ENDPT can be either a scalar numeric or logical value or one of
%   the following:
%
%       'shrink'    - (default) compute the mean over the number of
%                     elements of X that are inside the window, effectively
%                     reducing the window size to fit X at the endpoints.
%       'fill'      - compute the mean over the full window size, filling
%                     missing values from X with NaN. This is equivalent to
%                     padding X with NaN at the endpoints.
%       'discard'   - compute the mean only when the window is filled with
%                     elements of X, discarding partial endpoint
%                     calculations and their corresponding elements in Y.
%                     This truncates the output; for a vector X and window
%                     length K, Y has length LENGTH(X)-K+1.
%                     
%   When ENDPT is a scalar numeric or logical value, the missing elements
%   of X inside the window are replaced with that value and Y remains the
%   same size as X.
%
%   Y = MOVMEAN(X,K,...,'SamplePoints',T) computes a centered moving
%   average of X using a window of length K with respect to the sample
%   points T. Each element Y(i) is the local mean of X(IDX), where IDX is
%   the set of indices such that (T(i)-K/2) <= T(IDX) < (T(i)+K/2). Each
%   window has a closed left end and an open right end.
%
%   Y = MOVMEAN(X,[NB NF],...'SamplePoints',T) computes a moving average of
%   X using a window of width (NF-NB) with respect to the sample points T.
%   Each element Y(i) is the local mean of X(IDX), where IDX is the set of
%   indices such that (T(i)-NB) <= T(IDX) <= (T(i)+NF). Both ends for each
%   window are closed.
%   
%   T must be a numeric, duration, or datetime vector of the same length as
%   X, and must be sorted and contain unique points. You can use T to
%   specify time stamps for the data. By default, MOVMEAN uses data sampled
%   uniformly at points T = [1 2 3 ... ].
%
%   Example: Compute a 5-point centered moving average.
%       t = 1:10;
%       x = [4 8 6 -1 -2 -3 -1 3 4 5];
%       yc = movmean(x,5);
%       plot(t,x,t,yc);
%
%   Example: Compute a 5-point trailing moving average.
%       t = 1:10;
%       x = [4 8 6 -1 -2 -3 -1 3 4 5];
%       yt = movmean(x,[4 0]);
%       plot(t,x,t,yt);
%
%   Example: Compute a 5-point centered moving average, padding the ends of
%   the input with NaN.
%       t = 1:10;
%       x = [4 8 6 -1 -2 -3 -1 3 4 5];
%       yp = movmean(x,5,'Endpoints','fill');
%       plot(t,x,t,yp);
%
%   Example: Compute a 5-point trailing moving average, ignoring the first
%   4 window shifts that do not contain 5 input elements.
%       x = [4 8 6 -1 -2 -3 -1 3 4 5];
%       yd = movmean(x,[4 0],'Endpoints','discard');
%
%   Example: Compute a 5-hour centered moving average of non-uniformly
%   spaced data.
%       x = [4 8 6 -1 -2 -3 -1 3 4 5];
%       t = datetime('now') + hours([0 2 5:12]);
%       yd = movmean(x,hours(5),'SamplePoints',t);
%
%   See also MEAN, MOVMEDIAN, MOVSTD, MOVSUM, MOVVAR
%   

% Copyright 2015-2016 The MathWorks, Inc.

    narginchk(2, inf);
    args = convertMovfunArgs(varargin{:});
    y = builtin('movmean', args{:});

end