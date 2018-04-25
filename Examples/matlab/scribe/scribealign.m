function scribealign(h,aligntype,space)
%SCRIBEALIGN Align objects.
%   SCRIBEALIGN(H,ALIGN) aligns objects in handle vector H according to
%   the ALIGN:
%       'Left'   = Align left edges
%       'Center' = Align centers (X)
%       'Right'  = Align right edges
%       'Top'    = Align top edges
%       'Middle' = Align middles (Y)
%       'Bottom' = Align bottom edges
%       'VDistAdj' = Vertical distribution spaced between adjacent edges
%       'VDistTop' = Vertical distribution spaced from top to top
%       'VDistMid' = Vertical distribution spaced between middles
%       'VDistBot' = Vertical distribution spaced from bottom to bottom
%       'HDistAdj' = Horizontal distribution spaced between adjacent edges
%       'HDistLeft' = Horizontal distribution spaced from left edges
%       'HDistCent' = Horizontal distribution spaced at centers
%       'HDistRight' = Horizontal distribution spaced at right edges
%       'Smart' = Align and Distribute into closest grid%
%   SCRIBEALIGN(FIG,ALIGN) aligns selected objects (with 'position'
%   properties) in FIG according to align type.
%   SCRIBEALIGN(...,SPACE) uses specified pixel spacing when ALIGN
%   is one of the distribution types.
%
%   Examples:
%       r(1) = annotation('rectangle',[.1 .2 .4 .4]);
%       r(2) = annotation('rectangle',[.2 .3 .5 .3]);
%       scribealign(r,'Left');
%
%       % Now click on the Edit Plot button in the menu bar
%       % and select both rectangles.
%       scribealign(gcf,'Bottom');
%
%       scribealign(gcf,'VDistMid',20);
%
%   See also PLOTEDIT.

%   SCRIBEALIGN(FIG) start alignment GUI for figure FIG.
%   SCRIBEALIGN(CMD,PARAM) execute callback CMD from GUI.

%   Copyright 1984-2017 The MathWorks, Inc.

narginchk(1,inf);

if nargin==1 && ~ischar(h) && ishandle(h) && isequal(get(h,'type'),'figure')
    fig = h; 
    
 
    
    % START GUI
    if isappdata(0,'ScribeGUIS_Aligner')
        AlignFrame = getappdata(0,'ScribeGUIS_Aligner');
        javaMethodEDT('setVisible',AlignFrame,true);
        javaMethodEDT('requestFocus',AlignFrame);
        aligntogg = uigettool(fig,'Annotation.AlignDistribute');
        set(aligntogg,'state','off');
        
        addRootListener(isobject(fig),AlignFrame);    
        
        return;
    end

    % Throw error dialog if no java available
    err = javachk('swing');
    if ~isempty(err)
        errordlg(err.message);
        return;
    end

    AlignFrame = com.mathworks.mwswing.MJFrame(getString(message('MATLAB:scribealign:AlignDistributeToolTitle')));
    AlignPanel=com.mathworks.page.scribealign.ScribeAlignmentPanel;
    AlignFrame.getContentPane.add(AlignPanel);
    AlignFrame.setResizable(false);
    AlignFrame.pack;
    javaMethodEDT('show',AlignFrame);
    setappdata(0,'ScribeGUIS_Aligner',AlignFrame);
    start_listeners(AlignFrame,fig);
    aligntogg = uigettool(fig,'Annotation.AlignDistribute');
    set(aligntogg,'state','off');

    addRootListener(isobject(fig),AlignFrame); 
    
elseif ischar(h) && nargin>1
    % GUI FUNCTION:  SCRIBEALIGN(CMD,PARAM)
    switch h
        case 'doalign'
            % SCRIBEALIGN('doalign',[vop,vspace,hop,hspace])
            fig = get(0,'CurrentFigure');
            
            % Error out if there is no curretn figure target for the
            % alignment. A warning message will be dislayed by the java
            % caller.
            if isempty(fig)
                error(message('MATLAB:scribealign:InvalidTargetHandle'));
            end
            
            vals = aligntype;
            if length(vals)~=4
                error(message('MATLAB:scribealign:InvalidAlignmentInput'));
            end
            vop = vals(1);
            vspace = vals(2);
            hop = vals(3);
            hspace = vals(4);
            % do the vertical alignment
            if vspace <=0
                switch vop
                    case 0
                        %noop
                    case 4
                        scribealign(fig,'Top');
                    case 2
                        scribealign(fig,'Middle');
                    case 5
                        scribealign(fig,'Bottom');
                    case 7
                        scribealign(fig,'VDistAdj');
                    case 11
                        scribealign(fig,'VDistTop');
                    case 9
                        scribealign(fig,'VDistMid');
                    case 12
                        scribealign(fig,'VDistBot');
                    otherwise
                        error(message('MATLAB:scribealign:InvalidVerticalAlignment'));
                end
            else
                switch vop
                    case 0
                        %noop
                    case 4
                        scribealign(gcf,'Top',vspace);
                    case 2
                        scribealign(gcf,'Middle',vspace);
                    case 5
                        scribealign(gcf,'Bottom',vspace);
                    case 7
                        scribealign(gcf,'VDistAdj',vspace);
                    case 11
                        scribealign(gcf,'VDistTop',vspace);
                    case 9
                        scribealign(gcf,'VDistMid',vspace);
                    case 12
                        scribealign(gcf,'VDistBot',vspace);
                    otherwise
                        error(message('MATLAB:scribealign:InvalidVerticalAlignment'));
                end
            end
            if hspace <=0
                switch hop
                    case 0
                        %noop
                    case 1
                        scribealign(gcf,'Left');
                    case 2
                        scribealign(gcf,'Center');
                    case 3
                        scribealign(gcf,'Right');
                    case 7
                        scribealign(gcf,'HDistAdj');
                    case 8
                        scribealign(gcf,'HDistLeft');
                    case 9
                        scribealign(gcf,'HDistCent');
                    case 10
                        scribealign(gcf,'HDistRight');
                    otherwise
                        error(message('MATLAB:scribealign:InvalidHorizontalAlignment'));
                end
            else
                switch hop
                    case 0
                        %noop
                    case 1
                        scribealign(gcf,'Left',hspace);
                    case 2
                        scribealign(gcf,'Center',hspace);
                    case 3
                        scribealign(gcf,'Right',hspace);
                    case 7
                        scribealign(gcf,'HDistAdj',hspace);
                    case 8
                        scribealign(gcf,'HDistLeft',hspace);
                    case 9
                        scribealign(gcf,'HDistCent',hspace);
                    case 10
                        scribealign(gcf,'HDistRight',hspace);
                    otherwise
                        error(message('MATLAB:scribealign:InvalidHorizontalAlignment'));
                end
            end
    end

else % ALIGNMENT OPERATIONS
    narginchk(2,3);
    if nargin == 2, space = []; end

    if ~all(ishghandle(h))
        error(message('MATLAB:scribealign:InvalidTargetHandle'));
    end

    if ishghandle(h,'figure')
        fig = h;
        h = get_figure_selected_objects(fig);
    else
        fp = get_figure_parent(h);
        fig = fp(1);
        if ~all(repmat(fig,1,length(fp))==fp)
            error(message('MATLAB:scribealign:InvalidParent'));
        end
    end

    if isaligntype(aligntype)
        aligntype=lower(aligntype);
    elseif isdisttype(aligntype)
        disttype=lower(aligntype);
        aligntype = '';
    else
        error(message('MATLAB:scribealign:InvalidAlignType'));
    end

    if isempty(h) || length(h)==1
        return;
    end

    [halign,hunits,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center] = prepare_alignment(h);

    if ~isempty(aligntype)
        do_alignment(halign,hpos,top,bot,left,right,middle,center,aligntype);
    else
        if strcmpi(disttype,'smart')
            do_smartalign(halign,hpos,top);
        else
            do_distribution(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center,disttype,space);
        end
    end
    cleanup_alignment(halign,hunits);
end

%---------------------------------------------------------------%
function [halign,hunits,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,middle,center] = prepare_alignment(h)

top=[]; bot=[]; right=[]; left=[]; middle=[]; center=[];
tops=[]; mids=[]; bots=[]; lefts=[]; cents=[]; rights=[];
halign = [];
hunits = {};
hpos = {};
for k=1:length(h)
    [ok,u,p] = getalignobjectposition(h(k));
    if ok
        hunits{length(hunits)+1} = u;
        hpos{length(hpos)+1} = p;
        halign = [halign,double(h(k))];
        tops(length(halign)) = p(2) + p(4);
        bots(length(halign)) = p(2);
        mids(length(halign)) = (tops(length(halign)) + bots(length(halign)))/2;
        lefts(length(halign)) = p(1);
        rights(length(halign)) = p(1) + p(3);
        cents(length(halign)) = (lefts(length(halign)) + rights(length(halign)))/2;
        widths(length(halign)) = p(3);
        heights(length(halign)) = p(4);
        if isempty(top) || length(halign)==1 || top < (p(2) + p(4))
            top = p(2) + p(4);
        end
        if isempty(bot) || length(halign)==1 || bot > p(2)
            bot = p(2);
        end
        if isempty(left) || length(halign)==1 || left > p(1)
            left = p(1);
        end
        if isempty(right) || length(halign)==1 || right < (p(1) + p(3))
            right = p(1) + p(3);
        end
    end
end
middle = (top + bot)/2;
center = (left + right)/2;

%---------------------------------------------------------------%
function cleanup_alignment(h,u)

for k=1:length(u)
    set(handle(h(k)),'units',u{k});
end

%---------------------------------------------------------------%
function do_distribution(halign,hpos,tops,bots,lefts,rights,widths,heights,top,bot,left,right,~,~,disttype,space)

switch disttype

    case 'vdistadj'
        % sort by tops descending
        [~,ind] = sort(tops);
        ind = fliplr(ind);
        if isempty(space)
            availablespace = top - bot;
            objectspace = sum(heights);
            if objectspace > availablespace
                space = 0;
            else
                space = (availablespace - objectspace)/(length(halign)-1);
            end
        end
        yt = top;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yt - pos(4);
            yt = yt - (pos(4) + space);
            setalignobjectposition(ha,pos);
        end

    case 'vdisttop'
        % sort by tops descending
        [~,ind] = sort(tops);
        ind = fliplr(ind);
        if isempty(space)
            space = ((top - bot) - heights(ind(length(halign))))/(length(halign)-1);
        end
        yt = top;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yt - pos(4);
            yt = yt - space;
            setalignobjectposition(ha,pos);
        end

    case 'vdistmid'
        % sort by tops descending
        [tops,ind] = sort(tops);
        tops = fliplr(tops); ind = fliplr(ind);
        if isempty(space)
            h1 = heights(ind(length(halign)))/2;
            h2 = heights(ind(1))/2;
            space = ((top-bot)-(h1 + h2))/(length(halign)-1);
        end
        ymid = top - (heights(ind(1))/2);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = ymid - (pos(4)/2);
            ymid = ymid - space;
            setalignobjectposition(ha,pos);
        end

    case 'vdistbot'
        [bots,ind] = sort(bots);
        if isempty(space)
            space = (bots(length(bots))- bots(1))/(length(bots)-1);
        end
        yb = bots(1);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(2) = yb;
            yb = yb + space;
            setalignobjectposition(ha,pos);
        end

    case 'hdistadj'
        % sort by lefts ascending
        [~,ind] = sort(lefts);
        if isempty(space)
            availablespace = right - left;
            objectspace = sum(widths);
            if objectspace > availablespace
                space = 0;
            else
                space = (availablespace - objectspace)/(length(halign)-1);
            end
        end
        xl = left;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl;
            xl = xl + (pos(3) + space);
            setalignobjectposition(ha,pos);
        end

    case 'hdistleft'
        % sort by lefts ascending
        [~,ind] = sort(lefts);
        if isempty(space)
            space = ((right - left) - widths(ind(length(halign))))/(length(halign)-1);
        end
        xl = left;
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl;
            xl = xl + space;
            setalignobjectposition(ha,pos);
        end

    case 'hdistcent'
        % sort by tops descending
        [~,ind] = sort(lefts);
        if isempty(space)
            w1 = widths(ind(length(halign)))/2;
            w2 = widths(ind(1))/2;
            space = ((right - left)-(w1 + w2))/(length(halign)-1);
        end
        xmid = left + (widths(ind(1))/2);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xmid - (pos(3)/2);
            xmid = xmid + space;
            setalignobjectposition(ha,pos);
        end

    case 'hdistright'
        [rights,ind] = sort(rights);
        if isempty(space)
            space = (rights(length(rights))- rights(1))/(length(rights)-1);
        end
        xl = rights(1);
        for k=1:length(halign)
            ha = halign(ind(k)); %index from sorted list
            pos = hpos{ind(k)};
            pos(1) = xl - pos(3);
            xl = xl + space;
            setalignobjectposition(ha,pos);
        end
end

%---------------------------------------------------------------%
function do_alignment(halign,hpos,top,bot,left,right,middle,center,aligntype)

for k=1:length(halign)
    pos = hpos{k};
    switch aligntype
        case 'left'
            pos(1) = left;
        case 'center'
            pos(1) = center - pos(3)/2;
        case 'right'
            pos(1) = right - pos(3);
        case 'top'
            pos(2) = top - pos(4);
        case 'middle'
            pos(2) = middle - pos(4)/2;
        case 'bottom'
            pos(2) = bot;
    end
    setalignobjectposition(halign(k),pos);
end

%-------------------------------------------------------------%
function do_smartalign(halign,hpos,top)

used = zeros(1,length(halign));
rows = zeros(1,length(halign));cols = zeros(1,length(halign));
row = 1;
% loop, adding rows until all ar used;
while ~all(used)
    % get the top object
    gotone=0;
    for k=1:length(halign)
        if ~used(k)
            pos = hpos{k};
            if ~gotone || top < (pos(2) + pos(4))
                top = pos(2) + pos(4);  topi = k;
            end
            gotone=1;
        end
    end
    % find top left object
    % start with top
    ul = topi;
    pos = hpos{ul};
    moreleft=1; joinfrx=.4;
    while moreleft
        found=0;
        % look for one to the left
        for k=1:length(halign)
            if k~=ul && ~used(k)
                tpos = hpos{k};
                if tpos(1) < pos(1)
                    if tpos(2)>pos(2) || (tpos(2) + tpos(4)) > pos(2) + (joinfrx*pos(4))
                        found=1;
                        ul = k;
                        pos = tpos;
                    end
                end
            end
            if ~found
                moreleft=0;
            end
        end
    end
    rows(ul) = row;  cols(ul) = 1; used(ul) = 1;
    % get everything in the row
    rowxpos = pos(1);
    for k=1:length(halign)
        if ~used(k)
            tpos = hpos{k};
            if tpos(2)>pos(2) || (tpos(2) + tpos(4)) > pos(2) + (joinfrx*pos(4))
                rowxpos = [rowxpos,tpos(1)];
                rows(k)=row;  used(k)=1;
            end
        end
    end
    [~,rind] = sort(rowxpos);
    col = 2;
    for k=1:length(halign)
        if k~=ul
            if rows(k)==row
                cols(k) = rind(col); col = col + 1;
            end
        end
    end
    row = row + 1;
end
% find all in first row and align middle
alignset=[];
for k=1:length(halign)
    if rows(k)==1
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'middle')
end
% find all in last row and align middle
rlast = max(rows);
alignset=[];
for k=1:length(halign)
    if rows(k)==rlast
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'middle')
end
% find all in first col and align center
alignset=[];
for k=1:length(halign)
    if cols(k)==1
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'center')
end
% find all in last col and align center
clast = max(cols);
alignset=[];
for k=1:length(halign)
    if cols(k)==clast
        alignset = [alignset,halign(k)];
    end
end
if ~isempty(alignset)
    scribealign(alignset,'center')
end
% hdist adj each row
for r=1:rlast
    alignset=[];
    for k=1:length(halign)
        if rows(k)==r
            alignset = [alignset,halign(k)];
        end
    end
    if ~isempty(alignset)
        scribealign(alignset,'hdistcent')
    end
end
% vdist adj each col
for c=1:clast
    alignset=[];
    for k=1:length(halign)
        if cols(k)==c
            alignset = [alignset,halign(k)];
        end
    end
    if ~isempty(alignset)
        scribealign(alignset,'vdistmid');
    end
end

%------------------------------------------------------------%
function p=get_figure_parent(h)
p=[];
for k=1:length(h)
    if ~ishandle(h(k))
        error(message('MATLAB:scribealign:BadInputHandle'))
    end
    type='';
    ph = h(k);
    while ~strcmpi(type,'figure')
        ph = get(ph,'parent');
        if isempty(ph)
            error(message('MATLAB:scribealign:NoFigure'));
        end
        type = get(ph,'type');
    end
    p(k) = ph;
end

%------------------------------------------------------------%
function ok=isaligntype(s)

%       'Left'   = Align left edges
%       'Center' = Align centers (X)
%       'Right'  = Align right edges
%       'Top'    = Align top edges
%       'Middle' = Align middles (Y)
%       'Bottom' = Align bottom edges
ok = any(strcmpi(s,{'Left','Center','Right',...
    'Top','Middle','Bottom'}));

%-------------------------------------------------------------%
function ok=isdisttype(s)

%       'VDistAdj' = Vertical distribution spaced between adjacent edges
%       'VDistTop' = Vertical distribution spaced from top to top
%       'VDistMid' = Vertical distribution spaced between middles
%       'VDistBot' = Vertical distribution spaced from bottom to bottom
%       'HDistAdj' = Horizontal distribution spaced between adjacent edges
%       'HDistLeft' = Horizontal distribution spaced from left edges
%       'HDistCent' = Horizontal distribution spaced at centers
%       'HDistRight' = Horizontal distribution spaced at right edges
%       'Smart' = Smart distribution and alignment - pretty smart
ok = any(strcmpi(s,{'VDistAdj','VDistTop','VDistMid',...
    'VDistBot','HDistAdj','HDistLeft',...
    'HDistCent','HDistRight','Smart'}));

%-------------------------------------------------------------%
function h = get_figure_selected_objects(fig)

h = getselectobjects(fig);
% If nothing is selected, operate on everything movable by default
if isempty(h) || (isscalar(h) && ishghandle(h,'figure'))
    scribeax = handle(graph2dhelper('findScribeLayer',fig));
    if (isobject(scribeax) && isvalid(scribeax)) || ...
            (any(ishandle(scribeax)) && ~strcmpi(get(scribeax,'BeingDeleted'),'on'))
        shapes = findobj(scribeax,'-property','Position');
        ax = findobj(get(fig,'children'),'flat','-regexp','Type','.*axes');
        if ~isempty(ax)
            axNonData = true(1,length(ax));
            for k=length(ax):-1:1
                axNonData(k) = isappdata(ax(k),'NonDataObject');
            end
            ax(axNonData) = [];
        end
    end
    h = [shapes;ax];
end
%-------------------------------------------------------------%
function res = localCompareClass(handles,className)

res = arrayfun(@(h)(isa(handle(h),className)),double(handles));

%-------------------------------------------------------------%
function [ok,u,p] = getalignobjectposition(h)

u=[];p=zeros(1,4);ok=0;
fig = ancestor(h,'figure');

if ishghandle(h,'text')
    u = get(h,'Units');
    set(h,'Units','pixels');
    p = get(h,'Extent');
    % Since text object live inside an axes, we need to convert to get a
    % position relative to the figure.
    hAx = ancestor(h,'Axes');
    axPos = hgconvertunits(fig,get(hAx,'Position'),get(hAx,'Units'),'Pixels',fig);
    p(1:2) = p(1:2) + axPos(1:2);
    p(1) = p(1) - p(3)/2;
    ok=1;
elseif isprop(h,'Units')
    u = get(h,'Units');
    if isprop(h,'Position')
        p = get(h,'Position');
        p = hgconvertunits(fig,p,u,'Pixels',fig);
        ok=1;
    end
end

%-------------------------------------------------------------%
function setalignobjectposition(h,pos)

fig = ancestor(h,'figure');

if ishghandle(h,'text')
    hAx = ancestor(h,'axes');
    p = get(h,'Extent');
    axPos = hgconvertunits(fig,get(hAx,'Position'),get(hAx,'Units'),'Pixels',fig);
    pos(1:2) = pos(1:2) - axPos(1:2);
    pos(1) = pos(1) + p(3)/2;
    currPos = get(h,'Position');
    set(h,'Position',[pos(1) pos(2) currPos(3)]);
else
    u = get(h,'Units');
    pos = hgconvertunits(fig,pos,'Pixels',u,fig);
    set(h,'Position',pos);
end

%-------------------------------------------------------------%
% GUI MANAGEMENT
%-------------------------------------------------------------%
function start_listeners(gui,fig)

if ~isobject(fig)    
    cls = classhandle(handle(0));
    ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'),'PropertyPostSet', {@currentFigureChanged, gui, fig});
    set(ml.cfigchanged,'Enabled','on'); 
    setappdata(0,'ScribeAlignGUIMATLABListeners',ml);       
else   
    hRoot = handle(0);
    ml.cfigchanged = event.proplistener(hRoot,findprop(hRoot,'CurrentFigure'),'PostSet', @(obj,evd)(currentFigureChanged(obj,evd,gui, fig)));
    ml.cfigchanged.Enabled = true;  
    setappdata(hRoot,'ScribeAlignGUIMATLABListeners',ml);
end
%-------------------------------------------------------------%
function kill_listeners

% remove all listeners
if isappdata(0,'ScribeAlignGUIMATLABListeners')
    rmappdata(0,'ScribeAlignGUIMATLABListeners');
end
if isappdata(0,'FigureDestroyGUIMATLABListeners')
    rmappdata(0,'FigureDestroyGUIMATLABListeners');
end

fig = get(0,'CurrentFigure');
if isempty(fig)
    return;
end

%-------------------------------------------------------------%
function currentFigureChanged(~, ~, gui, oldfig)

fig = get(0,'CurrentFigure');
if isempty(fig) 
    % If there are no figures, close editor and kill listeners
    if isempty(findall(0,'type','figure'))
       gui.setVisible(false);
       kill_listeners;
    end
    % If the only remaining figure is HandleViible off then do nothing.
    % The alginment tool will warn when attempting to perform an alignment.
    return;
else
    if isequal(fig,oldfig) %if current figure is unchanged
        return;
    end
end

if ~isobject(oldfig)   
    cls = classhandle(handle(0));
    ml.cfigchanged = handle.listener(0, cls.findprop('CurrentFigure'),'PropertyPostSet', {@currentFigureChanged, gui, fig});
    set(ml.cfigchanged,'Enabled','on');
    setappdata(0,'ScribeAlignGUIMATLABListeners',ml);
else
    hRoot = handle(0);
    ml.cfigchanged = event.proplistener(hRoot,findprop(hRoot,'CurrentFigure'),'PostSet', @(obj,evd)(currentFigureChanged(obj,evd, gui, fig)));
    ml.cfigchanged.Enabled = true;
    setappdata(hRoot,'ScribeAlignGUIMATLABListeners',ml);
end

%-------------------------------------------------------------%
function figureDestroyed(gui)

nfigs=length(findall(0,'type','figure'));
if nfigs<=1
    gui.setVisible(false);
    kill_listeners;
end

%-------------------------------------------------------------%

function addRootListener(objectGraphics,AlignFrame)

if objectGraphics
    setappdata(groot,'FigureDestroyGUIMATLABListeners',event.listener(groot,'ObjectChildRemoved',@(obj,evd) figureDestroyed(AlignFrame)));   
else
    setappdata(0,'FigureDestroyGUIMATLABListeners',handle.listener(handle(0),'ObjectChildRemoved',@(obj,evd) figureDestroyed(AlignFrame)));
end 
