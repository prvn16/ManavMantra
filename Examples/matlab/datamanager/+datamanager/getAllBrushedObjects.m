function selected_sibs = getAllBrushedObjects(gobj)

% Copyright 2008-2015 The MathWorks, Inc.

% Get all the objects in the graphic container which have been brushed.
% Be sure to include the peer axes for any plotyy axes.

selected_sibs = findobj(gobj,'-property','type','-function',...
    @(x) isprop(x,'BrushData') && ~isempty(get(x,'BrushData')) && any(x.BrushData(:)>0));
if isappdata(gobj,'graphicsPlotyyPeer')
    selected_yysibs = findobj(getappdata(gobj,'graphicsPlotyyPeer'),'-function',...
       @(x) isprop(x,'BrushData') && ~isempty(get(x,'BrushData')) && any(x.BrushData(:)>0));
    selected_sibs = [selected_sibs(:);selected_yysibs(:)]';
end
 
% Check for objects brushed using behavior objects
custom = findobj(gobj.Parent,'HandleVis','on','-not',{'Behavior',struct},'-function',...
    @localHasBrushBehavior,'HandleVis','on');
if isempty(custom)
    return
end

% Add objects brushed by enabled behavior objects
Iinclude = false(length(custom),1);
for k=1:length(custom)
    
    % for historgram like objects (histogram, histogram2 and
    % categoricalhistogram) it is not enough to look at the behavior object
    % only, since the object must be linked in order to be brushed. 
    % Therefore, look at the BrushValues property and if it has a non
    % zero value, then include it.
    if isprop(custom(k),'BrushValues') && (isempty(custom(k).BrushValues) || ~any(custom(k).BrushValues(:)))
        continue
    end
    
    bh = hggetbehavior(custom(k),'Brush');
    Iinclude(k) =  bh.Enable;
    
end 
selected_sibs = [selected_sibs(:); custom(Iinclude)];


function state = localHasBrushBehavior(h)

state = ~isempty(hggetbehavior(h,'Brush','-peek'));

