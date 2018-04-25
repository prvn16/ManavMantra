function varargout = colormapeditor(obj, varargin)
%COLORMAPEDITOR starts colormap editor ui
%
%   When started the colormap editor displays the current figure's colormap
%   as a strip of rectangluar cells. Nodes, displayed as rectangles(end
%   nodes) or carrots below the strip, separate regions of uniform slope in
%   R,G and B.   The grays colormap, for example, has only two nodes since
%   R,G and B increase at a constant slope from the first to last index in
%   the map. Most of the other standard colormaps have additional nodes where
%   the slopes of the R,G or B curves change.
% 
%   As the mouse is moved over the color cells the colormap index, CData
%   value r,g,b and h,s,v values for that cell are displayed in the Current
%   Color Info box of the gui.
%
%   To add a node: 
%       Click below the cell where you wish to add the node
%
%   To delete a node:
%       Select the node by clicking on it and hit the Delete key or
%       Edit->Delete, or Ctrl-X
%
%   To move a node:
%       Click and drag or select and use left and right arrow keys.
%
%   To change a node's color:
%       Double click or click to select and Edit->Set Node Color. If multiple
%       nodes are selected the color change will apply to the last node
%       selected (current node).
%
%   To select this node, that node and all nodes between:
%       Click on this node, then Shift-Click on that node.
%
%   To select this, that and the other node:
%       Click on this, Ctrl-Click on that and the other.
%
%   To move multiple nodes at once: 
%       Select multiple nodes then use left and right arrow keys to move them
%       all at once.  Movement will stop when one of the selected nodes bumps
%       into an unselected node or end node. 
%
%   To delete multiple nodes:
%       Select the nodes and hit the Delete key, or Edit->Delete, or Ctrl-X.
%
%   To avoid flashing while editing the colormap set the figures DoubleBuffer
%   property to 'on'.
%
%   The "Interpolating Colorspace" selection determines what colorspace is
%   used to calculate the color of cells between nodes.  Initially this is
%   set to RGB, meaning that the R,G and B values of cells between nodes are
%   linearly interpolated between the R,G and B values of the nodes. Changing
%   the interpolating colorspace to HSV causes the cells between nodes to be
%   re-calculated by interpolating their H,S and V values from  the H,S and V
%   values of the nodes.  This usually produces very different results.
%   Because Hue is conceptually mapped about a color circle, the
%   interpolation between Hue values could be ambiguous.  To minimize
%   ambiguity the shortest distance around the circle is used.  For example,
%   if two  nodes have Hues of 2(slightly orange red) and 356 (slightly
%   magenta red), the cells between them would not have hues 3,4,5 ....
%   353,354,355  (orange/red-yellow-green-cyan-blue-magenta/red) but 357,
%   358, 1, 2  (orange/red-red-magenta/red).
%
%   The "Color Data Min" and "Color Data Max" editable text areas contain 
%   the values that correspond to the current axes "Clim" property.  These
%   values may be set here and are useful for selecting a range of data
%   values to which the colormap will map.  For example, your CData values
%   might range from 0 to 100, but the range of interest may be between 40 
%   and 60.  Using Color Data Min and Max (or the Axes Clim property) the
%   full variation of the colormap can be placed between the values 40 and 60
%   to improve visual/color resolution in that range.   Color Data Min
%   corresponds to Clim(0) and is the CData value to which the first Colormap
%   index is mapped.  All CData Values below this will display in the same
%   color as the first index.  Color Data Max corresponds to Clim(1) and is
%   the CData value to which the last Colormap index is mapped.  All CData 
%   values greater than this will display the same color as the last index.
%   Setting Color Data Min and Max (or Clim) will only affect the display of
%   objects (Surfaces, Patches, Images) who's CDataMapping Property is set to
%   'Scaled'.  e.g.  imagesc(im) but not image(im).
%
%   Immediate Apply is checked by default, and applies changes as they are
%   made.  If Immediate Apply is unselected, changes in the colormap editor
%   will not be applied until the apply or OK button is selected, and any
%   changes made will be lost if the Cancel button is selected.
%
%   See also COLORMAP


%   G. DeLoid 03/04/2002
%
%   Copyright 1984-2013 The MathWorks, Inc.

error(javachk('mwt', getString(message('MATLAB:uistring:colormapeditor:TheColormapEditor'))));

import com.mathworks.page.cmapeditor.*;
varargout = {};

% look for figure input
if nargin
    % Check to see if the conversion is specified
    if nargin>1
        if obj == MLQue.RGB_TO_HSV
            [varargout{1}] = ...
                RGBtoHSB(varargin{1});
        elseif obj == MLQue.HSV_TO_RGB
            [varargout{1}] = ...
                HSBtoRGB(varargin{1});
        end
        return;
    end
    
    % colormapeditor([]) should do nothing
    if isempty(obj)
        return
    end
    
    if nargin == 1
        if isa(obj,'matlab.graphics.chart.Chart')
            error(message('MATLAB:colormapeditor:UnsupportedObject', obj.Type));
        end
        if ~any(ishandle_valid(obj)) || (~isgraphics(obj,'figure') && ~isgraphics(obj,'axes') && ~isgraphics(obj,'polaraxes'))
            error(message('MATLAB:colormapeditor:InvalidFigureHandle'));
        end
    end
else
    obj = [];
end

% get figure if not provided or if HandleVisibility is off
if isempty(obj) ||...
   ~strcmpi(get(obj, 'HandleVisibility'),'on') ||... % Colormap editor does not support handle visibility off
   ~strcmpi(get(ancestor(obj,'figure'), 'HandleVisibility'),'on') % Colormap editor does not support handle visibility off
    obj = get(0,'CurrentFigure');
    if isempty(obj) || ~strcmpi(get(obj, 'HandleVisibility'),'on') % g1038597
        obj = gcf;
    end
    axObj = get(obj,'CurrentAxes');
    if ~isempty(axObj)
        obj = axObj;
    end
end

% make sure the colormap is valid
check_colormap(colormap(obj))

% reuse the only one if it's there
cme = get_cmapeditor();
if ~isempty(cme)
    cme.bringToFront;
    cme.setVisible;
    return;
end

% start colormapeditor and make it the only one
com.mathworks.page.cmapeditor.CMEditFrame.sendJavaWindowFocusEventsToMatlab(true);
cme = CMEditor;
set_cmapeditor(cme);

cme.init;
   
% attach the matlab callback interface so we get notified of updates
cb = handle(cme.getMatlabQue.getCallback,'callbackproperties');
set(cb,'delayedCallback',@handle_callback)

if ishghandle(handle(obj),'figure')
    ax = get(obj,'CurrentAxes');
    fig = handle(obj);
elseif ishghandle(handle(obj),'axes')
    ax = obj;
    fig = handle(ancestor(obj,'figure'));
else
    fig = handle(gcf);
    ax = get(fig,'CurrentAxes');
end

if ~isprop(ax,'clim')
    ax = [];
end
set_current_object(obj);
cme.setFigure(java(fig));
start_listeners(fig, ax);

% all set, show it now
cme.setVisible;
update_colormap(colormap(obj));

%----------------------------------------------------------------------%
% FUNCTIONS CALLED BY FROM JAVA EDITOR
%----------------------------------------------------------------------%
function handle_callback(callback_source, eventData) %#ok<INUSL>
% callback_source is not used
cme = get_cmapeditor();
cme_ = eventData.getEditor;
if isempty(cme) || (~isempty(cme_) && cme_.isDisposed)
    % This error was put in to catch the scenario where a callback for the cmeditor
    % is gone before a callback is handled. Since the cmeditor goes away in response
    % to a matlab event from the figure and these callbacks are coming from JAVA, there
    % is no guarantee on the order of these events. Therefore, don't error, just igonre.
    %    error('MATLAB:colormapeditor:CmeditorExpected', 'expected cmeditor to still be there')
    return;
end

if eventData.getOperation()==MLQue.CURRENT_FIGURE_UPDATE
    cme = eventData.getEditor;
end
fig = handle(cme.getFigure); % Remove java wrapper

funcode    = eventData.getOperation();
args       = eventData.getArguments();
resultSize = eventData.getResultSize;
source     = eventData.getSource;

if ~isequal(cme,cme_)
    error(message('MATLAB:colormapeditor:ExpectedCmeditor'))
end

import com.mathworks.page.cmapeditor.MLQue

switch(funcode)
 case MLQue.CMAP_UPDATE
  cmap_update(fig,args);
 case MLQue.CLIM_UPDATE
  clim_update(fig,args);
 case MLQue.CMAP_STD
  source.finished(funcode, stdcmap(args, resultSize), cme);
 case MLQue.CMAP_EDITOR_OFF
  kill_listeners(fig);
 case MLQue.CHOOSE_COLOR
  source.finished(funcode, choosecolor(args), cme);
 case MLQue.CURRENT_FIGURE_UPDATE
  oldfig = handle(eventData.getEditor.getFigure);
  drawnow
  fig = get(0,'CurrentFigure');
  if isempty(fig) || ~strcmpi(get(fig, 'HandleVisibility'),'on') % g1038597
      fig = oldfig;
  end
  if ~isequal(oldfig,fig)
      oldax = [];
      if ~isempty(oldfig) && ishghandle(oldfig)
          oldax = get(oldfig,'CurrentAxes');
      end
      set_current_object(fig);
      set_current_figure(fig,oldfig,oldax);
  end
  % Addtional options added to the tools menu
 case MLQue.RESET_CURRENT_AXES
     obj = get_current_object();
     if ishghandle(obj,'axes')         
        obj.ColorSpace.ColormapMode = 'auto';
        update_colormap(colormap(obj)); 
     end
 case MLQue.RESET_ALL_AXES
     f = get(0, 'CurrentFigure');
     ax = findall(f,'type','axes');
     for i = 1:length(ax)
         ax(i).ColorSpace.ColormapMode = 'auto';
     end
     update_colormap(colormap(f));  
end

%----------------------------------------------------------------------%
function cmap_update(fig,map)

%df ~ishandle_valid(fig)
if ~any(ishandle_valid(fig))
    return;
end

cmap_listen_enable(fig,'off');
obj = get_current_object();
colormap(obj, map);
% Need this so that the MarkedClean happens while the listeners are off, otherwise we end up in an infinite loop between MATLAB and Java
drawnow;
cmap_listen_enable(fig,'on');

%----------------------------------------------------------------------%
function clim_update(fig,lims)

%df ~ishandle_valid(fig)
if ~any(ishandle_valid(fig))
    return;
end
ax = get(fig,'CurrentAxes');
%df ~ishandle_valid(ax)
if ~any(ishandle_valid(ax)) || any(~isprop(ax,'clim'))
    return;
end

cmap_listen_enable(fig,'off');
set(ax,'clim',lims);
drawnow update
cmap_listen_enable(fig,'on');

%----------------------------------------------------------------------%
function map=choosecolor(vals)

r = vals(1);
g = vals(2);
b = vals(3);
map=uisetcolor([r,g,b],getString(message('MATLAB:uistring:colormapeditor:SelectMarkerColor')));

%----------------------------------------------------------------------%
function map=stdcmap(maptype, mapsize)

import com.mathworks.page.cmapeditor.MLQue

switch maptype
 case MLQue.AUTUMN
  map = autumn(mapsize);
 case MLQue.BONE
  map = bone(mapsize);
 case MLQue.COLORCUBE
  map = colorcube(mapsize);
 case MLQue.COOL
  map = cool(mapsize);
 case MLQue.COPPER
  map = copper(mapsize);
 case MLQue.FLAG
  map = flag(mapsize);
 case MLQue.GRAY
  map = gray(mapsize);
 case MLQue.HOT
  map = hot(mapsize);
 case MLQue.HSV
  map = hsv(mapsize);
 case MLQue.JET
  map = jet(mapsize);
 case MLQue.LINES
  map = lines(mapsize);
 case MLQue.PINK
  map = pink(mapsize);
 case MLQue.PRISM
  map = prism(mapsize);
 case MLQue.SPRING
  map = spring(mapsize);
 case MLQue.SUMMER
  map = summer(mapsize);
 case MLQue.WHITE
  map = white(mapsize);
 case MLQue.WINTER
  map = winter(mapsize);
 case MLQue.PARULA
  map = parula(mapsize);
end

%----------------------------------------------------------------------%
% function cmeditor_off(fig)
% destroy any remaining listeners and remove the only one


%----------------------------------------------------------------------%
%   MATLAB listener callbacks
%----------------------------------------------------------------------%
function currentFigureChanged(hProp, eventData, oldfig, oldax) %#ok<INUSL>
fig = get(0, 'CurrentFigure');
if isempty(fig) || handle(fig)==handle(oldfig) ||  ~strcmpi(get(fig, 'HandleVisibility'),'on') % g1038597
    % Nothing to do here, since it's the same figure or the current figure
    % has handle visiblity off
    return;
end
set_current_object(fig);
set_current_figure(fig,oldfig,oldax);

%----------------------------------------------------------------------%
%   Figure listener callbacks
%----------------------------------------------------------------------%
function cmapChanged(~, ~, obj)

% hProp is not used
try
    update_colormap(colormap(obj));
    
    % The CLim may not have been set in the initialization and a PostSet
    % may not fire so we need to update the clim too if the ColorSpace is
    % updated g1079308
    if ishghandle(obj,'axes')
        climChanged([],[],obj);
    end
catch err
    warning(err.identifier,'%s',err.message);
end

%----------------------------------------------------------------------%
function currentAxesChanged(hProp, eventData, oldfig, oldax) %#ok<INUSL>

ax = get(eventData.AffectedObject,'CurrentAxes');

if isempty(ax) || ~isvalid(ax)
    return;
end

set_current_axes(ax,oldfig,oldax);
set_current_object(ax);
% Calling drawnow to make colormap of axes get set to default values
% If we don't do this an initialization can happen afterwards making the
% UI flash from one colormap to another.  This is because the original
% colormap is Jet but changed to parula for the new handle graphics.
drawnow;
obj = get_current_object();
if ~ishandle_valid(obj)
    return;
end
cmap = colormap(obj);
update_colormap(cmap);

%-----------------------------------------------------------------------%
function updateTitle(~,~)
    
cme = get_cmapeditor();
if isempty(cme)
    return
end
set_cme_title(cme);

%------------------------------------------------------------------------%
function handle_mouse_released(~,~,~,~)
    
obj = get_current_matlab_object();
set_current_object(obj);
cme = get_cmapeditor();
if ~isempty(cme)
    if ishghandle(obj,'figure')
        update_colormap(colormap(obj));
        enableResetAxes(cme,false);
    elseif ishghandle(obj,'axes')
        update_colormap(colormap(obj));
        enableResetAxes(cme,true);
    end
end

%-----------------------------------------------------------------------%
function figureDestroyed(hProp,eventData,oldfig,oldax) %#ok<INUSL>

allFigs = findobj(0,'type','figure','handlevisibility','on');
nfigs = length(allFigs);
% We need to check that get_cmapeditor is not empty here because when
% the test point tcolormapeditor lvlTwo_Listeners is run,
% the call to close all closes the figure
% linked to the ColorMapEditor after the unlinked figure, so nfigs==1 %
% then this callback fires. In this case kill_listeners expects 
% that a getappdata(0,'CMEditor') is not empty, which it normally would not
% be but in the testpoint appdata(0,'CMEditor') was cleared.
cme = get_cmapeditor();
if ~isempty(cme)
    cme.removeObject(eventData.Source);
end
if nfigs<=1 && ~isempty(get_cmapeditor)% the one being destroyed
    destroy_matlab_listeners;
    destroy_figure_listeners(oldfig);
    destroy_axes_listeners(oldax);
    kill_listeners(oldfig);
else
    fig = get(0,'CurrentFigure');
    fig = handle(fig);
    %if fig is the figure currently being destroyed, we need to get the figure
    %that is previously being referred to
    if (fig == eventData.Source)
        for i = 1:length(allFigs)
            if allFigs(i) ~= eventData.Source
                fig = handle(allFigs(i));
                break;
            end
        end
    end
    %---------------------------------------------------------------------
    set_current_object(fig);
    set_current_figure(fig,oldfig,oldax);
end

%----------------------------------------------------------------------%
%   Axes Listener Callbacks
%----------------------------------------------------------------------%
function climChanged(hProp, eventData, ax) %#ok<INUSL>

cme = get_cmapeditor();
if isempty(cme)
    return
end
clim = get(ax,'Clim');
cme.getModel.setColorLimits(clim,0);

%----------------------------------------------------------------------%
function axesDestroyed(hProp, eventData, oldfig, oldax) %#ok<INUSL>

cme = get_cmapeditor();
if isempty(cme)
    return;
end
cme.removeObject(eventData.Source);

fig = handle(cme.getFigure); % Remove java wrapper
if ~any(ishandle_valid(fig))
    return;
end
ax = get(fig,'currentaxes');
if ~ishandle_valid(ax)
    set_current_object(fig);
else
    set_current_object(ax);
end
set_current_axes(ax,oldfig,oldax);
update_colormap(colormap(fig));

%------------------------------------------------------------------------%
function handleAxesReset(~,~,ax)

al = getappdata(ax,'CMEditAxListeners');
ax.Title;
drawnow;
delete(al.titleSet);
al.titleSet = event.listener(ax.Title,'MarkedClean', ...
                                   @(es,ed) updateTitle(es,ed));
setappdata(ax,'CMEditAxListeners',al);

%----------------------------------------------------------------------%
%   Helpers
%----------------------------------------------------------------------%
function set_current_figure(fig,oldfig,oldax)

if ~any(ishandle_valid(fig)) || isequal(fig,oldfig) ||...
        ~strcmpi(get(fig, 'HandleVisibility'),'on') % g1038597
    return;
end

if strncmpi (get(handle(fig),'Tag'), 'Msgbox', 6) || ...
    strcmpi (get(handle(fig),'Tag'), 'Exit') || ...
    strcmpi (get(handle(fig),'WindowStyle'), 'Modal')
    return;
end

cme = get_cmapeditor();
if isempty(cme)
    return;
end

ax = get(fig,'CurrentAxes');
if ~isprop(ax,'clim')
    ax = [];
end
% get rid of old figure listeners
destroy_figure_listeners(oldfig);
% get rid of old axes listeners
destroy_axes_listeners(oldax);
cme.setFigure (java(handle(fig)));
create_matlab_listeners(fig,ax);
create_figure_listeners(fig,ax);
handle_axes_change(fig,ax,true);
%------update colormap when figure deleted-------
update_colormap(colormap(fig));

%----------------------------------------------------------------------%
function set_current_axes(ax,oldfig,oldax)

if ~any(ishandle_valid(ax)) || isequal(ax,oldax) || ~isprop(ax,'clim')
    return;
end

fig = ancestor(ax,'figure');

% get rid of old axes listeners
destroy_axes_listeners(oldax);

% if the new axes is invalid, get out now
if ~any(ishandle_valid(ax))
    kill_listeners(oldfig);
    return;
end

create_matlab_listeners(fig,ax);
create_figure_listeners(fig,ax);
handle_axes_change(fig, ax, true);


%----------------------------------------------------------------------%
function cmap_listen_enable(fig,onoff)

% figure listeners
if ~any(ishandle_valid(fig))
    return;
end

% just cmap
if isappdata(fig,'CMEditFigListeners')
    fl = getappdata(fig,'CMEditFigListeners');
    if isobject(fl.cmapchanged)
        fl.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.cmapchanged,'Enabled',onoff);
    end
    setappdata(fig,'CMEditFigListeners',fl);
end

% axes listeners
ax = get(fig,'CurrentAxes');
if any(ishandle_valid(ax,'CMEditAxListeners'))
    al = getappdata(ax,'CMEditAxListeners');
    if isobject(al.climchanged)
        al.climchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.climchanged,'Enabled',onoff);
    end
    if isobject(al.cmapchanged)
        al.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.cmapchanged,'Enabled',onoff);
    end
    setappdata(ax,'CMEditAxListeners',al);
end


%----------------------------------------------------------------------%
function start_listeners(fig,ax)

create_matlab_listeners(fig,ax);
create_figure_listeners(fig,ax);
handle_axes_change(fig,ax,true);

%----------------------------------------------------------------------%
function kill_listeners(fig)

% make sure the colormap editor is gone
cme = get_cmapeditor();
if isempty(cme)
    error(message('MATLAB:colormapeditor:ColormapeditorAppdataExpected'))
end
cme.close;

% we need to kill these now, otherwise we'll leak the listeners and
% they will continue to fire after this colormap editor is gone
destroy_matlab_listeners

if any(ishandle_valid(fig))
    destroy_figure_listeners(fig);

    % axes
    ax = get(fig,'CurrentAxes');

    % return if no current axes or it is being destroyed
    if any(ishandle_valid(ax))
        destroy_axes_listeners(ax);
    end
end

% now flush out the cmap editor handle
rm_cmapeditor();

%----------------------------------------------------------------------%
function create_matlab_listeners(fig,ax)

rt = handle(0);
ml.cfigchanged = event.proplistener(rt,rt.findprop('CurrentFigure'), ...
    'PostSet',@(es,ed) currentFigureChanged(es,ed,fig,ax));
setappdata(0,'CMEditMATLABListeners',ml);

%----------------------------------------------------------------------%
function destroy_matlab_listeners

if isappdata(0,'CMEditMATLABListeners')
    % we actually need to delete these handles or they
    % will continue to fire
    ld = getappdata(0,'CMEditMATLABListeners');
    fn = fields(ld);
    for i = 1:length(fn)
        l = ld.(fn{i});
        if ishghandle(l)
            delete(l);
        end
    end
    rmappdata(0,'CMEditMATLABListeners');
end

%----------------------------------------------------------------------%
function create_figure_listeners(fig,ax)

if any(ishandle_valid(fig))
    
    fig = handle(fig);
    fl.deleting = event.listener(fig, ...
              'ObjectBeingDestroyed', @(es,ed) figureDestroyed(es,ed,fig, ax));
    fl.cmapchanged = event.proplistener(fig,fig.findprop('Colormap'), ...
              'PostSet',@(es,ed) cmapChanged(es,ed,fig));
    fl.caxchanged = event.proplistener(fig, fig.findprop('CurrentAxes'), ...
              'PostSet',@(es,ed) currentAxesChanged(es,ed,fig,ax));
    fl.numberTitle = event.proplistener(fig, fig.findprop('NumberTitle'), ...
              'PostSet',@(es,ed) updateTitle(es,ed));
    fl.nameSet = event.proplistener(fig, fig.findprop('Name'), ...
              'PostSet',@(es,ed) updateTitle(es,ed));
    fl.mouseDown = event.listener(fig, 'WindowMouseRelease', ...
                        @(es,ed) handle_mouse_released(es,ed,fig,ax));
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%

function enable_figure_listeners(fig,onoff)

if ~isempty(fig) && any(ishandle_valid(fig, 'CMEditFigListeners'))
    fl = getappdata(fig,'CMEditFigListeners');
    if isobject(fl.cmapchanged)
        fl.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.cmapchanged,'Enabled',onoff);
    end
    if isobject(fl.caxchanged)
        fl.caxchanged.Enabled = strcmpi(onoff,'on');
    else
        set(fl.caxchanged,'Enabled',onoff);
    end
    if isobject(fl.deleting)
        fl.deleting.Enabled = strcmpi(onoff,'on');
    else
        set(fl.deleting,'Enabled',onoff);
    end
    if isobject(fl.numberTitle)
        fl.numberTitle.Enabled = strcmpi(onoff,'on');
    else
        set(fl.numberTitle,'Enabled',onoff);
    end
    if isobject(fl.nameSet)
        fl.nameSet.Enabled = strcmpi(onoff,'on');
    else
        set(fl.nameSet,'Enabled',onoff);
    end
    if isobject(fl.mouseDown)
        fl.mouseDown.Enabled = strcmpi(onoff,'on');
    else
        set(fl.mouseDown,'Enabled',onoff);
    end
    setappdata(fig,'CMEditFigListeners',fl);
end

%----------------------------------------------------------------------%
function destroy_figure_listeners(fig)

enable_figure_listeners(fig,'off');
if any(ishandle_valid(fig, 'CMEditFigListeners'))
    rmappdata(fig,'CMEditFigListeners');
end

%----------------------------------------------------------------------%
function create_axes_listeners(fig,ax)

if any(ishandle_valid(ax))
    al.deleting = event.listener(ax, ...
              'ObjectBeingDestroyed',@(es,ed) axesDestroyed(es,ed,fig,ax));
    al.climchanged = event.proplistener(ax,ax.findprop('CLim'), ...
              'PostSet', @(es,ed) climChanged(es,ed,ax));
    al.cmapchanged = event.listener(ax.ColorSpace,'MarkedClean', ...
                                   @(es,ed) cmapChanged(es,ed,ax));
    % Forced creation of delayed axes property
    ax.Title;drawnow;
    al.titleSet = event.listener(ax.Title,'MarkedClean', ...
                                   @(es,ed) updateTitle(es,ed));
    al.reset = event.listener(ax,'Reset', ...
                                   @(es,ed) handleAxesReset(es,ed,ax));
    setappdata(ax,'CMEditAxListeners',al);
end


%----------------------------------------------------------------------%
function enable_axes_listeners(ax,onoff)
    
fig = get(0,'CurrentFigure');
if ~isempty(fig) && any(ishandle_valid(ax, 'CMEditAxListeners'))
    al = getappdata(ax,'CMEditAxListeners');
    if isobject(al.climchanged)
        al.climchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.climchanged,'Enabled',onoff);
    end
    if isobject(al.deleting)
        al.deleting.Enabled = strcmpi(onoff,'on');
    else
        set(al.deleting,'Enabled',onoff);
    end
    if isobject(al.cmapchanged)
       al.cmapchanged.Enabled = strcmpi(onoff,'on');
    else
        set(al.cmapchanged,'Enabled',onoff);
    end 
    if isobject(al.titleSet)
       al.titleSet.Enabled = strcmpi(onoff,'on');
    else
        set(al.titleSet,'Enabled',onoff);
    end
    setappdata(ax,'CMEditAxListeners',al);
end

%----------------------------------------------------------------------%
function destroy_axes_listeners(ax)

enable_axes_listeners(ax,'off');
if any(ishandle_valid(ax, 'CMEditAxListeners'))
    rmappdata(ax,'CMEditAxListeners');
end

%----------------------------------------------------------------------%
function update_colormap(cmap)

check_colormap(cmap);
cme = get_cmapeditor();
if ~isempty(cme) && ~isempty(cme.getModel)
    cme.getModel.setBestColorMapModel(cmap);
    set_cme_title(cme);
end

%----------------------------------------------------------------------%
function yesno = ishandle_valid(h,appdata_field)
    
narginchk(1,2);
if nargin == 1
    appdata_field = [];
end
yesno = any(ishghandle(h)) && ~strcmpi('on',get(h,'BeingDeleted'));
if yesno && ~isempty(appdata_field)
    yesno = yesno && isappdata(h,appdata_field);
end        

%----------------------------------------------------------------------%
function handle_axes_change(fig,ax,create_listeners)
    
cme = get_cmapeditor();
if isempty(cme)
    return;
end
if isempty(cme.getFrame) || isempty(cme.getModel)
    return;
end

if ~any(ishandle_valid(ax))
    cme.getFrame.setColorLimitsEnabled(0);
else
    clim = get(ax,'Clim');
    cme.getFrame.setColorLimitsEnabled(1);
    cme.getModel.setColorLimits(clim,0);
    if (create_listeners)
        create_axes_listeners(fig,ax);
    end
end


%----------------------------------------------------------------------%
function check_colormap(cmap)
if isempty(cmap)
    error(message('MATLAB:colormapeditor:ColormapEmpty'));
end

%----------------------------------------------------------------------%
function cme = get_cmapeditor
cme = getappdata(0,'CMEditor');

%----------------------------------------------------------------------%
function set_cmapeditor(cme)
setappdata(0,'CMEditor',cme);

%----------------------------------------------------------------------%
function rm_cmapeditor
rmappdata(0,'CMEditor');

%-----------------------------------------------------------------------%
% the function sets obj to the current working object, could be either axes or
% figure. If a surface is selected then, the current working object is the
% axes that contains the surface.
function obj = get_current_matlab_object()

obj = gco;

if ~isempty(obj)
    if ishghandle(obj,'Colorbar')
        obj = obj.Axes;
    elseif ~ishghandle(obj,'figure') && ~ishghandle(obj,'axes')
        obj = ancestor(obj, 'axes');
        if ~ishandle_valid(obj)
            obj = '';
        end
        
        if isempty(obj)
            obj = get(0,'CurrentFigure');
        end
    end
end

if isempty(obj) || (~ishghandle(obj,'figure') && ~ishghandle(obj,'axes'))
    fig = get(0,'CurrentFigure');
    ax = get(fig, 'currentaxes');
    if ~isempty(ax) && isprop(ax,'clim')        
        obj = ax;
    else
        obj = fig;
    end
end

%----------------------------------------------------------------------%
function set_current_object(obj)
    
if ishandle_valid(obj)
    cme = get_cmapeditor();
    if ~isempty(cme)
        cme.setCurrentObject(java(handle(obj)));
    end
end
        
%----------------------------------------------------------------------%
function obj = get_current_object()
    
obj = [];
cme = get_cmapeditor();
if isempty(cme)
    return;
end
obj = handle(cme.getCurrentObject());
if isempty(obj)
    obj = get_current_matlab_object;
    set_current_object(obj);
end

%----------------------------------------------------------------------%
%set the title to be displayed in the colormapeditor, G950928
function set_cme_title(cme)
    
if isempty(cme)
    return
end
obj = get_current_object();
if ~ishandle_valid(obj)
    return;
end

if ~ishghandle(obj,'figure')
    fig = ancestor(obj, 'figure');
else
    fig = obj;
end

figureNumber = num2str(fig.Number);
title = '';
separator = '';
if strcmpi(get(fig,'NumberTitle'),'on')
    title = [getString(message('MATLAB:uistring:colormapeditor:FigureTitle')) ' ' figureNumber];
    separator = ': ';
end
if ~isempty(get(fig,'Name'))
    title = [title separator get(fig,'Name')];
end        

if ishghandle(obj,'axes')
    axestitle = get_axes_title(obj);
    title = [title ': ' axestitle];     
end

currentText = cme.getCurrentItemLabel();
if ~strcmp(currentText,title)
    cme.setCurrentItemLabel(title);
end

%---------------------------------------------------------------------- %
%enables Reset current Axes Colormap when the current working object is an axes
function enableResetAxes(cme,state)
cme.enableResetAxes(state);
    
%----------------------------------------------------------------------
function hsv = RGBtoHSB(rgb)

hsv = cell(length(rgb),1);
for i = 1:length(rgb)
    r = rgb{i}(1) * 255;
    g = rgb{i}(2) * 255;
    b = rgb{i}(3) * 255;

    if r > g
        cmax = r;
    else
        cmax = g;
    end
    
    if b > cmax
        cmax = b;
    end

    if r < g
        cmin = r;
    else
        cmin = g;
    end
    
    if b < cmin
        cmin = b;
    end

    brightness = cmax/255.0;
    if cmax ~= 0
        saturation = (cmax - cmin)/cmax;
    else
        saturation = 0;
    end
    
    if saturation==0
        hue = 0;
    else
        redc = (cmax-r)/(cmax-cmin);
        greenc = (cmax-g)/(cmax-cmin);
        bluec = (cmax-b)/(cmax-cmin);
        if r == cmax
            hue = bluec-greenc;
        elseif g == cmax
            hue = 2.0 + redc - bluec;
        else
            hue = 4.0 + greenc - redc;
        end
        
        hue = hue/6.0;
        if hue < 0
            hue = hue + 1.0;
        end
    end
    
    hsv{i}(1) = hue;
    hsv{i}(2) = saturation;
    hsv{i}(3) = brightness;
    
end


%----------------------------------------------------------------------
function rgb = HSBtoRGB(hsv)

rgb = cell(length(hsv),1);
for i = 1:length(hsv)
    r = 0;g = 0;b = 0;
    hue = hsv{i}(1);
    saturation = hsv{i}(2);
    brightness = hsv{i}(3);
    
    if saturation == 0
        r = (brightness * 255 + 0.5);
        g = r;
        b = r;
    else
        h = (hue - floor(hue)) * 6;
        f = h - floor(h);
        p = brightness * (1 - saturation);
        q = brightness * (1 - saturation * f);
        t = brightness * (1-(saturation * (1-f)));

        switch(floor(h))
            case 0
                r = brightness * 255.0 + 0.5;
                g = t * 255.0 + 0.5;
                b = p * 255.0 + 0.5;
            case 1
                r = q * 255.0 + 0.5;
                g = brightness * 255.0 + 0.5;
                b = p * 255.0 + 0.5;        
            case 2
                r = p * 255.0 + 0.5;
                g = brightness * 255.0 + 0.5;
                b = t * 255.0 + 0.5;        
            case 3
                r = p * 255.0 + 0.5;
                g = q * 255.0 + 0.5;
                b = brightness * 255.0 + 0.5;        
            case 4
                r = t * 255.0 + 0.5;
                g = p * 255.0 + 0.5;
                b = brightness * 255.0 + 0.5;        
            case 5
                r = brightness * 255.0 + 0.5;
                g = p * 255.0 + 0.5;
                b = q * 255.0 + 0.5;        
        end
    end

    rgb{i}(1) = min(r/255,1);
    rgb{i}(2) = min(g/255,1);
    rgb{i}(3) = min(b/255,1);
end

function axestitle = get_axes_title(ax) 
% Return the title of an axes as a 1D string.
%
% @todo This (and the functions above) need unittests!
%
axestitle = '';
if ~isempty(ax.Title) && ~isempty(ax.Title.String)
    title_string = ax.Title.String;
    if ischar(title_string)
        if size(title_string,1) == 1
            axestitle = title_string;
        elseif (size(title_string,1) > 1)
            title_string = title_string';
            title_string = title_string(:)';
        end
        if ~isempty(title_string)
            axestitle = title_string;
        end
    elseif iscell(title_string)
        axestitle = strjoin(title_string);
    end
else
    axestitle = getString(message('MATLAB:uistring:colormapeditor:UntitledAxes'));
end
