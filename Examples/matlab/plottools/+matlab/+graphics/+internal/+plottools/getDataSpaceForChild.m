function [ hDataSpace, hContainer ] = getDataSpaceForChild( child )
%This is an undocumented function and may be removed in future.

% getDataSpaceForChild returns the dataspace and the childCotainer that a child is
% associated with


ax = ancestor(child,'axes','node');
hContainer = [];

% Undocumentnted third argument 'node' - uses mcos tree instead of Parent
% property
hDataSpace = ancestor(child,'matlab.graphics.axis.dataspace.DataSpace','node');

if isempty(ax) || ~ishghandle(ax,'axes') || ~isa(ax,'matlab.graphics.axis.Axes') || isempty(ax.TargetManager)
    return
end

% There is no similar way to ask for a ChildContainer, because when clipping
% is off it is not a recognizable ChildContainer class. Therefore
% we have to loop thorugh the children and detect the correct one. 
for i = 1:length(ax.TargetManager.Children)
    if any(hDataSpace == ax.TargetManager.Children(i).DataSpace)
        hContainer = ax.TargetManager.Children(i).ChildContainer;
        break;
    end
end

end
