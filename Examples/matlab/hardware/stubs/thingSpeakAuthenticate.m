function thingSpeakAuthenticate(varargin)
% THINGSPEAKAUTHENTICATE allows a user to store their Read or/and Write
% API Key once for an entire session of MATLAB. This allows the user to
% read data from the authenticated private channel and write data to
% the authenticated channels without specifying the ReadKey or WriteKey
% parameters. This function also allows a user to authenticate themselves
% by using either their username/Email Id and password.
%
% The authentication provided by this function is for the current session
% of MATLAB alone. Closing MATLAB will remove the user authentication and
% will require the user to reauthenticate themselves the next time MATLAB
% is started.
%
%   Syntax
%   ------
%
%   thingSpeakAuthenticate(username, password)
%   thingSpeakAuthenticate(channelID, Name, Value)
%
%   Description
%   -----------
%
%   thingSpeakAuthenticate(username, password) allows a user to
%   authenticate themselves to all the channels in the specified user
%   account. 'username' can be either the MathWorks account login id or
%   ThingSpeak account login id. 'username' can also be an Email Id. On
%   authenticating a user using 'username' and 'password', the user will
%   not have to provide either the Read Key or the Write Key for any of the
%   channels contained in their user account.
%
%   thingSpeakAuthenticate(channelID, Name, Value) allows a user to
%   authenticate themselves only to a channel specified by 'channelID'.
%   The 'Name' and 'Value' inputs are as described below:
%
%   Input Arguments
%   ---------------
%
%   Name         Description                            Data Type
%   ----      ------------------                        ---------
%   channelID
%            Channel identification number.             positive integer
%
%   Name-Value Pair Arguments
%   -------------------------
%
%   Name         Description                            Data Type
%   ----      ------------------                        ---------
%
%   ReadKey   Read API Key                              string
%
%
%
%   WriteKey  Write API Key                             string
%
%   Both the Read Api Key and the Write API Key can be found on
%   ThingSpeak.com
%
%   % Example 1
%   % ---------
%   % Authenticate using channel ID and API Keys
%   thingSpeakAuthenticate(17504, 'ReadKey', 'TJW6Y559SUGLKPGR', 'WriteKey', '23ZLGOBBU9TWHG2H');
%
%   % Example 2
%   % ---------
%   % Authenticate using username and password
%   userName = <Enter ThingSpeak.com user name>
%   passwd   = <Enter ThingSpeak.com password>
%   thingSpeakAuthenticate(userName, passwd);
%
%   % Example 3
%   % ---------
%   % Authenticate using email ID and password
%   emailID = <Enter email ID used on ThingSpeak.com>
%   passwd   = <Enter ThingSpeak.com password>
%   thingSpeakAuthenticate(emailID, passwd);

% Copyright 2015-2016 The MathWorks, Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
    tsfcncallrouter('thingSpeakAuthenticate', varargin);
catch err
    throwAsCaller(err);    
end