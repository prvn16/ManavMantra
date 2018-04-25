function uddNode = getUDDListNodeFromME(this, mcosListNode)
% GETUDDLISTNODEFROMME Gets the UDD node from the model explorer list node
% that wraps the MCOS result

% Copyright 2013 MathWorks, Inc

uddNode = [];
uddListNodes = this.imme.getVisibleListNodes;
for i = 1:length(uddListNodes)
    mcosObj = uddListNodes(i).getMCOSObjectReference;
    if isequal(mcosObj, mcosListNode)
        uddNode = uddListNodes(i);
        return;
    end
end
