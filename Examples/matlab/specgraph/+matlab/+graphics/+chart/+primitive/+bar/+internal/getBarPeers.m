function peers = getBarPeers(hBar)
% Get all valid bar peers including given bar.  If no peers exist, return
% empty.

%   Copyright 2014-2015 The MathWorks, Inc.

allBars = hBar.BarPeers;
peers = flipud(allBars(isvalid(allBars)));