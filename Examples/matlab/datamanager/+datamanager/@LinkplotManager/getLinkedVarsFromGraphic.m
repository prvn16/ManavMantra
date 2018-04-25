function [linkedVarList,linkedGraphics] = getLinkedVarsFromGraphic(h,gObjContainer,mfile,fcnname,...
    keepEmpty)

% keepEmpty determines whether variables with no data brushed is returned,
% defaults to not returned
if nargin < 5
    keepEmpty = false;
end

% Get a list of linked variables and their brushing arrays from this
% graphic. Include only those variables which have been brushed.

linkedVarList = {};
linkedGraphics = [];
if isempty(h.Figures)
    return
end

% Find linked graphics which belong to this ancestor
fig = handle(ancestor(gObjContainer,'figure'));
I = find([h.Figures.('Figure')]==fig);
if isempty(I)
    return
end
figStruct = h.Figures(I(1));
if strcmp(get(gObjContainer,'type'),'figure')
    linkedGraphics = figStruct.LinkedGraphics;
    I = 1:length(figStruct.LinkedGraphics);
else 
    % If the container is an axes from a plotyy then add its peer.
    if strcmp(get(gObjContainer,'type'),'axes') && isappdata(gObjContainer,'graphicsPlotyyPeer') && ...
            ishghandle(getappdata(gObjContainer,'graphicsPlotyyPeer'))
        gObjContainer = [gObjContainer(:)',getappdata(gObjContainer,'graphicsPlotyyPeer')];
    end
    [linkedGraphics,I] = intersect(handle(figStruct.LinkedGraphics),...
        handle(findobj(gObjContainer)));
    if isempty(linkedGraphics)
        return
    end
end

% Remove variables with no brushing
brushMgr = datamanager.BrushManager.getInstance();
linkedVarList = cell(length(I),3);
Ilinked = false(length(I),1);
for k=1:length(I)
    for j=1:3
        locVarName = figStruct.VarNames{I(k),j};
        if ~isempty(locVarName)          
           ind = brushMgr.getBrushingProp(locVarName,mfile,fcnname,'I');
           if ~isempty(ind)
               Ilinked(k) = true;
               if keepEmpty || any(ind(:))
                   linkedVarList{k,j} = locVarName;
               end
           end
        end
    end
end

linkedVarList = linkedVarList(:);
linkedVarList = unique(linkedVarList(~cellfun('isempty',linkedVarList)));
linkedGraphics(~Ilinked) = [];
    
