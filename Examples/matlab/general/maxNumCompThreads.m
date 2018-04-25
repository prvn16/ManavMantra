function lastn = maxNumCompThreads(varargin)
%maxNumCompThreads controls the maximum number of computational threads
%   N = maxNumCompThreads returns the current maximum number of
%   computational threads N.
%
%   LASTN = maxNumCompThreads(N) set the maximum number of computational
%   threads to N, and returns the previous maximum number of computational
%   threads LASTN.
%
%   LASTN = maxNumCompThreads('automatic') set the maximum number of
%   computational threads to what MATLAB determines to be the most
%   desirable. In addition, it returns the previous maximum number of
%   computational threads LASTN. Currently the maximum number of
%   computational threads is equal to the number of computational cores on
%   your machine. 
%
%   Settings changed by maxNumCompThreads are not propagated to the next
%   MATLAB session.

%   Copyright 2007-2017 The MathWorks, Inc.

narginchk(0, 1)
lastn = maxNumCompThreadsHelper(varargin{:});
