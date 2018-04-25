function ch=get_legendable_children(ax)
%GET_LEGENDABLE_CHILDREN Gets the children for a legend
%  CH=GET_LEGENDABLE_CHILDREN(AX,INCLUDE_IMAGES) returns the
%  legendable children for axes AX. If INCLUDE_IMAGES is true then
%  include images in the list of legendable children.
%
% Copyright 2004-2016 The MathWorks, Inc.

legkids = allchild(ax);

% Take plotyy axes into account:
if isplotyyaxes(ax)
    newAx = getappdata(ax,'graphicsPlotyyPeer');
    newChil = get(newAx,'Children');
    % The children of the axes of interest (passed in) should
    % appear lower in the stack than those of its plotyy peer.
    % The child stack gets flipud at the end of this function in
    % order to return a list in creation order.
    if ~isempty(newChil)
        legkids = [newChil(:); legkids(:)];
    else
        legkids = legkids(:);
    end            

end

if isempty(legkids)
    ch = matlab.graphics.primitive.Data.empty;
    return
end

% exclude non-legendable objects
legkids = legkids(islegendable(legkids));

% support for hggroup
legkids = expandLegendChildren(legkids);

% We need to return a list of legendable children in creation order, but
% the axes 'Children' property returns a stack (reverse creation order).
% So we flip it.
ch = flipud(legkids);
