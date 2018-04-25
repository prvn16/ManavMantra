function noncedAppURL = CreateNoncedURL(appUrl)
%% Get the URL with the port and nonce given an application URL
%   Copyright 2014-2015 The MathWorks, Inc.

noncedAppURL = connector.getUrl(appUrl);
