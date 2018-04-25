function [m,f,c] = mode(a,varargin)
%MODE Most frequent duration value.
%   M = MODE(T), when T is a vector of durations, computes M as the sample mode,
%   or most frequently occurring value in T.  When T is a matrix, MODE(T) is a
%   row vector containing the mode of each column.  For N-D arrays, MODE(T) is
%   the mode of the elements along the first non-singleton dimension of T.
%   
%   When there are multiple values occurring equally frequently, MODE returns
%   the smallest of those values.
%   
%   [M,F] = MODE(T) also returns an array F, of the same size as M. Each element
%   of F is the number of occurrences of the corresponding element of M.
%   
%   [M,F,C] = MODE(T) also returns a cell array C, of the same size as M.  Each
%   element of C is a sorted vector of all the values having the same frequency
%   as the corresponding element of M.
%  
%   [...] = MODE(T,DIM) takes the mode along the dimension DIM of T.
%   
%   This function is most useful with discrete or coarsely rounded data. The
%   mode for a continuous probability distribution is defined as the peak of its
%   density function.  Applying the mode function to a sample from that
%   distribution is unlikely to provide a good estimate of the peak; it would be
%   better to compute a histogram or density estimate and calculate the peak of
%   that estimate.  Also, the mode function is not suitable for finding peaks in
%   distributions having multiple modes.
%
%   Example:
%   
%      % Create an array of durations with random integers.  Find the
%      % most common (mode) value.
%      dur = hours(randi(4,6,1))
%      mode(dur)
%
%   See also MEAN, MEDIAN, STD.

%   Copyright 2014-2015 The MathWorks, Inc.

m = a;
if nargout < 3
    [m.millis,f] = mode(a.millis,varargin{:});
else
    [m.millis,f,c] = mode(a.millis,varargin{:});
    for i = 1:numel(c)
        c_i = a;
        c_i.millis = c{i};
        c{i} = c_i;
    end
end
