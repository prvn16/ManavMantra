%ERROR  Display message and abort function.
%   ERROR(MSGID, ERRMSG, V1, V2, ...) displays a descriptive message
%   ERRMSG when the currently-running program encounters an error
%   condition. Depending on how the program code responds to the error,
%   MATLAB then either enters a catch block to handle the error condition,
%   or exits the program.
%
%   MSGID is a unique message identifier, represented by a character vector
%   or string scalar, that MATLAB attaches to the error message to better
%   identify the source of the error (see MESSAGE IDENTIFIERS, below).
%
%   ERRMSG is a character vector or string scalar that informs the user
%   about the cause of the error and can also suggest how to correct the
%   faulty condition. ERRMSG may include predefined escape sequences, such
%   as \n for newline, and conversion specifiers, such as %d for a decimal
%   number.
%
%   Inputs V1, V2, etc. represent values that are to replace conversion
%   specifiers used in ERRMSG. The format is the same as that used with the
%   SPRINTF function.
%
%   ERROR(ERRMSG, V1, V2, ...) reports an error without including a 
%   message identifier in the error report.
%
%   ERROR(ERRMSG) is the same as the above syntax, except that ERRMSG
%   contains no conversion specifiers, no escape sequences, and no
%   substitution value (V1, V2, ...) arguments.
%
%   ERROR(MSGSTRUCT) reports the error using fields stored in the scalar
%   structure MSGSTRUCT. This structure can contain these fields:
%
%       message    - Error message text
%       identifier - See MESSAGE IDENTIFIERS, below
%       stack      - Struct similar to the output of the DBSTACK function
%  
%   If MSGSTRUCT is an empty structure, no action is taken and ERROR
%   returns without exiting the program. If you do not specify the
%   stack, the ERROR function determines it from the current file and line.
% 
%   MESSAGE IDENTIFIERS
%   A message identifier is a character vector or string scalar of the form
% 
%       [component:]component:mnemonic
% 
%   that enables MATLAB to identify with a specific error. It consists of
%   one or more COMPONENT fields followed by a single MNEMONIC field. All 
%   fields are separated by colons. Here is an example identifier that has 
%   2 components and 1 mnemonic.
% 
%       'myToolbox:myFunction:fileNotFound'
% 
%   The COMPONENT and MNEMONIC fields must begin with an 
%   upper or lowercase letter which is then followed by alphanumeric  
%   or underscore characters. 
% 
%   The COMPONENT field specifies a broad category under which various
%   errors can be generated. The MNEMONIC field is normally used as a tag
%   related to the particular message.
% 
%   From the command line, you can obtain the message identifier for an 
%   error that has been issued using the MException.last function. 
%
%   See also MException, MException/throw, TRY, CATCH, SPRINTF, DBSTOP,
%            ERRORDLG, WARNING, DISP, DBSTACK.
    
%   Copyright 1984-2017 The MathWorks, Inc.
%   Built-in function.
