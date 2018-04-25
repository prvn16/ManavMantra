function [boo, offending_name] = utChkforSlashInName(h)
% Check for slashes in names of h and in all objects contained inside h.
% Return true if a slash ('/') is find in any name.

%   Copyright 2005-2017 The MathWorks, Inc.

boo = false;
offending_name = '';
if ~isempty(strfind(h.TsValue.Name,'/'))
    boo = true;
    offending_name = h.TsValue.Name;
    return;
end

Names = h.TsValue.gettimeseriesnames;
if ~isempty(Names)
    Loc = cellfun(@(x) ~isempty(strfind(x,'/')), Names);
    if any(Loc)
        boo = true;
        offending_names = Names(Loc);
        offending_name = offending_names{1};
    end
end