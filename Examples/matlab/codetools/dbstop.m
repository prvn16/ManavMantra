%DBSTOP Set breakpoints
%   The DBSTOP function is used to temporarily stop the execution of a
%   program and give the user an opportunity to examine the local
%   workspace. There are several forms to this command. They are:
%
%   (1)  DBSTOP in FILE at LINENO
%   (2)  DBSTOP in FILE at LINENO@
%   (3)  DBSTOP in FILE at LINENO@N
%   (4)  DBSTOP in FILE at SUBFUN
%   (5)  DBSTOP in FILE
%   (6)  DBSTOP in FILE at LINENO if EXPRESSION
%   (7)  DBSTOP in FILE at LINENO@ if EXPRESSION
%   (8)  DBSTOP in FILE at LINENO@N if EXPRESSION
%   (9)  DBSTOP in FILE at SUBFUN if EXPRESSION
%   (10) DBSTOP in FILE if EXPRESSION
%   (11) DBSTOP if error 
%   (12) DBSTOP if caught error
%   (13) DBSTOP if warning 
%   (14) DBSTOP if naninf  or  DBSTOP if infnan
%   (15) DBSTOP if error IDENTIFIER
%   (16) DBSTOP if caught error IDENTIFIER
%   (17) DBSTOP if warning IDENTIFIER
%
%   FILE is the name of the file in which you want the MATLAB to stop,
%   specified as a character vector or string scalar. FILE can include 
%   a full or partial path to the file (see PARTIALPATH). You can specify a
%   file that is not on the current path by using the keyword -completenames 
%   in the command, and specifying FILE as a fully qualified file name.
%   (On Windows, this is a file name that begins with \\ or with a drive 
%   letter followed by a colon. On Unix, this is a file name that begins 
%   with / or ~.) You can also include a filemarker in FILE to specify 
%   the path to a particular subfunction or to a nested function within the
%   same file.
%
%   LINENO is a line number within FILE, N is an integer specifying the Nth
%   anonymous function on the line, and SUBFUN is the name of a subfunction
%   within FILE. EXPRESSION is an evaluatable conditional expression,
%   specified as a character vector or string scalar. IDENTIFIER is a 
%   MATLAB Message Identifier (see help for ERROR for a description of 
%   message identifiers). The AT and IN keywords are optional.
% 
%   The forms behave as follows:
%
%   (1)  Stops at line LINENO in the specified file.
%   (2)  Stops just after any call to the first anonymous function
%        in the specified line number.
%   (3)  As (2), but just after any call to the Nth anonymous function.
%   (4)  Stops at the specified subfunction in the specified file.
%   (5)  Stops at the first executable line in the specified file.
%   (6-10) As (1)-(5), except that execution stops only if EXPRESSION
%        evaluates to true. EXPRESSION is evaluated (as if by EVAL) in the
%        workspace of the program being debugged. Evaluation takes place
%        when MATLAB encounters the breakpoint. EXPRESSION must evaluate 
%        to a scalar logical value (true or false).
%   (11) Causes a stop in any function causing a run-time error that
%        would not be detected within a TRY...CATCH block.
%        You cannot resume execution after an uncaught run-time error.
%   (12) Causes a stop in any function, causing a run-time error that
%        would be detected within a TRY...CATCH block. You can resume 
%        execution after a caught run-time error.
%   (13) Causes a stop in any function causing a run-time warning. 
%   (14) Causes a stop in any function where an infinite value (Inf)
%        or Not-a-Number (NaN) is detected.
%   (15-17) As (11)-(13), except that MATLAB only stops on an error or
%        warning whose message identifier is IDENTIFIER. (If IDENTIFIER 
%        is specified as 'all', then these uses behave exactly like
%        (11)-(13).)
%
%   When MATLAB reaches a breakpoint, it enters debug mode. The prompt
%   changes to a K>> and, depending on the "Open Files when Debugging"
%   setting in the Debug menu, the debugger window may become active. 
%   Any MATLAB command is allowed at the prompt. To resume execution, 
%   use DBCONT or DBSTEP. To exit from the debugger, use DBQUIT.
%
%   See also DBCONT, DBSTEP, DBCLEAR, DBTYPE, DBSTACK, DBUP, DBDOWN, DBSTATUS,
%            DBQUIT, ERROR, EVAL, LOGICAL, PARTIALPATH, TRY, WARNING.

%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.

