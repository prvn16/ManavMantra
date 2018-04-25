%LASTERROR  Last error message and related information.
%   LASTERROR returns a structure containing the last error message issued 
%   by MATLAB as well as other last error-related information. The
%   LASTERROR structure is guaranteed to contain at least the following
%   fields:
%
%       message    : the text of the error message 
%       identifier : the message identifier of the error message 
%		stack	   : the location of the error, in the same format as the 
%					 output of dbstack.
%   
%   LASTERROR(ERR) sets the LASTERROR function to return the information 
%   stored in ERR as the last error. The only restriction on ERR is that it
%   must be a scalar structure. Fields in ERR whose names appear in the
%   list above are used as is, while suitable defaults are used for missing
%   fields (for example, if ERR doesn't have an 'identifier' field, then
%   the empty character vector is used instead, and, if a stack field is not 
%   present, the stack is set to be a 0-by-1 structure with the fields: file, 
%   name, and line.)  
%
%   LASTERROR('reset') sets last error information to the default state.
%       message    :    '' 
%       identifier :    '' 
%       stack      :    0-by-1 structure with fields: file, name, and line
%
%   This function depends on global state, and its programmatic use is not
%   encouraged.  The new syntax,
%
%       try
%           execute_code;
%       catch exception
%           do_cleanup;
%           throw(exception);
%       end
%
%   should be used instead, where possible.  At the command line,
%   MException.last contains all of the information in LASTERROR.
%
%   See also MException, MException/last, ERROR, RETHROW, TRY, CATCH,
%            DBSTACK.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.