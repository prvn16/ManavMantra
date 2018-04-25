%LOOKFOR Search all MATLAB files for keyword.
%   LOOKFOR XYZ looks for the string XYZ in the first comment line
%   (the H1 line) of the HELP text in all MATLAB files found on MATLABPATH
%   (including private directories).  For all files in which a 
%   match occurs, LOOKFOR displays the H1 line.
%
%   For example, "lookfor inverse" finds at least a dozen matches,
%   including the H1 lines containing "inverse hyperbolic cosine"
%   "two-dimensional inverse FFT", and "pseudoinverse".
%   Contrast this with "which inverse" or "what inverse", which run
%   more quickly, but which probably fail to find anything because
%   MATLAB does not ordinarily have a function "inverse".
%
%   LOOKFOR XYZ -all  searches the entire first comment block of
%   each MATLAB file.
%
%   In summary, WHAT lists the functions in a given directory,
%   WHICH finds the directory containing a given function or file, and
%   LOOKFOR finds all functions in all directories that might have
%   something to do with a given key word.
%
%   See also DIR, HELP, WHO, WHAT, WHICH.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.

