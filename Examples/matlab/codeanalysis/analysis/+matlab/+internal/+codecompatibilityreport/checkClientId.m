function isExisting = checkClientId(clientId)
%checkClientId Check if a client id is already in use.
%   Client ids are stored in a persistent map. But persistent variables are
%   cleared by clear functionName or clear all, so using mlock to keep the
%   variable in memory until MATLAB quits.

%   Copyright 2017 The MathWorks, Inc.
    mlock;
    persistent clientIdMap;

    if isempty(clientIdMap)
        clientIdMap = containers.Map;
    end

    isExisting = isKey(clientIdMap, clientId);
    clientIdMap(clientId) = 1;
end
