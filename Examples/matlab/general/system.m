%SYSTEM   Execute system command and return result.
%   [status,result] = SYSTEM('command') calls upon the operating system to
%   execute the given command.  The resulting status and standard output
%   are returned.
%
%   The following trailing character has special meaning:
%           '&' - For console programs this causes the console to
%                 open.  Omitting this character causes console
%                 programs to run iconically. For GUI programs,
%                 appending this character causes the application to
%                 run in the background. MATLAB continues processing.
%
%   This function is interchangeable with the DOS and UNIX functions. They
%   all have the same effect.
%
%   Examples:
%
%       [status,result] = system('dir')
%       [status,result] = system('ls')
%
%   returns status = 0 and, in result, a MATLAB character vector containing
%   a list of files in the current directory (assuming your operating
%   system knows about the "dir" or "ls" command). If "dir" or "ls" fails
%   or does not exist on your system, SYSTEM returns a nonzero value in
%   status, and an explanatory message in result.
%
%   See also COMPUTER, DOS, PERL, UNIX, and ! (exclamation point) under PUNCT.

%   Copyright 1984-2016 The MathWorks, Inc.
