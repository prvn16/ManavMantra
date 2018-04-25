function connect(h)
%CONNECT Open a connection to the server.
%    CONNECT(FTP) opens a connection to the server.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2010 The MathWorks, Inc.

% If we're already connected, exit.
try
    h.jobject.getStatus;
    return
end

% Try to open.
try
    % Adding a timeout for 2 minutes
    % In case of no response, setDefaultTimeout will throw
    % java.net.SocketTimeoutException
    h.jobject.setDefaultTimeout(120000); 
    h.jobject.connect(h.host,h.port);
catch
    error(message('MATLAB:ftp:NoConnection', h.host, sprintf( '%.0f', h.port )))
end

% Try to login.
try
    isSuccess = h.jobject.login(h.username,h.password);
catch
    isSuccess = false;
end
if ~isSuccess
    error(message('MATLAB:ftp:BadLogin', h.username))
end

% Try to return to the directory we were in before, if any.
if (h.remotePwd.length == 0)
    h.remotePwd.append(h.jobject.printWorkingDirectory);
else
    cd(h,char(h.remotePwd.toString));
end
