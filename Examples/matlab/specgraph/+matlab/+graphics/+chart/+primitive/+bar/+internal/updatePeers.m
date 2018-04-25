function updatePeers(obj,evd)
% Given a property change, update the same property on the peers of the
% Bar object. A peer is defined to be all Bar objects sharing a parent with the
% affected object.

%   Copyright 2014-2015 The MathWorks, Inc.

hBar = evd.AffectedObject;
hPeers = matlab.graphics.chart.primitive.bar.internal.getBarPeers(hBar);
hPars = get(hPeers,'Parent');
if ~iscell(hPars)
    % We only have the one bar, short-circuit
    return;
end
% Remove the object from the list of peers as well:
hPeers(hPeers == hBar) = [];
% Set the internal property that was changed on the bar:
for i=1:numel(hPeers)
    set(hPeers(i),[obj.Name '_I'],get(hBar,obj.Name));
end