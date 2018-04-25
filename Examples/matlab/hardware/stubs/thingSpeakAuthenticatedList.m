function authList = thingSpeakAuthenticatedList()

% THINGSPEAKAUTHENTICATEDLIST function is used to list the user account
% and the Channel number - API Keys provided so far to authenticate user
% access in the current session of MATLAB. The authenticated channels are
% displayed only and an output is not provided.
%
% Syntax
% ------
%
% thingSpeakAuthenticatedList
% authorizedChannels = thingSpeakAuthenticatedList
%
% Description
% -----------
%
% thingSpeakAuthenticatedList
% displays a list of all the channels that have been authenticated for the
% current MATLAB session. If username/emailID based account authentication
% was performed, then public channels associated with the account are also
% displayed.
%
% authorizedChannels = thingSpeakAuthenticatedList
% returns a MATLAB table containing information on all channels that have
% been authenticated for the current MATLAB session.


% Copyright, 2015-2016 The MathWorks Inc.

runFromFolder = pwd;
finishup = onCleanup(@() cd(runFromFolder));

% Check if the mltbx has been installed
try
    authList = tsfcncallrouter('thingSpeakAuthenticatedList', {''});
catch err
    throwAsCaller(err);
end