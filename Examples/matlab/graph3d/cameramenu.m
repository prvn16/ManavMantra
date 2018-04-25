function cameramenu(varargin)
%CAMERAMENU  Interactively manipulate camera.
%   CAMERAMENU creates a new menu that enables interactive
%   manipulation of a scene's camera and light by dragging the
%   mouse on the figure window; the camera properties of the
%   current axes (gca) are affected. Several camera properties
%   are set when the menu is initialized. 
%
%   CAMERAMENU('noreset') creates the menu without setting any
%   camera properties.
% 
%   CAMERAMENU('close') removes the menu.
%
%   Note: Either mouse button can be used to move the camera or
%   light. Clicking the right mouse button will stop camera or
%   light movements.
%
%   Note: Rendering performance is affected by presence of OpenGL 
%   hardware.
%
%   See also ROTATE3D, ZOOM.

%   Copyright 1984-2014 The MathWorks, Inc.

persistent walk_flag
[hfig,haxes]=currenthandles;

Udata = getUdata;

if nargin==0
  if iscameraobj(haxes)
    axis(haxes,'vis3d')
    axis(haxes,axis(haxes))
	camproj(haxes,'perspective');
    renmode = get(hfig, 'renderermode');
  end
  try
    set(hfig, 'renderer', 'opengl');
  catch err %#ok<NASGU>
    warning(message('MATLAB:cameramenu:OpenGLNotAvailable'))
  end
  % Workaround for bug: if Opengl does not load, the renderermode 
  % is not reset to previous value.
  if ~strcmpi(get(hfig, 'renderer'), 'opengl')
    set(hfig, 'renderermode', renmode)
  end
  arg = 'init';
  scribeclearmode(hfig,'cameramenu', 'nomode');
else
  arg = lower(varargin{1});
  if ~strcmp(arg, 'init') && ~strcmp(arg, 'motion') && isempty(Udata)
    cameramenu('init')
    Udata = getUdata;
    if ~strcmp(arg, 'nomode')
      scribeclearmode(hfig,'cameramenu', 'nomode');
    end
  end
end

switch arg
case 'down'
   origUnits=get(hfig,'units');
   set(hfig,'units','pixels');
   pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
   set(hfig,'units',origUnits);
   Udata.figStartPoint = pt;
   Udata.figLastPoint  = pt;
   Udata.figLastLastPoint = pt;
   Udata.buttondown = 1;
   Udata.moving = 0;
   setUdata(Udata)

   if ~iscameraobj(haxes)
	   return;
   end
   if strcmp(Udata.movedraw, 'box') && isempty(Udata.savestate.ax)
     Udata.savestate.children = findobj(haxes, 'visible', 'on');
     Udata.savestate.fig = get(hfig);
     Udata.savestate.ax = get(haxes);
     if ~strcmp(get(hfig, 'renderer'), 'OpenGL')
       set(hfig, 'renderer', 'painters')
     end
     set(get(haxes,'children'), 'vis', 'off')
     set(haxes, 'color', 'none', 'visible', 'on');
     figColor = get(hfig, 'color');
     if sum(figColor .* [.3 .6 .1]) > .5
       contrastColor = 'k';
     else
       contrastColor = 'w';
     end
     if isequal(figColor, get(haxes, 'xcolor'))
       set(haxes, 'xcolor', contrastColor);
     end
     if isequal(figColor, get(haxes, 'ycolor'))
       set(haxes, 'ycolor', contrastColor);
     end
     if isequal(figColor, get(haxes, 'zcolor'))
       set(haxes, 'zcolor', contrastColor);
     end
     ticks(haxes,'off')
     box(haxes,'on')
   end

   setUdata(Udata)

   validateScenelight(haxes)
   updateScenelightOnOff(Udata.scenelightOn)
   
   
case 'motion'
  if isstruct(Udata) && Udata.buttondown 
   	origUnits=get(hfig,'units');
	set(hfig,'units','pixels');
	pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
	set(hfig,'units',origUnits);
    deltaPix  = pt-Udata.figLastPoint;
    deltaPixStart  = pt-Udata.figStartPoint;
    Udata.figLastLastPoint = Udata.figLastPoint;
    Udata.figLastPoint = pt;
    
    Udata.time = clock;
    
    mode = Udata.mode;
    hvmode = Udata.mouseconstraint;
    if hvmode(1) == 'h'
      deltaPix(2) = 0;
      deltaPixStart(2) = 0;
    elseif hvmode(1) == 'v'
      deltaPix(1) = 0;
      deltaPixStart(1) = 0;
    end
    
    setUdata(Udata)
    if ~iscameraobj(haxes)
	   return;
    end
    switch mode
        case getString(message('MATLAB:cameramenu:Label_Orbit'))
            orbitPangca(haxes,deltaPix, 'o');
        case getString(message('MATLAB:cameramenu:Label_OrbitScenelight'))
            orbitLightgca(haxes,deltaPix);
        case getString(message('MATLAB:cameramenu:Label_Pan'))
            orbitPangca(haxes,deltaPix, 'p');
        case getString(message('MATLAB:cameramenu:Label_DollyHorizVert'))
            dollygca(haxes,deltaPix);
        case getString(message('MATLAB:cameramenu:Label_Zoom'))
            zoomgca(haxes,deltaPix);
        case getString(message('MATLAB:cameramenu:Label_DollyInOut'))
            forwardBackgca(haxes,deltaPix, 'c');
        case getString(message('MATLAB:cameramenu:Label_Roll'))
            rollgca(haxes,deltaPix, pt);
        case getString(message('MATLAB:cameramenu:Label_Walk'))
            Udata.moving=1;
            setUdata(Udata)
            if isempty(walk_flag)
                walk_flag = 1;
                walkgca(haxes,deltaPixStart,[]);
            else
                walkgca(haxes,deltaPixStart,1);
            end
    end
  end
case 'up'
  Udata.buttondown = 0;
  Udata.moving   = 0;
  origUnits=get(hfig,'units');
  set(hfig,'units','pixels');
  pt = get(hfig, 'currentpoint');pt = pt(1,1:2);
  set(hfig,'units',origUnits);
  deltaPix  = pt-Udata.figLastLastPoint;
  deltaPixStart  = pt-Udata.figStartPoint;
  Udata.figLastPoint = pt;
  % Checking the sensitivity of the camera throw mode w.r.t mouse events
  % Speed at the end being proportional to the dist traveled at the end...
  speed_sense = sqrt((deltaPix(1)^2)+(deltaPix(2)^2));
  % Total distance traveled from start to finish:
  dist_sense = sqrt((deltaPixStart(1)^2)+(deltaPixStart(2)^2));
  % Scaling down the speed of motion in the throw mode
  mode = Udata.mode;
  clear walk_flag;
  
  hvmode = lower(Udata.mouseconstraint);
  if hvmode(1) == 'h'
    deltaPix(2) = 0;
    deltaPixStart(2) = 0;
  elseif hvmode(1) == 'v'
    deltaPix(1) = 0;
    deltaPixStart(1) = 0;
  end
  
  setUdata(Udata)
  if ~iscameraobj(haxes)
	 return;
  end
  % Scale down the deltas to get a reasonable speed.
  scaled_deltaPix = deltaPix/10;
  scaled_deltaPixStart = deltaPixStart/10;
  if etime(clock, Udata.time)<.1 && (speed_sense>=7) && (dist_sense>30) ...
	&& any(deltaPix) && ~strcmp('alt', get(hfig, 'selectiontype'))
    Udata.moving = 1;
    setUdata(Udata)
    switch mode
        case getString(message('MATLAB:cameramenu:Label_Orbit'))
            orbitPangca(haxes,scaled_deltaPix, 'o');
        case getString(message('MATLAB:cameramenu:Label_OrbitScenelight'))
            orbitLightgca(haxes,scaled_deltaPix);
        case getString(message('MATLAB:cameramenu:Label_Pan'))
            orbitPangca(haxes,scaled_deltaPix, 'p');
        %case getString(message('MATLAB:cameramenu:Label_Roll'))
            %rollgca(haxes,deltaPix);
        case getString(message('MATLAB:cameramenu:Label_Walk'))
            walkgca(haxes,scaled_deltaPixStart,1);
    end
  end
     
  if strcmp(Udata.movedraw, 'box') && ~isempty(Udata.savestate.ax)
    set(Udata.savestate.children, 'vis', 'on')
    set(hfig, 'Renderer',     Udata.savestate.fig.Renderer    );
    set(hfig, 'RendererMode', Udata.savestate.fig.RendererMode);
    set(haxes, 'Color',     Udata.savestate.ax.Color    )
    set(haxes, 'Visible',   Udata.savestate.ax.Visible  )
    set(haxes, 'XColor',    Udata.savestate.ax.XColor   )
    set(haxes, 'YColor',    Udata.savestate.ax.YColor   )
    set(haxes, 'ZColor',    Udata.savestate.ax.ZColor   )
    set(haxes, 'Xtick',     Udata.savestate.ax.XTick    )
    set(haxes, 'XtickMode', Udata.savestate.ax.XTickMode)
    set(haxes, 'Ytick',     Udata.savestate.ax.YTick    )
    set(haxes, 'YtickMode', Udata.savestate.ax.YTickMode)
    set(haxes, 'Ztick',     Udata.savestate.ax.ZTick    )
    set(haxes, 'ZtickMode', Udata.savestate.ax.ZTickMode)
    set(haxes, 'Box',       Udata.savestate.ax.Box      )
    Udata.savestate.ax = [];
    setUdata(Udata)
   end
   
case 'stopmoving'
  Udata.moving = 0;
  setUdata(Udata)
case 'updatemenu'
  updateMenu(hfig,haxes);
case 'changemode'
  if strcmp(Udata.mode, get(gcbo, 'Label'))
    cameramenu('nomode')
    Udata = getUdata;
  else
    Udata.mode = get(gcbo, 'Label');
    scribeclearmode(hfig,'cameramenu', 'nomode');
  end
  if iscameraobj(haxes)
	  if strcmp(Udata.mode, getString(message('MATLAB:cameramenu:Label_Walk')))
		  camproj(haxes,'perspective');
	  end
  end
  setUdata(Udata)
  updateMenu(hfig,haxes);
case 'changecoordsys'
  Udata.coordsys = getCoordsys(gcbo);
  setUdata(Udata)

  if iscameraobj(haxes)
	  if length(Udata.coordsys)==1
		  coordsysval =  lower(Udata.coordsys) - 'x' + 1;
		  
		  d = [0 0 0];
		  d(coordsysval) = 1;
		  
		  up = camup(haxes);
		  if up(coordsysval) < 0
			  d = -d;
		  end
		  
		  % Check if the camera up vector is parallel with the view direction;
		  % if not, set the up vector
		  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
			  camup(haxes,d)
			  updateScenelightPosition;
		  end  
	  end
  end
  updateMenu(hfig,haxes);
case 'changescenelight'
  val = toggleOnOff(gcbo);
  if ~val && strcmp(Udata.mode, getString(message('MATLAB:cameramenu:Label_OrbitScenelight')))
    Udata.mode = getString(message('MATLAB:cameramenu:Label_Orbit'));
    setUdata(Udata)
  end
  validateScenelight(haxes)
  updateScenelightOnOff(val)
  updateScenelightPosition
case 'changeaxesvisible'
  toggleOnOff(gcbo)
  axis(haxes,get(gcbo, 'checked'))
case 'changeaxesbox'
  if toggleOnOff(gcbo)
    axis(haxes,'on')
  end
  box(haxes,get(gcbo, 'checked'))
case 'changeaxesgrid'
  if iscameraobj(haxes)
	  if toggleOnOff(gcbo)
		  axis(haxes,'on')
		  ticks(haxes,'on')
	  end
	  grid(haxes,get(gcbo, 'checked'))
  end
case 'changeaxesticks'
  if iscameraobj(haxes)
	  if toggleOnOff(gcbo)
		  axis(haxes,'on')
	  else
		  grid(haxes,'off')
	  end
	  ticks(haxes,get(gcbo, 'checked'))
  end
case 'changeaxesprojection'
  if iscameraobj(haxes)
	  camproj(haxes, getCamproj(gcbo));
  end
case 'changeaxescolor'
  str = getColorStr(gcbo);
  set(haxes, str, uisetcolor(get(haxes, str)))
case 'changerenderer'
  set(hfig, 'renderer', getRenderer(gcbo))
case 'changerenderermode'
  if toggleOnOff(gcbo)
    set(hfig, 'renderermode', 'auto')
  else
    set(hfig, 'renderermode', 'manual')
  end
case 'changemovedraw'
  if toggleOnOff(gcbo)
    Udata.movedraw = 'box';
  else
    Udata.movedraw = 'same';
  end
  setUdata(Udata)
case 'changefigcolor'
  set(hfig, 'color', uisetcolor(get(hfig, 'color')))
case 'changedoublebuffer'
  toggleOnOff(gcbo)
  set(hfig, 'doublebuffer', get(gcbo, 'checked'))
case 'changenosort'
  if toggleOnOff(gcbo)
    haxes.SortMethod = 'ChildOrder';
  else
    haxes.SortMethod = 'depth';
  end
case 'resetscenelight'
  if iscameraobj(haxes)
	  Udata.scenelightAz = 0;
	  Udata.scenelightEl = 0;
	  setUdata(Udata)
	  validateScenelight(haxes)
	  updateScenelightPosition
  end
case 'resetall'
  if any(ishghandle(Udata.scenelight))
      delete(Udata.scenelight);
  end
  initUdata;
  updateMenu(hfig,haxes)
  cameramenu('resetcamera');
case 'resetcamera'
  if iscameraobj(haxes)
	  resetCameraProps(haxes)
	  cameramenu('resetscenelight');
  end
case 'changemouseconstraint'
  Udata.mouseconstraint = getMouseconstraint(gcbo);
  setUdata(Udata)
  updateMenu(hfig,haxes)
case 'checkcdata'
  objs=[findobj(haxes, 'type', 'patch'); findobj(haxes, 'type', 'surface')];
  for j = 1:length(objs)
    obj = objs(j);
    if strcmp(get(obj, 'visible'), 'on') && isempty(get(obj, 'cdata'))
      warndlg('Not all visible surfaces and patches have cdata', '')
      return
    end
  end
  eval(varargin{2});
case 'noreset'
  cameramenu('init');
case 'nomode'
  Udata.mode = '';
  restoreWindowCallbacks(hfig,Udata.wcb);
  setUdata(Udata)
  updateMenu(hfig,haxes)
  restoreWindowCursor(hfig,Udata.cursor);
case 'init'
  warning(message('MATLAB:cameramenu:Removal'));
  emptyUdata = isempty(Udata);
  wcb = getWindowCallbacks(hfig);
  cursor = getWindowCursor(hfig);
  initWindowCallbacks(hfig)
  menus = findobj(hfig, 'type', 'uimenu');
  cammenu = findobj(menus, 'tag', 'cm598');
  if isempty(cammenu)
    createMenu(hfig,haxes);
  end
  if isfield(Udata, 'scenelight') && any(ishghandle(Udata.scenelight))    
    delete(Udata.scenelight);      
  end
  initUdata
  Udata = getUdata;
  if emptyUdata
    Udata.wcb = wcb;
    Udata.cursor = cursor;
  end
  setUdata(Udata)
  updateMenu(hfig,haxes)
case 'close'
  restoreWindowCallbacks(hfig,Udata.wcb);
  restoreWindowCursor(hfig,Udata.cursor);
  cameramenu('stopmoving')
  if any(ishghandle(Udata.scenelight))
      delete(Udata.scenelight);
  end
  if any(ishghandle(Udata.mainMenuHandle))
      delete(Udata.mainMenuHandle);
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localDrawnow

Udata = getUdata;

if Udata.moving == 1
  drawnow
else
  drawnow expose
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitPangca(haxes,xy, mode)
Udata = getUdata;

%mode = 'o';  orbit
%mode = 'p';  pan


coordsys = lower(Udata.coordsys);
if coordsys(1)=='u'
  coordsysval = 0;
else
  coordsysval = coordsys(1) - 'x' + 1;
end

xy = -xy;

if mode=='p' % pan
  panxy = xy*camva(haxes)/500;
end
  
if coordsysval>0
  d = [0 0 0];
  d(coordsysval) = 1;
  
  up = camup(haxes);
  upsidedown = (up(coordsysval) < 0);
  if upsidedown 
    xy(1) = -xy(1);
    d = -d;
  end

  % Check if the camera up vector is parallel with the view direction;
  % if not, set the up vector
  if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
    camup(haxes,d)
  end  
end

flag = 1;

while sum(abs(xy))> 0 && isstruct(Udata) && (flag || Udata.moving==1)
  flag = 0;
  
  if mode=='o' %orbit
    if coordsysval==0 %unconstrained
      camorbit(haxes,xy(1), xy(2), coordsys)
    else
      camorbit(haxes,xy(1), xy(2), 'data', coordsys)
    end
  else %pan
    if coordsysval==0 %unconstrained
      campan(haxes,panxy(1), panxy(2), coordsys)
    else
      campan(haxes,panxy(1), panxy(2), 'data', coordsys)
    end
  end
  
  updateScenelightPosition;
  localDrawnow;
  Udata = getUdata;
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function orbitLightgca(~,xy)
Udata = getUdata;

if sum(abs(xy))> 0 && ~Udata.scenelightOn
  updateScenelightOnOff(1)
  Udata = getUdata;
end

% Check if the light is on the other side of the object
az = mod(abs(Udata.scenelightAz),360);
if az > 90 && az < 270
  xy(2) = -xy(2);
end

flag = 1;

while sum(abs(xy))> 0 && isstruct(Udata) && (flag || Udata.moving==1)
  flag = 0;
  
  Udata.scenelightAz = mod(Udata.scenelightAz + xy(1), 360);
  Udata.scenelightEl = mod(Udata.scenelightEl + xy(2), 360);
  
  if abs(Udata.scenelightEl) > 90
    Udata.scenelightEl = 180 - Udata.scenelightEl;
    Udata.scenelightAz = 180 + Udata.scenelightAz;
    xy(2) = -xy(2);
  end

  setUdata(Udata)
  updateScenelightPosition
  
  localDrawnow;
  Udata = getUdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function walkgca(haxes,xy1,walk_flag)
persistent xy v up d cva q
xy = xy1;
Udata = getUdata;

coordsys = lower(Udata.coordsys);
if coordsys(1)=='u'
  coordsysval = 0;
else
  coordsysval = coordsys(1) - 'x' + 1;
end

if coordsysval>0
  d = [0 0 0];
  d(coordsysval) = 1;

  up = camup(haxes);
  if up(coordsysval) < 0
    d = -d;
  end
end

q = max(-.9, min(.9, xy(2)/700));
cva = camva(haxes);

recursionflag = 1;

while sum(abs(xy))> 0 && isstruct(Udata) && recursionflag && Udata.moving==1
  
  if coordsysval==0 %unconstrained
    campan(haxes,xy(1)*cva/700, 0, 'camera')
    v = q*(camtarget(haxes)-campos(haxes));
  else
    campan(haxes,xy(1)*cva/700, 0, 'data', d)
	
	% Check if the camera up vector is parallel with the view direction;
	% if not, set the up vector
	if any(crossSimple(d,campos(haxes)-camtarget(haxes)))
		camup(haxes,d);
	end
	
    v = q*(camtarget(haxes)-campos(haxes));
    v(coordsysval) = 0;
  end
  camdolly(haxes,v(1), v(2), v(3), 'movetarget', 'data')
  updateScenelightPosition;
  if isempty(walk_flag)
	  localDrawnow;
  else
	  drawnow expose
	  recursionflag = 0;
  end
  Udata = getUdata;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dollygca(haxes,xy)
camdolly(haxes,-xy(1), -xy(2), 0, 'movetarget', 'pixels')
updateScenelightPosition;
localDrawnow;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% not used
%
% function flipgca(xy)
% Udata = getUdata;
% 
% xy = -xy;
% 
% flag = 1;
% 
% while isstruct(Udata) && (flag || Udata.moving==1)
%   flag = 0;
% 
%   camorbit(haxes,xy(1), xy(2), 'camera')
%   
%   updateScenelightPosition;
%   
%   drawnow
%   Udata = getUdata;
% end
% 


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function zoomgca(haxes,xy)
q = max(-.9, min(.9, sum(xy)/70));
camzoom(haxes,1+q);
localDrawnow;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function forwardBackgca(haxes,xy, mode)

q = max(-.9, min(.9, sum(xy)/70));

if mode=='b'
  camdolly(haxes,0,0,q);
else
  camdolly(haxes,0,0,q, 'f');
end

updateScenelightPosition;
localDrawnow;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function rollgca(haxes,dxy, pt)
Udata = getUdata;

% find the pixel center of the axes
units = get(haxes, 'units');
set(haxes, 'units', 'pix');
pos = get(haxes, 'pos');
center = pos(1:2)+pos(3:4)/2;
set(haxes, 'units', units);

startpt = pt - dxy;

v1 = pt-center;
v2 = startpt-center;

v1 = v1/norm(v1);
v2 = v2/norm(v2);
theta = acos(sum(v2.*v1)) * 180/pi;
cross =  crossSimple([v1 0],[v2 0]);
if cross(3) >0
  theta = -theta;
end

flag = 1;

while isstruct(Udata) && (flag || Udata.moving==1)
  flag = 0;
  
  camroll(haxes,theta);
  
  updateScenelightPosition;

  localDrawnow;
  Udata = getUdata;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function createMenu(~, ~)
Udata.mainMenuHandle = uimenu('Label', getString(message('MATLAB:cameramenu:Label_Camera')), ...
    'callback', 'cameramenu(''updatemenu'')');

%Udata.mainMenuHandle=uicontextmenu( ...
%    'callback', 'cameramenu(''updatemenu'')');
%set(hfig, 'uicontextmenu', Udata.mainMenuHandle)


%%
%% Mode
%%
Udata.modeMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_MouseMode')),...
    'tag','Cameramenu_MouseMode');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Orbit')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_Orbit');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_OrbitScenelight')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_OrbitScenelight');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Pan')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_Pan');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_DollyHorizVert')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_DollyHorizVert');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_DollyInOut')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_DollyInOut');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Zoom')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_Zoom');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Roll')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_Roll');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Walk')), ...
    'callback', 'cameramenu(''changemode'')','tag','Cameramenu_MouseMode_Walk');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_X')), ...
    'separator', 'on', ...
    'callback', 'cameramenu(''changecoordsys'')','tag','Cameramenu_MouseMode_X');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Y')), ...
    'callback', 'cameramenu(''changecoordsys'')','tag','Cameramenu_MouseMode_Y');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Z')), ...
    'callback', 'cameramenu(''changecoordsys'')','tag','Cameramenu_MouseMode_Z');
uimenu(Udata.modeMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Unconstrained')), ...
    'callback', 'cameramenu(''changecoordsys'')','tag','Cameramenu_MouseMode_Unconstrained');

%%
%% Mouse constraint
%%
Udata.mouseConstraintMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_MouseConstraint')), ...
    'tag','Cameramenu_MouseConstraint');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Horizontal')), ...
    'callback', 'cameramenu(''changemouseconstraint'')','tag','Cameramenu_MouseConstraint_Horizontal');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Vertical')), ...
    'callback', 'cameramenu(''changemouseconstraint'')','tag','Cameramenu_MouseConstraint_Vertical');
uimenu(Udata.mouseConstraintMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Unconstrained')), ...
    'callback', 'cameramenu(''changemouseconstraint'')','tag','Cameramenu_MouseConstraint_Unconstrained');

%%
%% Stop moving
%%
Udata.stopmovingMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_StopMoving')), ...
    'callback', 'cameramenu(''stopmoving'')','tag','Cameramenu_StopMoving');

%%
%% Scenelight
%%
Udata.scenelightMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Scenelight')), ...
    'callback', 'cameramenu(''changescenelight'')','tag','Cameramenu_SceneLight');

%%
%% Reset
%%
Udata.resetMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Reset')), ...
    'tag','Cameramenu_Reset');
uimenu(Udata.resetMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ResetModesCameraProperties')), ...
    'callback', 'cameramenu(''resetall'')' ,'tag','Cameramenu_Reset_ModesCameraProperties');
uimenu(Udata.resetMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ResetCameraProperties')), ...
    'callback', 'cameramenu(''resetcamera'')','tag','Cameramenu_Reset_CameraProperties');
uimenu(Udata.resetMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ResetTargetPoint')), ...
    'callback', 'camtarget(gca(gcbf),''auto''); camtarget(gca(gcbf),camtarget(gca(gcbf))); cameramenu(''resetscenelight'');','tag','Cameramenu_Reset_TargetPoint');
uimenu(Udata.resetMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ResetScenelight')), ...
    'callback', 'cameramenu(''resetscenelight'')','tag','Cameramenu_Reset_SceneLight');


%%
%% Scene
%%
Udata.sceneMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Scene')), ...
    'tag','Cameramenu_Scene');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_FitAll')), ...
    'callback','camlookat(gca(gcbf))','tag','Cameramenu_Scene_FitAll');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_LightingNone')), ...
    'separator', 'on',...
    'callback', 'lighting(gca(gcbf),''none'')','tag','Cameramenu_Scene_LightingNone');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_LightingFlat')), ...
    'callback', 'lighting(gca(gcbf),''flat'')','tag','Cameramenu_Scene_LightingFlat');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_LightingGouraud')), ...
    'callback', 'lighting(gca(gcbf),''gouraud'')','tag','Cameramenu_Scene_LightingGouraud');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ShadingFaceted')), ...
    'separator', 'on',...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''faceted'''')'')','tag','Cameramenu_Scene_ShadingFaceted');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ShadingFlat')), ...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''flat'''')'')','tag','Cameramenu_Scene_ShadingFlat');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ShadingInterp')), ...
    'callback', 'cameramenu(''checkcdata'', ''shading(gca(gcbf),''''interp'''')'')','tag','Cameramenu_Scene_ShadingInterp');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ClippingOn')), ...
    'separator', 'on',...
    'callback', 'set(findobj(gca(gcbf)), ''clipping'', ''on'')','tag','Cameramenu_Scene_ClippingOn');
uimenu(Udata.sceneMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ClippingOff')), ...
    'callback', 'set(findobj(gca(gcbf)), ''clipping'', ''off'')','tag','Cameramenu_Scene_ClippingOff');

%%
%% Axes
%%
Udata.axesMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Axes')), ...
    'tag','Cameramenu_Axes');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Visible')), ...
    'callback', 'cameramenu(''changeaxesvisible'')','tag','Cameramenu_Axes_Visible');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Box')), ...
    'callback', 'cameramenu(''changeaxesbox'')','tag','Cameramenu_Axes_Box');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Ticks')), ...
    'callback', 'cameramenu(''changeaxesticks'')','tag','Cameramenu_Axes_Ticks');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Grid')), ...
    'callback', 'cameramenu(''changeaxesgrid'')','tag','Cameramenu_Axes_Grid');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_WallsColor')), ...
    'separator', 'on',...
    'callback', 'cameramenu(''changeaxescolor'')','tag','Cameramenu_Axes_WallsColor');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_XColor')), ...
    'callback', 'cameramenu(''changeaxescolor'')','tag','Cameramenu_Axes_XColor');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_YColor')), ...
    'callback', 'cameramenu(''changeaxescolor'')','tag','Cameramenu_Axes_YColor');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_ZColor')), ...
    'callback', 'cameramenu(''changeaxescolor'')','tag','Cameramenu_Axes_ZColor');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Orthographic')), ...
    'separator', 'on',  ...
    'callback', 'cameramenu(''changeaxesprojection'')','tag','Cameramenu_Axes_Orthographic');
uimenu(Udata.axesMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Perspective')), ...
    'callback', 'cameramenu(''changeaxesprojection'')','tag','Cameramenu_Axes_Perspective');

%%
%% Renderer
%%
Udata.rendererMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_RendererOptions')), ...
    'tag','Cameramenu_Renderer');
uimenu(Udata.rendererMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Painters')), ...
    'callback', 'cameramenu(''changerenderer'')','tag','Cameramenu_Renderer_Painters');
uimenu(Udata.rendererMenuHandle, ...
    'Label', ['  ' getString(message('MATLAB:cameramenu:Label_DoubleBuffer'))], ...
    'callback', 'cameramenu(''changedoublebuffer'')','tag','Cameramenu_Renderer_DoubleBuffer');
uimenu(Udata.rendererMenuHandle, ...
    'Label', ['  ' getString(message('MATLAB:cameramenu:Label_NoSort'))], ...
    'callback', 'cameramenu(''changenosort'')','tag','Cameramenu_Renderer_NoSort');
uimenu(Udata.rendererMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_OpenGL')), ...
    'callback', 'cameramenu(''changerenderer'')','tag','Cameramenu_Renderer_OpenGL');
uimenu(Udata.rendererMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_Auto')), ...
    'callback', 'cameramenu(''changerenderermode'')','tag','Cameramenu_Renderer_Auto');
uimenu(Udata.rendererMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_MoveAsBox')), ...
    'separator', 'on',  ...
    'callback', 'cameramenu(''changemovedraw'')','tag','Cameramenu_Renderer_MoveAsBox');
uimenu(Udata.rendererMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_BackgroundColor')), ...
    'separator', 'on', ...
    'callback', 'cameramenu(''changefigcolor'')','tag','Cameramenu_Renderer_BackgroundColor');

%%
%% Remove menu
%%
Udata.removeMenuHandle = uimenu(Udata.mainMenuHandle, ...
    'Label', getString(message('MATLAB:cameramenu:Label_RemoveMenu')), ...
    'callback', 'cameramenu(''close'')','tag','Cameramenu_Remove');


set(Udata.mainMenuHandle, 'tag', 'cm598');
setUdata(Udata)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateMenu(hfig,haxes)
Udata = getUdata;

menu = Udata.mainMenuHandle;
if isempty(Udata.mode)
  str = getString(message('MATLAB:cameramenu:Label_Camera'));
elseif strmatch(Udata.mode, { ...
        getString(message('MATLAB:cameramenu:Label_Orbit')) ...
        getString(message('MATLAB:cameramenu:Label_Pan')) ...
        getString(message('MATLAB:cameramenu:Label_Walk')) })
  str = getString(message('MATLAB:cameramenu:Label_CameraModeCoordsys', Udata.mode, getCoordsysMenuLabel(Udata.coordsys)));
else
  str = getString(message('MATLAB:cameramenu:Label_CameraMode', Udata.mode));
end

set(menu, 'Label', str)

children = get(Udata.mainMenuHandle, 'children');
set(children, 'checked', 'off');

%%
%% Mode
%%
children = get(Udata.modeMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Label', Udata.mode);
set(menu, 'checked', 'on')
menu = findobj(children, 'Label', getCoordsysMenuLabel(Udata.coordsys));
set(menu, 'checked', 'on')
children = get(Udata.modeMenuHandle, 'children');
menus = [findobj(children,'tag','Cameramenu_MouseMode_X'),findobj(children,'tag','Cameramenu_MouseMode_Y'),findobj(children,'tag','Cameramenu_MouseMode_Z'),findobj(children,'tag','Cameramenu_MouseMode_Unconstrained')];
if ~isempty(Udata.mode)
  set(menus, 'enable', bool2OnOff(strmatch(Udata.mode, ...
      {getString(message('MATLAB:cameramenu:Label_Orbit')) ...
       getString(message('MATLAB:cameramenu:Label_Pan')) ...
       getString(message('MATLAB:cameramenu:Label_Walk'))})))
else
  set(menus, 'enable', 'off')
end

%%
%% Stop Moving
%%
set(Udata.stopmovingMenuHandle, 'enable', bool2OnOff(Udata.moving))

%%
%% Scenelight
%%
if ~any(ishghandle(Udata.scenelight))
   Udata.scenelightOn = 0;
end
set(Udata.scenelightMenuHandle, 'checked', bool2OnOff(Udata.scenelightOn));

%%
%% Mouse motion constraint
%%
children = get(Udata.mouseConstraintMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Tag', getMouseconstraintTag(Udata.mouseconstraint));
set(menu, 'checked', 'on')

%%
%% Axes
%%
children = get(Udata.axesMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Tag', 'Cameramenu_Axes_Visible');
set(menu, 'checked', get(haxes, 'visible'))
menu = findobj(children, 'Tag', 'Cameramenu_Axes_Box');
boxVal = get(haxes,'box');
if ~any(strcmpi(boxVal,{'on','off'}))
    boxVal = 'off';
end
set(menu, 'checked', boxVal)
menu = findobj(children, 'Tag', 'Cameramenu_Axes_Grid');
set(menu, 'checked', get(haxes, 'xgrid'))
menu = findobj(children, 'Tag', 'Cameramenu_Axes_Ticks');
set(menu, 'checked', bool2OnOff(~isempty(get(haxes, 'xtick'))))
menu = findobj(children, 'Tag', getCamprojTag(camproj(haxes)));
set(menu, 'checked', 'on')

%%
%% Renderer
%%
children = get(Udata.rendererMenuHandle, 'children');
set(children, 'checked', 'off')
menu = findobj(children, 'Tag', getRendererTag(get(hfig, 'renderer')));
set(menu, 'checked', 'on')
menu = findobj(children, 'Tag', 'Cameramenu_Renderer_Auto');
set(menu, 'checked', bool2OnOff(strcmp(get(hfig, 'renderermode'), 'auto')))

enable = bool2OnOff(strcmp(get(hfig, 'renderer'), 'painters'));
menu = findobj(children, 'Tag', 'Cameramenu_Renderer_DoubleBuffer');
set(menu, 'checked', get(hfig, 'doublebuffer'), ...
    'enable', enable)
menu = findobj(children, 'Tag', 'Cameramenu_Renderer_NoSort');
set(menu, 'checked', bool2OnOff(strcmp(haxes.SortMethod, 'ChildOrder')), ...
    'enable', enable)
menu = findobj(children, 'Tag', 'Cameramenu_Renderer_MoveAsBox');
set(menu, 'checked', bool2OnOff(strcmp(Udata.movedraw, 'box')))


if ~isempty(Udata.mode)
  cdata = [
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan 1   nan nan nan nan nan nan nan nan 1   nan nan nan 
    nan nan 1   1   nan nan nan nan nan nan nan nan 1   1   nan nan 
    nan 1   2   1   1   1   1   1   1   1   1   1   1   2   1   nan 
    1   2   2   2   2   2   2   2   2   2   2   2   2   2   2   1   
    1   2   2   2   2   2   2   2   2   2   2   2   2   2   2   1   
    nan 1   2   1   1   1   1   1   1   1   1   1   1   2   1   nan 
    nan nan 1   1   nan nan nan nan nan nan nan nan 1   1   nan nan 
    nan nan nan 1   nan nan nan nan nan nan nan nan 1   nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan nan 
    ];
  
  hvmode = lower(Udata.mouseconstraint);
  if hvmode(1) == 'h'
    %cdata = cdata;
  elseif hvmode(1) == 'v'
    cdata =cdata';
  else  % make cross
    cdata([5 6 11 12],4 ) = nan;
    cdata([5 6 11 12],13) = nan;
    a = cdata;
    b = cdata';
    newcdata = nan*zeros(16);
    newcdata(a==1 | b==1) = 1;
    newcdata(a==2 | b==2) = 2;
    cdata = newcdata;
  end
  
  set(hfig, 'pointer', 'custom', 'pointershapecdata', cdata, ...
      'pointershapehotspot', [8 8]);
  initWindowCallbacks(hfig)
  
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Udata = getUdata

hfig = currenthandles;

%h = hfig;
h = findobj(get(hfig,'children'), 'type', 'uimenu', 'tag', 'cm598');
if ~isempty(h)
  Udata = get(h(1), 'userdata');
else
  Udata = [];
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function setUdata(Udata)

hfig =currenthandles;

%h = hfig;
h = findobj(get(hfig,'children'), 'type', 'uimenu', 'tag', 'cm598');
if ~isempty(h)
  set(h(1), 'userdata', Udata);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initUdata
Udata = getUdata;

Udata.mode = getString(message('MATLAB:cameramenu:Label_Orbit'));
Udata.coordsys = 'Z';
Udata.mouseconstraint = 'Unconstrained';
Udata.movedraw = 'same';
Udata.savestate.ax = [];

Udata.buttondown = 0;
Udata.moving = 0;
Udata.time = clock;
Udata.scenelightOn=0;
Udata.scenelight=-1;
Udata.scenelightAz = 0;
Udata.scenelightEl = 0;

setUdata(Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightPosition
Udata = getUdata;
if Udata.scenelightOn
  camlight(Udata.scenelight, Udata.scenelightAz, Udata.scenelightEl);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function updateScenelightOnOff(val)
Udata = getUdata;
Udata.scenelightOn = val;
set(Udata.scenelight, 'vis', bool2OnOff(val))
setUdata(Udata);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function validateScenelight(haxes)
Udata = getUdata;
if ~any(ishghandle(Udata.scenelight))
  Udata.scenelight = camlight(light('parent',haxes));
  set(Udata.scenelight, 'vis', 'off')
  setUdata(Udata)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function initWindowCallbacks(hfig)
set(hfig, 'windowbuttondownfcn',   'cameramenu(''down''  )')
set(hfig, 'windowbuttonmotionfcn', 'cameramenu(''motion'')')
set(hfig, 'windowbuttonupfcn',     'cameramenu(''up''    )')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCallbacks(hfig)
ret{1} = get(hfig, 'windowbuttondownfcn'   );
ret{2} = get(hfig, 'windowbuttonmotionfcn' );
ret{3} = get(hfig, 'windowbuttonupfcn'     );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restoreWindowCallbacks(hfig,cb)
set(hfig, 'windowbuttondownfcn',   cb{1});
set(hfig, 'windowbuttonmotionfcn', cb{2});
set(hfig, 'windowbuttonupfcn',     cb{3});


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret = getWindowCursor(hfig)
ret{1} = get(hfig, 'pointer'  );
ret{2} = get(hfig, 'pointershapecdata' );


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function restoreWindowCursor(hfig,cursor)
set(hfig, 'pointer'  ,         cursor{1});
set(hfig, 'pointershapecdata', cursor{2});

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=bool2OnOff(val)
if val
  ret = 'on';
else
  ret = 'off';
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ret=toggleOnOff(h)
newval = strcmp(get(h, 'checked'), 'off');
set(h, 'checked', bool2OnOff(newval));
if nargout>0
  ret = newval;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ticks(haxes,arg)

switch arg
  case 'off' 
    set(haxes, 'xtick', [], 'ztick', [], 'ytick', [])
  case 'on'
    set(haxes, 'xtickmode', 'a', 'ztickmode','a', 'ytickmode', 'a')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% simple cross product
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function c=crossSimple(a,b)
c(1) = b(3)*a(2) - b(2)*a(3);
c(2) = b(1)*a(3) - b(3)*a(1);
c(3) = b(2)*a(1) - b(1)*a(2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function resetCameraProps(haxes)
camva(haxes,'auto'); campos(haxes,'auto'); camtarget(haxes,'auto'); daspect(haxes,'auto'); camup(haxes,'auto'); 
view(haxes,3);
daspect(haxes,daspect(haxes)); camva(haxes,camva(haxes)); 
axis(haxes,'tight');
camproj(haxes,'perspective');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function val=iscameraobj(haxes)
% Checking if the selected axes is for a valid object to perform camera functions on.

if ~isa(handle(haxes),'graph2d.legend') && ~isa(handle(haxes),'graph3d.colorbar')
	val = true;
else
	val = false;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [hfig,haxes]=currenthandles
% Obtaining the correct handle to the current figure and axes in all cases:
% handlevisibility ON-gcbf; OFF-gcbf/gcf.

if ~isempty(gcbf)
	hfig=gcbf;
	haxes=get(gcbf,'CurrentAxes');
else
	hfig=gcf;
	haxes=gca;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The following are utility functions created to facilitate           % 
% internationalization                                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function coordsys = getCoordsys(obj)
% Get the coordsys, given the callback object

menuTag = get(obj, 'Tag');
switch menuTag
    case 'Cameramenu_MouseMode_X'
        coordsys = 'X';
    case 'Cameramenu_MouseMode_Y'
        coordsys = 'Y';
    case 'Cameramenu_MouseMode_Z'
        coordsys = 'Z';
    otherwise
        coordsys = 'Unconstrained';
end

function coordsysMenuLabel = getCoordsysMenuLabel(coordsys)
% Get the coordsys menu label, given the coordsys

switch coordsys
    case 'X'
        coordsysMenuLabel = getString(message('MATLAB:cameramenu:Label_X'));
    case 'Y'
        coordsysMenuLabel = getString(message('MATLAB:cameramenu:Label_Y'));
    case 'Z'
        coordsysMenuLabel = getString(message('MATLAB:cameramenu:Label_Z'));
    otherwise % unconstrained
        coordsysMenuLabel = getString(message('MATLAB:cameramenu:Label_Unconstrained'));
end

function projection = getCamproj(obj)
% Get the projection, given the callback object

menuTag = get(obj, 'Tag');
switch menuTag
    case 'Cameramenu_Axes_Perspective'
        projection = 'perspective';
    otherwise % orthographic
        projection = 'orthographic';
end

function renderer = getRenderer(obj)
% Get the renderer, given the callback object

menuTag = get(obj, 'Tag');
switch menuTag
    case 'Cameramenu_Renderer_Painters'
        renderer = 'Painters';
    case 'Cameramenu_Renderer_ZBuffer'
        renderer = 'Zbuffer';
    case 'Cameramenu_Renderer_OpenGL'
        renderer = 'OpenGL';
    otherwise % Auto
        renderer = 'Auto';
end

function colorStr = getColorStr(obj)
% Get the colorStr, given the callback object

menuTag = get(obj, 'Tag');
switch menuTag
    case 'Cameramenu_Axes_XColor'
        colorStr = 'XColor';
    case 'Cameramenu_Axes_YColor'
        colorStr = 'YColor';
    case 'Cameramenu_Axes_ZColor'
        colorStr = 'ZColor';
    otherwise % Walls color
        colorStr = 'color';
end

function mouseconstraint = getMouseconstraint(obj)
% Get the mouseconstraint, given the callback object

menuTag = get(obj, 'Tag');
switch menuTag
    case 'Cameramenu_MouseConstraint_Horizontal'
        mouseconstraint = 'Horizontal';
    case 'Cameramenu_MouseConstraint_Vertical'
        mouseconstraint = 'Vertical';
    otherwise % Unconstrained
        mouseconstraint = 'Unconstrained';
end

function mouseconstraintTag = getMouseconstraintTag(mouseconstraint)
% Get the mouseconstraint menu tag, given the constraint

switch mouseconstraint
    case 'Horizontal'
        mouseconstraintTag = 'Cameramenu_MouseConstraint_Horizontal';
    case 'Vertical'
        mouseconstraintTag = 'Cameramenu_MouseConstraint_Vertical';
    otherwise % Unconstrained
        mouseconstraintTag = 'Cameramenu_MouseConstraint_Unconstrained';
end

function camprojTag = getCamprojTag(projection)
% Get the camproj menu tag, given the projection

projection = lower(projection);
switch projection
    case 'perspective'
        camprojTag = 'Cameramenu_Axes_Perspective';
    otherwise % Orthographic
        camprojTag = 'Cameramenu_Axes_Orthographic';
end

function rendererTag = getRendererTag(renderer)
% Get the renderer menu tag, given the renderer 

renderer = lower(renderer);
switch renderer
    case 'painters'
        rendererTag = 'Cameramenu_Renderer_Painters';
    case 'zbuffer'
        rendererTag = 'Cameramenu_Renderer_ZBuffer';
    case 'opengl'
        rendererTag = 'Cameramenu_Renderer_OpenGL';
    otherwise % Might be "None" (which is indicated by not having any of 
              % the other options checked). 
        rendererTag = '';
end



