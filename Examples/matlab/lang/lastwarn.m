%LASTWARN Last warning message.
%   LASTWARN, by itself, returns a character vector containing the last 
%   warning message issued by MATLAB.
%
%   [LASTMSG, LASTID] = LASTWARN returns two character vectors, the first containing the
%   last warning message issued by MATLAB and the second containing the last
%   warning message's corresponding message identifier (see HELP WARNING for
%   more information on message identifiers).
%
%   LASTWARN('') resets the LASTWARN function so that it will return an empty
%   character vector for both LASTMSG and LASTID until the next warning is
%   encountered.
%   
%   LASTWARN('MSG', 'MSGID') sets the last warning message to MSG and the last
%   warning message identifier to MSGID.  MSGID must be a legal message
%   identifier (or an empty character vector).
%
%   The WARNING function will update LASTWARN's state irrespective of
%   whether the warning invoked was on or off at the time.
%
%   See also WARNING, MException.last.

%   Copyright 1984-2016 The MathWorks, Inc.
%   Built-in function.
