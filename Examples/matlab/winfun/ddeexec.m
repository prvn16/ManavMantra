%

%   Copyright 1984-2013 The MathWorks, Inc. 
%   Built-in function.

%DDEEXEC Send string for execution.
%   DDEEXEC sends a string for execution to another application via an
%   established DDE conversation. Specify the string as the command
%   argument.
%
%   rc = DDEEXEC(channel,command,item,timeout)
%
%   rc      Return code: 0 indicates failure, 1 indicates success.
%   channel Conversation channel from DDEINIT.
%   command String specifying the command to be executed.
%   item    (optional) String specifying the DDE item name for 
%           execution. This argument is not used for many applications. 
%           If your application requires this argument, it provides 
%           additional information for command. Consult your server 
%           documentation for more information.
%   timeout (optional) Scalar specifying the time-out limit for 
%           this operation.  Timeout is specified in milliseconds.
%           (1000 milliseconds = 1 second). The default value of timeout 
%           is three seconds.
%
%   For example, given the channel assigned to a conversation,
%   send a command to Excel:
%      rc = ddeexec(channel, '[formula.goto("r1c1")]');

%   DDEEXEC is available only on Microsoft Windows.
%
%   See also DDEINIT, DDETERM, DDEREQ, DDEPOKE, DDEADV, DDEUNADV.
