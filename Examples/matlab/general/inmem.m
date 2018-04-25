%INMEM List functions in memory. 
%   M = INMEM returns a cell array of character vectors containing the 
%   names of program files that are currently loaded.
%
%   M = INMEM('-completenames') is similar, but each element of
%   the cell array has the directory, file name, and file extension.
%
%   [M,MEX]=INMEM also returns a cell array containing the names of
%   the MEX files that are currently loaded.
%
%   [M,MEX,C]=INMEM also returns a cell array containing the names of
%   the classes that are currently loaded. 
%
%   Examples:
%      clear all % start with a clean slate
%      magic(10)
%      m = inmem
%   lists the program files that were required to run magic.
%      m1 = inmem('-completenames')
%   lists the same files, each with directory, name, and extension.
%
%   If INMEM is called with any argument other than '-completenames',
%   it behaves as if it were called with no argument.
%
%   See also WHOS, WHO.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
