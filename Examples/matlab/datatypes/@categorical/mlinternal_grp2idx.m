function [gidx,ng,gdata] = mlinternal_grp2idx(group,inclnan,inclempty)
%   FOR INTERNAL USE ONLY -- This feature is intentionally undocumented.
%   Its behavior may change, or it may be removed in a future release.

%  Copyright 2017-2018 The MathWorks, Inc.

% Convert data to double
gidx = double(group.codes);

% Extract group names and count them
gnames = group.categoryNames;
ng = numel(gnames);

% Mark the <undefined> locations 
nid = (gidx == group.undefCode);
anynid = any(nid);

% set gidx to NaN if needed
if anynid
    gidx(nid) = NaN;
end

% Prepopulate gdata valueset
valset = (1:ng)';

% If excluding empty categories need to do more work
if ~inclempty
    if all(nid) 
        % If all are <undefined> or group was empty this means there are no 
        % elements left in the group
        gnames = {}; 
        valset = zeros(0,1);
    else
        % Create a mask of values which are used
        if anynid
            ngidx = group.codes(~nid);
            mask(ngidx) = true;
        else
            mask(group.codes) = true;
        end
        % Compute the new group number
        cmask = cumsum(mask);
        
        % If not all groups present adjust lists
        if cmask(end) ~= numel(gnames)
            if anynid
                gidx(~nid) = cmask(ngidx);
            else
                gidx(:) = cmask(gidx);
            end
            gnames = gnames(mask);
            valset = valset(mask);
        end
    end
    
    % Recompute number of categories
    ng = numel(gnames);
end

% If we're including NaN set the group as the n+1 option
if inclnan && anynid
    ng = ng+1;
    gidx(nid)= ng;
end

% If asking for the groups also create gdata
if nargout > 2
    % Adjust value set if <undefined>'s are present
    if inclnan && anynid
        valset(end+1,1) = group.undefCode;
    end
    
    % Copy gdata information from group (ordinal, etc.)
    gdata = group;
    
    % Set codes to corect value like group
    gdata.codes = cast(valset,'like',group.codes);
end
    
end