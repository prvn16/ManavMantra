%MLOCK Prevents clearing function from memory.
%   MLOCK locks the currently running MATLAB code file or MEX-file in
%   memory so that subsequent CLEAR commands do not remove it.
%
%   Use the command MUNLOCK or MUNLOCK(FUN) to return the MATLAB code
%   file or MEX-file to its normal CLEAR-able state.
%
%   Locking a MATLAB code file or MEX-file in memory also prevents
%   any PERSISTENT variables defined in the file from getting
%   reinitialized.
%
%   See also MUNLOCK, MISLOCKED, PERSISTENT.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.
