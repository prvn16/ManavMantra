%LASTERR Last error message.
%
%   LASTERR is maintained for backward compatibility.  
%
%   This function depends on global state, and its programmatic use is not
%   encouraged.  The newer syntax,
%
%       try
%           execute_code;
%       catch exception
%           do_cleanup;
%           throw(exception);
%       end
%
%   should be used instead, where possible.  At the command line,
%   MException.last contains all of the information in LASTERR.
%
%   LASTMSG = LASTERR returns a character vector containing the most recent
%   error message issued by MATLAB.
%
%   [LASTMSG, LASTID] = LASTERR returns two character vectors, the first 
%   containing the most recent error message issued by MATLAB, the second
%   containing the message identifier corresponding to it. (See HELP ERROR 
%   for more information on message identifiers).
%
%   LASTERR('') resets the LASTERR function so that it returns an empty
%   character vector for both LASTMSG and LASTID until the next error is
%   encountered.
%
%   LASTERR('MSG', 'MSGID') sets the last error message to MSG and the last
%   error message identifier to MSGID. MSGID must be a valid message
%   identifier (or an empty character vector).
%
%   See also MException, MException/last, LASTERROR, ERROR, LASTWARN, TRY,
%            CATCH.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
