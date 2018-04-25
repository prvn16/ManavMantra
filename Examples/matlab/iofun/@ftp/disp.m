function disp(h)
% DISP Display method for the FTP object.

% Matthew J. Simoneau, 14-Nov-2001
% Copyright 1984-2012 The MathWorks, Inc.

if length(h) ~= 1
    % FTP array; Should work for empty case as well.
    s = size(h);
    str = sprintf('%dx',s);
    str(end) = [];
    disp(getString(message('MATLAB:ftp:ArrayOfFtp',str)));
else
    disp(sprintf( ...
        '  FTP Object\n     host: %s\n     user: %s\n      dir: %s\n     mode: %s', ...
        h.host,h.username,char(h.remotePwd.toString),char(h.type.toString)));
end
