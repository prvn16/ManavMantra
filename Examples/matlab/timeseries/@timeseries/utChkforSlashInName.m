function [boo, offending_name] = utChkforSlashInName(h)
% Check for slashes in names of h and in all objects contained inside h.
% Return true if a slash ('/') is find in any name. 

%   Copyright 2005-2006 The MathWorks, Inc.

boo = false;
offending_name = '';
if ~isempty(strfind(h.Name,'/'))
    boo = true;
    offending_name = h.Name;
end
