function ID = incrementPeerID()
% This function is undocumented and may change in a future release.

% Generate a unique peer ID for use by area and bar charts.

% mlock this file so that this workflow doesn't reset the counter:
% area(magic(3))
% hold on
% clear all
% area(magic(2))

mlock
persistent persistentID;

if isempty(persistentID)
    persistentID = 1;
else
    persistentID = persistentID + 1;
end

ID = persistentID;

end
