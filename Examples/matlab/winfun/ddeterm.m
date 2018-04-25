%

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.

%DDETERM Terminate DDE conversation.  
%   DDETERM takes one argument, the channel handle returned by the previous
%   call to DDEINIT that established the DDE conversation.
%
%   rc = DDETERM(channel)
%
%   rc      Return code: 0 indicates failure, 1 indicates success.
%   channel Conversation channel from DDEINIT.
%
%   For example, to terminate the DDE conversation:
%      rc = ddeterm(channel);

%   DDETERM is available only on Microsoft Windows.
%
%   See also DDEINIT, DDEEXEC, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.
