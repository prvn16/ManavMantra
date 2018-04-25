function insertBars(ax, bars, pastedBars, pastedBarChildPos)
% This function is undocumented and may change in a future release.

%  Copyright 2013-2014 The MathWorks, Inc.

% If the pasted object(s) comprise(s) one or more bars then increment
% the NumPeers count of all bars with the same BarPeerID. This will
% cause the affected groups of bars to layout correctly to accommodate
% the pasted bar(s).

% Insert pasted bars with barPeerIDs(kk) into their relative 
% positions (captured in the BarChildPos property when they were 
% serialized)
unpastedBars = setdiff(bars(:),pastedBars(:),'stable');
allSibBars = [pastedBars(:);unpastedBars(:)];
if any(pastedBarChildPos>length(allSibBars))
    % If any of the pastedBarChildPos lie beyond the total numbers of 
    % bars we are pasting into a new figure or axes. In this case just 
    % paste the new bars into the initial positions
    % Just revert to the initial positions
    pastedBarChildPos = 1:length(pastedBarChildPos);
end
allSibBars(pastedBarChildPos) = pastedBars(:);
unpastedChildPos = setdiff(1:(length(allSibBars)),pastedBarChildPos,'stable');
allSibBars(unpastedChildPos) = unpastedBars(:);
set(allSibBars,'NumPeers',length(allSibBars));

% Reorder all the bars with this BarPeerID with the pasted 
% bars in their serialized child positions.
 
% Create an array of axes children where the pasted parts are positioned
% right after the un-pasted bars. This ensures that the pasted bars are in a
% contiguous block of axes children with the existing un-pasted bars
axChild = ax.Children;
if ~isempty(unpastedBars)
   axChild(ismember(axChild,pastedBars)) = [];
   I = find(ismember(axChild,unpastedBars),1,'last');
   axChild = [axChild(1:I); pastedBars; axChild(I+1:end)]; % All bars are now in a contiguous block of child indices
end
% Re-order the bars in the array of axes children so that the bars are in 
% the correct order
childInd = ismember(axChild,allSibBars);
axChild(childInd) = allSibBars;
ax.Children = axChild;



    
