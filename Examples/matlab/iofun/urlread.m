function [s,status] = urlread(url,varargin)
%URLREAD Returns the contents of a URL.
%   NOTE: This function will be removed in a future release.  Most uses of URLREAD
%   with the 'get' method should be replaced by WEBREAD.  Most uses with the
%   'post' method should be replaced by WEBWRITE. 
%
%   S = URLREAD('URL') reads the content at a URL into a character array, S.  If the
%   server returns binary data, the array will contain garbage.
%
%   S = URLREAD('URL','method',PARAMS) passes information to the server as part of
%   the request.  The 'method' can be 'get', or 'post' and PARAMS is a cell array of
%   param/value pairs.
%
%   S = URLREAD(...,'Timeout',T) sets a timeout, in seconds, when the function will
%   error rather than continue to wait for the server to respond or send data.
%
%   [S,STATUS] = URLREAD(...) catches any errors and returns 1 if the file downloaded
%   successfully and 0 otherwise.
%
%   Examples: 
%
%     s = urlread('http://www.mathworks.com') 
%     s = urlread('ftp://ftp.mathworks.com/README') 
%     s = urlread(['file:///'fullfile(prefdir,'history.m')])
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLWRITE, WEBREAD, WEBWRITE, WEBSAVE

%   Copyright 1984-2017 The MathWorks, Inc.

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

[s,status] = urlreadwrite(mfilename,catchErrors,url,varargin{:});
