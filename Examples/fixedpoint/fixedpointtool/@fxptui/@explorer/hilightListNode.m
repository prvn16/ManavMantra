function hilightListNode(h, listNode, rgbVector)
% HILIGHTLISTNODE Highlights the specified list node with the color
% specified as a RGB vector

% if ~isa(listNode, 'DAStudio.DAObjectProxy')
%     resultObj = h.getUDDListNodeFromME(listNode);
% else
%     resultObj = listNode;
% end
% if isempty(resultObj); return; end
h.highlight(listNode, rgbVector);
