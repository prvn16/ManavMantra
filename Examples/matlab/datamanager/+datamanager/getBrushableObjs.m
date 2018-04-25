function objs = getBrushableObjs(f)

% Obtain all the hg series as datamanager series objects together with
% their x,yDataSources for children of f

% Copyright 2008-2015 The MathWorks, Inc.

host = f;
dataAnnotatables = findobj(f,'-function',@(x)(isa(x,'matlab.graphics.chart.interaction.DataAnnotatable')),'HandleVisibility','on',...
    'Visible','on');

custom = findobj(host,'-property','type','-and','HandleVis','on','-not',{'Behavior',struct},'-function',...
    @localHasBrushBehavior,'HandleVis','on');

if isempty(custom)
    objs = dataAnnotatables(:);
    return
end
Iinclude = false(length(custom),1);
for k=1:length(custom)
    bh = hggetbehavior(custom(k),'Brush');
    Iinclude(k) =  bh.Enable;
end 
objs = setdiff([dataAnnotatables;...
                custom(Iinclude)],custom(~Iinclude));


function state = localHasBrushBehavior(h)

state = ~isempty(hggetbehavior(h,'Brush','-peek'));
