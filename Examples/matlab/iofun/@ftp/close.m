function close(h)
%CLOSE Close the connection with the server.
%    CLOSE(FTP) closes the connection with the server.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2004 The MathWorks, Inc.

try
    h.jobject.disconnect;
catch
    % Do nothing.  The error was probably that we were already disconnected.
end