%KEYBOARD Invoke keyboard from MATLAB code file.
%   KEYBOARD, when placed in a MATLAB code file, stops execution of
%   the file and gives control to the user's keyboard. The special
%   status is indicated by a K appearing before the prompt. Variables
%   may be examined or changed - all MATLAB commands are valid. The
%   keyboard mode is terminated by executing the command DBCONT.
%   Control returns to the invoking MATLAB code file.
%
%   DBQUIT can also be used to get out of keyboard mode but in this
%   case the invoking MATLAB code file is terminated. 
%
%   The keyboard mode is useful for debugging your MATLAB code files.
%
%   See also DBQUIT, DBSTOP, DBCONT, INPUT.

%   Copyright 1984-2015 The MathWorks, Inc.
%   Built-in function.
