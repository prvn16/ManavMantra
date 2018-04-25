%MUNLOCK Allow clearing function from memory.
%   MUNLOCK(FUN) unlocks the MATLAB code file or MEX-file named FUN
%   from memory, so that subsequent CLEAR commands can remove it.  These
%   files are unlocked by default, so that changes to the file are picked
%   up.  Calls to MUNLOCK are only needed to unlock MATLAB code files or
%   MEX-files that have been locked with the MLOCK function.
%
%   MUNLOCK, by itself, unlocks the currently running MATLAB code file
%   or MEX-file.
%
%   See also MLOCK, MISLOCKED.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
