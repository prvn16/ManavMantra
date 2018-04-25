function host = getHostname()
% Copyright 2016 The MathWorks, Inc.
[status, host] = system('hostname');
if status ~= 0
    host = '';
end
host = strtrim(host);
end