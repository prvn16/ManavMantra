function [f,status] = urlwrite(url,filename,varargin)
%URLWRITE Save the contents of a URL to a file.
%   NOTE: This function will be removed in a future release.  Most uses of
%   URLWRITE can be replaced by WEBSAVE or FTP.
%
%   URLWRITE(URL,FILENAME) saves the contents of a URL to a file.  FILENAME
%   can specify the complete path to a file.  If it is just the name, it will
%   be created in the current directory.
%
%   F = URLWRITE(...) returns the path to the file.
%
%   F = URLWRITE(...,METHOD,PARAMS) passes information to the server as
%   part of the request.  The 'method' can be 'get', or 'post' and PARAMS is a
%   cell array of param/value pairs.
%
%   URLWRITE(...,'Timeout',T) sets a timeout, in seconds, when the function
%   will error rather than continue to wait for the server to respond or send
%   data.
%
%   [F,STATUS] = URLWRITE(...) catches any errors and returns the error code. 
%
%   Examples:
%   urlwrite('http://www.mathworks.com/',[tempname '.html'])
%   urlwrite('ftp://ftp.mathworks.com/README','readme.txt')
%   urlwrite(['file:///' fullfile(prefdir,'history.m')],'myhistory.m')
% 
%   From behind a firewall, use the Preferences to set your proxy server.
%
%   See also URLREAD, WEBSAVE, FTP

%   Copyright 1984-2017 The MathWorks, Inc.

% Do we want to throw errors or catch them?
if nargout == 2
    catchErrors = true;
else
    catchErrors = false;
end

[f,status] = urlreadwrite(mfilename,catchErrors,url,filename,varargin{:});
