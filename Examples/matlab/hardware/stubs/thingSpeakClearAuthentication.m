function thingSpeakClearAuthentication(varargin)

% THINGSPEAKCLEARAUTHENTICATION will clear all the authentication information
% provided so far - it will clear both username and password based
% authentication and APIKey based authentication provided by the user.
%
% Syntax:
% ------
%
% thingSpeakClearAuthentication
% thingSpeakClearAuthentication(<channelID>)
% thingSpeakClearAuthentication(<username>)
% thingSpeakClearAuthentication(<emailID>)
%
% Description:
% ------------
%
% thingSpeakClearAuthentication
% clears all authentication information stored for the current session of MATLAB.
% This include both Read/Write API Keys and username/EmailID based
% authentication information.
%
% thingSpeakClearAuthentication(<channelID>)
% clears both Read and Write API Keys stored for the specified channelID.
%
% thingSpeakClearAuthentication(<username>)
% clears authentication to all channels owned by the specified username account.
% Note that the thingSpeakRead can still be executed for public channels
% owned by the specified username account.
%
% thingSpeakClearAuthentication(<emailID>)
% clears authentication to all channels owned by the specified emailID account.
% Note that the thingSpeakRead can still be executed for public channels
% owned by the specified emailID account.


% Copyright, 2015-2016 The MathWorks Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
   tsfcncallrouter('thingSpeakClearAuthentication', varargin);
catch err
    throwAsCaller(err);
end