function [newUrl, lastUrl] = getConnectorUrl(clientId)
%getConnectorUrl Generate a new url and keeps track of the last url.
%   getConnectorUrl generates a new url based on the client id provided,
%   and keeps the last used url in a persistent variable.

%   Copyright 2017 The MathWorks, Inc.
    persistent currentUrl;
    url = connector.getUrl(['/toolbox/matlab/codeanalysis/view/index.html?clientid=' clientId]);

    lastUrl = currentUrl;
    currentUrl = url;

    newUrl = url;
end
