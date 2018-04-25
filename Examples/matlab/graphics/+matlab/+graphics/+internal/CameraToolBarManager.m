classdef CameraToolBarManager < handle
    %   Copyright 2013 The MathWorks, Inc.
    
    % UIComponents making up toolbar
    properties(Transient, Hidden)
        mainToolbarHandle matlab.graphics.Graphics
        PrincipalAxisHandles matlab.ui.container.toolbar.ToggleTool
        ModeHandles matlab.ui.container.toolbar.ToggleTool
        stopMovingHandle matlab.ui.container.toolbar.PushTool
    end
    
    properties(Transient, Hidden)
        mode char = ''
        coordsys char = 'z'
        
        time double = clock
        
        defaultAz double = 30
        defaultEl double = 30
        scenelights matlab.graphics.internal.SceneLight
    end
    
    % transitive properties
    properties(Transient, Hidden)
        CurrentObj matlab.graphics.Graphics
        
        figStartPoint(1,2) double
        figLastPoint(1,2) double
        figLastLastPoint(1,2) double
        buttondown = false;
        moving logical = false;
        
        wcb cell
        cursor cell
        buttonsDown double
    end
    
    % context menu properties
    properties(Transient, Hidden)
        doContext logical = false;
    end
    
    % toolbar creation functions
    methods
        function h=createToolbar(hObj, hfig)
            h = uitoolbar(hfig, 'HandleVisibility','off');
            props.Parent = h;
            hObj.mainToolbarHandle = h;
            load camtoolbarimages
            
            props.HandleVisibility = 'off';
            
            u = matlab.graphics.Graphics.empty;
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'orbit');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:OrbitCamera'));
            props.CData = camtoolbarimages.orbit;
            props.Tag = 'orbit';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'orbitscenelight');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:OrbitSceneLight'));
            props.CData = camtoolbarimages.orbitlight;
            props.Tag = 'orbitscenelight';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'pan');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:PanTiltCamera'));
            props.CData = camtoolbarimages.pan;
            props.Tag = 'pan';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'dollyhv');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:MoveCameraHorizontallyVertically'));
            props.CData = camtoolbarimages.hv;
            props.Tag = 'dollyhv';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'dollyfb');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:MoveCameraForwardBack'));
            props.CData = camtoolbarimages.fb;
            props.Tag = 'dollyfb';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'zoom');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:ZoomCamera'));
            props.CData = camtoolbarimages.zoom;
            props.Tag = 'zoom';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setmodegui(hObj, hfig, 'roll');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:RollCamera'));
            props.CData = camtoolbarimages.roll;
            props.Tag = 'roll';
            u(end+1) = uitoggletool(props);
            
            hObj.ModeHandles = u;
            
            u = matlab.graphics.Graphics.empty;
            props.ClickedCallback = @(~,~) setcoordsys(hObj, hfig, 'x');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:PrincipalAxisX'));
            props.CData = camtoolbarimages.x;
            props.Tag = 'x';
            u(end+1) = uitoggletool(props,...
                'Separator', 'on');
            
            props.ClickedCallback = @(~,~) setcoordsys(hObj, hfig, 'y');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:PrincipalAxisY'));
            props.CData = camtoolbarimages.y;
            props.Tag = 'y';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setcoordsys(hObj, hfig, 'z');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:PrincipalAxisZ'));
            props.CData = camtoolbarimages.z;
            props.Tag = 'z';
            u(end+1) = uitoggletool(props);
            
            props.ClickedCallback = @(~,~) setcoordsys(hObj, hfig, 'none');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:NoPrincipalAxis'));
            props.CData = camtoolbarimages.none;
            props.Tag = 'none';
            u(end+1) = uitoggletool(props);
            
            hObj.PrincipalAxisHandles = u;
            
            u = matlab.graphics.Graphics.empty;
            props.ClickedCallback = @(~,~) togglescenelight(hObj, hfig);
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:ToggleSceneLight'));
            props.CData = camtoolbarimages.light;
            props.Tag = 'togglescenelight';
            u(end+1) = uipushtool(props,...
                'Separator', 'on');
            
            props.ClickedCallback = @(~,~) setprojection(hObj, hfig, 'orthographic');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:OrthographicProjection'));
            props.CData = camtoolbarimages.ortho;
            props.Tag = 'orthographic';
            u(end+1) = uipushtool(props,...
                'Separator', 'on');
            
            props.ClickedCallback = @(~,~) setprojection(hObj, hfig, 'perspective');
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:PerspectiveProjection'));
            props.CData = camtoolbarimages.perspective;
            props.Tag = 'perspective';
            u(end+1) = uipushtool(props);
            
            
            props.ClickedCallback = @(~,~) resetcameraandscenelight(hObj, hfig);
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:ResetCameraAndSceneLight'));
            props.CData = camtoolbarimages.reset;
            props.Tag = 'reset';
            u(end+1) = uipushtool(props,...
                'Separator', 'on'); %#ok To do: Consider updating the button state for scene projection and lighting
            
            u = matlab.graphics.Graphics.empty;
            props.ClickedCallback = @(~,~) stopmoving(hObj);
            props.ToolTip = getString(message('MATLAB:uistring:cameratoolbar:StopCameraLightMotion'));
            props.CData = camtoolbarimages.stop;
            props.Tag = 'stopmoving';
            u(end+1) = uipushtool(props);
            
            hObj.stopMovingHandle = u;
            
            set(hObj.mainToolbarHandle, 'Tag', 'CameraToolBar', 'Visible', 'off','serializable','off');
        end
        
        function delete(hObj)
            if ~isempty(hObj.mainToolbarHandle) && isvalid(hObj.mainToolbarHandle)
                delete(hObj.mainToolbarHandle)
            end
        end
        
        function updateToolbar(hObj, hfig)
            set(hObj.ModeHandles, 'State', 'off')
            set(findall(hObj.ModeHandles, 'Tag', hObj.mode), 'State', 'on');
            
            set(hObj.PrincipalAxisHandles, 'State', 'off', 'Enable', 'on')
            if ~isempty(hObj.mode) & strmatch(hObj.mode, {'orbit' 'pan' 'walk'}) %#ok
                set(findall(hObj.PrincipalAxisHandles, 'Tag', hObj.coordsys), 'State', 'on');
            else
                set(hObj.PrincipalAxisHandles, 'Enable', 'off');
            end
            
            if ~isempty(hObj.mode)
                initWindowCallbacks(hObj, hfig);
            end
        end
    end

    % set and restore window callbacks and pointer
    methods
        function ret = getWindowCallBacks(~,hfig)
            ret{1} = get(hfig, 'WindowButtonDownFcn'   );
            %Two is reserved for motion function
            ret{3} = get(hfig, 'WindowButtonUpFcn'     );
            ret{4} = get(hfig, 'KeyPressFcn'           );
        end
        
        function ret = getWindowCursor(~,hfig)
            ret{1} = get(hfig, 'Pointer'  );
            ret{2} = get(hfig, 'PointerShapeCData' );
        end
        
        function initWindowCallbacks(hObj,hfig)
            set(hfig, 'UIModeEnabled', 'on');
            set(hfig, 'WindowButtonDownFcn',   @(~,evd) down_callback(hObj,hfig, evd, true));
            set(hfig, 'WindowButtonUpFcn',     [])
            %set(hfig, 'WindowButtonMotionFcn', [])
            set(hfig, 'KeyPressFcn',           @(~,~) keypress_callback(hObj,hfig));
        end
        
        function restoreWindowCallbacks(hObj,hfig)
            cb = hObj.wcb;
            set(hfig, 'UIModeEnabled', 'off');
            set(hfig, 'WindowButtonDownFcn',   cb{1});
            %Two is reserved for motion function
            set(hfig, 'WindowButtonUpFcn',     cb{3});
            set(hfig, 'KeyPressFcn',           cb{4});
            
        end
        
        function restoreWindowCursor(hObj,hfig)
            c = hObj.cursor;
            set(hfig, 'Pointer'  ,         c{1});
            set(hfig, 'PointerShapeCData', c{2});
        end
        
        function ret=bool2OnOff(~,val)
            if val
                ret = 'on';
            else
                ret = 'off';
            end
        end
    end
    
    % scenelights
    methods
        function validateScenelights(hObj,haxes)
            sl = hObj.scenelights;

            if isempty(sl)
                index = [];
            else
                % remove invalid axes and lights
                index = ~ishghandle([sl.ax]); 
                delete(sl(index));
                sl(index) = [];
                
                index = ~ishghandle([sl.h]);
                delete(sl(index));
                sl(index) = [];
                
                index = find([sl.ax]==haxes);
            end
            
            %We may have additional lights in the scene which have not yet been linked
            adds = findall(haxes,'Type','light');
            
            
            if isempty(index)
                if ~isempty(adds)
                    % new axes with existing light
                    [az, el] = lightangle(adds(1));
                    newsl = matlab.graphics.internal.SceneLight;
                    newsl.ax = haxes;
                    newsl.h = adds(1);
                    newsl.on = adds(1).Visible;
                    newsl.az = az;
                    newsl.el = el;
                    sl = [sl newsl];
                else
                    % new axes with no existing light
                    newsl = matlab.graphics.internal.SceneLight;
                    newsl.ax = haxes;
                    newsl.az = hObj.defaultAz;
                    newsl.el = hObj.defaultEl;
                    newh = light('parent',haxes);
                    set(newh, 'Visible', 'off', 'HandleVisibility', 'off', ...
                        'Tag', 'CameraToolBarScenelight');
                    newsl.h = newh;
                    sl = [sl newsl];
                end
            else
                % we have stored this axes before and we must have found a
                % light on stored axes and it must be valid
            end
            hObj.scenelights = sl;
        end
        
        function updateScenelightPosition(hObj,haxes)
            sl = hObj.scenelights;
            ax = haxes;
            
            sl = sl([sl.ax]==ax);
            if ~isempty(sl) && any(sl.on)
                set(sl.h,'Style','infinite');
                lightangle(sl.h, sl.az, sl.el);
            end
        end
        
        function updateScenelightOnOff(hObj,haxes,val)
            sl = hObj.scenelights;
            ax = haxes;
            index = find([sl.ax]==ax);
            
            sl(index).on = bool2OnOff(hObj,val);
            set(sl(index).h, 'Visible', bool2OnOff(hObj,val))
        end
        
        function resetScenelight(hObj,haxes)
            validateScenelights(hObj,haxes)
            
            sl = hObj.scenelights;
            ax = haxes;
            index = find([sl.ax]==ax);
            
            sl(index).az = hObj.defaultAz;
            sl(index).el = hObj.defaultEl;
            
            updateScenelightPosition(hObj,haxes);
        end
        
        function resetScenelightIfValid(hObj,hfig)
            haxes = hfig.CurrentAxes;
            if matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                resetScenelight(hObj,haxes);
            end
        end
    end
    
    % callbacks
    methods
        function down_callback(hObj, hfig, evd, set_motion_fcn)
            
            %Increment the number of buttons down. If the result is not 1, return.
            hObj.buttonsDown = hObj.buttonsDown+1;
            sel_type = get(hfig,'SelectionType');
            if (hObj.buttonsDown ~=1)
                if strcmpi(sel_type,'extend')
                    return;
                else
                    %We are in a bad state. Restore the original motion function before
                    %we get into trouble:
                    hObj.buttonsDown = 1;
                    %Restore motion function
                    set(hfig,'WindowButtonMotionFcn',hObj.wcb{2});
                end
            end
            if hObj.doContext
                restoreCallbacks(hObj,hfig);
            end
            
            % Get the hit object
            if isobject(evd)
                h = evd.HitObject;
                if isprop(evd,'HitPrimitive') && isequal(evd.HitObject,evd.HitPrimitive)
                    %     If the first ancestor with hittest on is the primitive itself, the
                    %     user may have hit a primitive brushing decoration. In this case,
                    %     return the first Pickable with HitTest on,
                    h = matlab.graphics.chart.internal.ChartHelpers.getPickableAncestor(evd.HitPrimitive);
                end
            else
                h = hittest(hfig);
            end
            
            % If we clicked on a UIControl object or a datatip, return
            if ishghandle(h,'uicontrol') || isa(h,'matlab.graphics.shape.internal.ScribePeer')
                if strcmpi(sel_type,'alt')
                    hObj.buttonsDown = hObj.buttonsDown - 1;
                end
                return
            end
            
            %Disable any button functions on the object we clicked on and register
            %the context menu
            hObj.CurrentObj = h;
            if isprop(h,'ButtonDownFcn')
                hObj.CurrentObj.ButtonDownFcn = get(h,'ButtonDownFcn');
                set(h,'ButtonDownFcn',[]);
            end
            
            %Disable the window button motion function
            hObj.wcb{2} = get(hfig,'WindowButtonMotionFcn');
            set(hfig,'WindowButtonMotionFcn',[]);
            
            if strcmp(sel_type,'alt')
                hObj.buttonsDown = hObj.buttonsDown - 1;
                hObj.CurrentObj.UIContextMenu = get(h,'UIContextMenu');
                set(h,'UIContextMenu',[]);
                hObj.doContext = true;
            end
            
            cp = hfig.CurrentPoint;
            pt = matlab.graphics.interaction.internal.getPointInPixels(hfig,cp(1:2));
            hObj.figStartPoint = pt;
            hObj.figLastPoint  = pt;
            hObj.figLastLastPoint = pt;
            hObj.buttondown = 1;
            hObj.moving = false;
            
            haxes = hfig.CurrentAxes;
            if ~matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                hObj.buttonsDown = hObj.buttonsDown - 1;
                hObj.buttonsDown = max(hObj.buttonsDown,0);
                set(hfig,'WindowButtonMotionFcn',hObj.wcb{2});
                return
            end
            
            % Register the button up function:
            set(hfig, 'WindowButtonUpFcn', @(f,~)up_callback(hObj, f, haxes));
            
            %can call with cameratoolbar('down',0/1) to prohibit setting of windowbuttonfcn's
            switch get(hfig,'SelectionType')
                case 'alt'
                    postContextMenu(hObj,hfig,haxes);
                otherwise
                    axis(haxes,'vis3d');
                    validateScenelights(hObj,haxes)
                    %updateScenelightOnOff(haxes,Udata.scenelightOn);
                    if ~(islogical(set_motion_fcn) && ~set_motion_fcn)
                        set(hfig, 'WindowButtonMotionFcn', @(~,~) motion_callback(hObj, hfig, haxes))
                    end
            end
        end
        
        function motion_callback(hObj, hfig, haxes)
            currpt = get(hfig,'CurrentPoint');
            pt = matlab.graphics.interaction.internal.getPointInPixels(hfig,currpt(1:2));
            deltaPix  = pt-hObj.figLastPoint;
            hObj.figLastLastPoint = hObj.figLastPoint;
            hObj.figLastPoint = pt;
            
            hObj.time = clock;
            currentmode = lower(hObj.mode);
            
            % Now perform the desired event from the rotation.
            switch currentmode
                case 'orbit'
                    orbitPangca(hObj,haxes,deltaPix, 'o');
                case 'orbitscenelight'
                    orbitLightgca(hObj,haxes,deltaPix);
                case 'pan'
                    orbitPangca(hObj,haxes,deltaPix, 'p');
                case 'dollyhv'
                    dollygca(hObj,haxes,deltaPix);
                case 'zoom'
                    zoomgca(hObj,haxes,deltaPix);
                case 'dollyfb'
                    forwardBackgca(hObj,haxes,deltaPix);
                case 'roll'
                    rollgca(hObj,haxes,deltaPix, pt);
            end
        end
        
        function up_callback(hObj, hfig,haxes)
            %Check for multiple buttons down
            hObj.buttonsDown = hObj.buttonsDown - 1;
            hObj.buttonsDown = max(hObj.buttonsDown,0);
            if hObj.buttonsDown ~=0
                return;
            end
            %set(hfig, 'WindowButtonMotionFcn', [])
            set(hfig, 'WindowButtonUpFcn', [])
            %Restore any button functions on the object we clicked on and unregister
            %the context menu
            
            if isprop(hObj.CurrentObj,'ButtonDownFcn')
                set(hObj.CurrentObj,'ButtonDownFcn',hObj.CurrentObj.ButtonDownFcn);
            end
            
            %Restore the window button motion function
            set(hfig,'WindowButtonMotionFcn',hObj.wcb{2});
            hObj.buttondown = 0;
            hObj.moving   = false;
            
            curr_pt = get(hfig,'CurrentPoint');
            pt = matlab.graphics.interaction.internal.getPointInPixels(hfig,curr_pt);
            
            deltaPix  = pt-hObj.figLastLastPoint;
            deltaPixStart  = pt-hObj.figStartPoint;
            hObj.figLastPoint = pt;
            % Checking the sensitivity of the camera throw mode w.r.t mouse events
            % Speed at the end being proportional to the dist traveled at the end...
            speed_sense = sqrt((deltaPix(1)^2)+(deltaPix(2)^2));
            % Total distance traveled from start to finish:
            dist_sense = sqrt((deltaPixStart(1)^2)+(deltaPixStart(2)^2));
            % Scaling down the speed of motion in the throw mode
            currentmode = lower(hObj.mode);
            clear walk_flag;
            
            % Scale down the deltas to get a reasonable speed.
            scaled_deltaPix = deltaPix/10;
            if etime(clock, hObj.time)<.5 && (speed_sense>=7) && (dist_sense>30) ...
                    && any(deltaPix) && ~strcmp('alt', get(hfig, 'SelectionType'))
                hObj.moving = true;
                switch currentmode
                    case 'orbit'
                        orbitPangca(hObj,haxes,scaled_deltaPix, 'o');
                    case 'orbitscenelight'
                        orbitLightgca(hObj,haxes,scaled_deltaPix);
                    case 'pan'
                        orbitPangca(hObj,haxes,scaled_deltaPix, 'p');
                        %case 'roll'
                        %rollgca(haxes,deltaPix);
                end
            end
        end
        
        function keymotion_callback(hObj, hfig, haxes, amount)
            down_callback(hObj, hfig, [], false)
            if ~isempty(hObj.figLastPoint)
                if (etime(clock,hObj.time))<.3
                    multFact=20;  %should rotate faster when the key is held down
                else
                    multFact=5;
                end
                newPoint = hObj.figLastLastPoint + multFact*amount;
                % Make sure the new point is in figure units:
                tempVar = hgconvertunits(hfig,[newPoint 0 0],'pixels',...
                    get(hfig,'Units'),get(hfig,'Parent'));
                newPoint = tempVar(1:2);
                set(hfig,'CurrentPoint',newPoint);
                
                motion_callback(hObj, hfig, haxes);
                up_callback(hObj, hfig, haxes);
            end
        end
        
        function keypress_callback(hObj, hfig)
            haxes = hfig.CurrentAxes;
            if ~matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                return;
            end
            
            switch get(hfig,'CurrentCharacter')
                case 'o'
                    setmode(hObj, hfig, 'orbit');
                case 'l'
                    setmode(hObj, hfig, 'orbitscenelight');
                case 'p'
                    setmode(hObj, hfig, 'pan');
                case 'd'
                    setmode(hObj, hfig, 'dollyhv');
                case 'z'
                    setmode(hObj, hfig, 'zoom');
                case 'r'
                    setmode(hObj, hfig, 'roll');
                case 'D'
                    setmode(hObj, hfig, 'dollyfb');
                case char(28) %left
                    keymotion_callback(hObj, hfig, haxes, [-1  0]);
                case char(29) %right
                    keymotion_callback(hObj, hfig, haxes, [ 1  0]);
                case char(30) %up
                    keymotion_callback(hObj, hfig, haxes, [ 0  1]);
                case char(31) %down
                    keymotion_callback(hObj, hfig, haxes, [ 0 -1]);
            end
        end
    end
    
    % perform cameratoolbar drag operations
    methods
        function orbitPangca(hObj,haxes,xy, mode)
            %mode = 'o';  orbit
            %mode = 'p';  pan
            
            coordsystem = lower(hObj.coordsys);
            if coordsystem(1)=='n'
                coordsysval = 0;
            else
                coordsysval = coordsystem(1) - 'x' + 1;
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
                if any(matlab.graphics.internal.CameraToolBarManager.crossSimple(d,campos(haxes)-camtarget(haxes)))
                    camup(haxes,d)
                end
            end
            
            flag = 1;
            
            while sum(abs(xy))> 0 && (flag || hObj.moving) && ishghandle(haxes)
                flag = 0;
                if ishghandle(haxes)
                    if mode=='o' %orbit
                        if coordsysval==0 %unconstrained
                            camorbit(haxes,xy(1), xy(2), coordsystem)
                        else
                            camorbit(haxes,xy(1), xy(2), 'data', coordsystem)
                        end
                    else %pan
                        if coordsysval==0 %unconstrained
                            campan(haxes,panxy(1), panxy(2), coordsystem)
                        else
                            campan(haxes,panxy(1), panxy(2), 'data', coordsystem)
                        end
                    end
                    updateScenelightPosition(hObj,haxes);
                    localDrawnow(hObj);
                end
            end
        end
        
        function orbitLightgca(hObj,haxes,xy)
            sl = hObj.scenelights;
            ax = haxes;
            index = find([sl.ax]==ax);
            
            if sum(abs(xy))> 0 && ~strcmp(sl(index).on,'on')
                updateScenelightOnOff(hObj,haxes,1);
            end
            
            % Check if the light is on the other side of the object
            az = mod(abs(sl(index).az),360);
            if az > 90 && az < 270
                xy(2) = -xy(2);
            end
            
            flag = 1;
            
            while sum(abs(xy))> 0 && (flag || hObj.moving) && ishghandle(haxes)
                flag = 0;
                az = sl(index).az;
                el = sl(index).el;
                
                az = mod(az + xy(1), 360);
                el = mod(el + xy(2), 360);
                
                if abs(el) > 90
                    el = 180 - el;
                    az = 180 + az;
                    xy(2) = -xy(2);
                end
                
                sl(index).az = az;
                sl(index).el = el;
                
                updateScenelightPosition(hObj,haxes);
                localDrawnow(hObj);
            end
        end
        
        function dollygca(hObj,haxes,xy)
            camdolly(haxes,-xy(1), -xy(2), 0, 'movetarget', 'pixels')
            updateScenelightPosition(hObj,haxes);
            localDrawnow(hObj);
        end
        
        function zoomgca(hObj,haxes,xy)
            
            q = max(-.9, min(.9, sum(xy)/70));
            q = 1+q;
            
            % heuristic avoids small view angles which will crash on Solaris
            MIN_VIEW_ANGLE = .001;
            MAX_VIEW_ANGLE = 75;
            vaOld = camva(haxes);
            camzoom(haxes,q);
            va = camva(haxes);
            %If the act of zooming puts us at an extreme, back the zoom out
            if ~((q>1 || va<MAX_VIEW_ANGLE) && (va>MIN_VIEW_ANGLE))
                set(haxes,'CameraViewAngle',vaOld);
            end
            
            localDrawnow(hObj);
        end
        
        function forwardBackgca(hObj,haxes,xy)
            
            q = max(-1, min(1, sum(xy)/250));
            
            % Get camera position and camera target in normalized
            % coordinates (not data coordinates) so that the distance
            % between the two can be used as a heuristic
            normpos = haxes.Camera.Position;
            normtar = haxes.Camera.Target;
            if strcmp(haxes.PlotBoxAspectRatioMode,'manual')
                normpos = normpos./haxes.PlotBoxAspectRatio;
                normtar = normtar./haxes.PlotBoxAspectRatio;
            end
            
            dist = norm(normpos - normtar);
            % If we are already too far out, don't do the operation.  We
            % cannot do the operation first and then undo it because then
            % the CameraPosition will oscillate. Don't zoom if we are too
            % far away and trying to zoom out or if we are too close and
            % trying to zooming in. 
            if ~(dist > 80 && q < 0) && ~(dist < -1 && q > 0)
                camdolly(haxes,0,0,q, 'fixtarget');
                drawnow;
            end
            
            updateScenelightPosition(hObj,haxes);
            localDrawnow(hObj);
        end
        
        function rollgca(hObj,haxes,dxy, pt)
            % find the pixel center of the axes
            pos = getpixelposition(haxes);
            center = pos(1:2)+pos(3:4)/2;
            
            startpt = pt - dxy;
            
            v1 = pt-center;
            v2 = startpt-center;
            
            v1 = v1/norm(v1);
            v2 = v2/norm(v2);
            theta = acos(sum(v2.*v1)) * 180/pi;
            cross =  matlab.graphics.internal.CameraToolBarManager.crossSimple([v1 0],[v2 0]);
            if cross(3) >0
                theta = -theta;
            end
            
            flag = 1;
            
            while (flag || hObj.moving) && ishghandle(haxes)
                flag = 0;
                camroll(haxes,theta);
                updateScenelightPosition(hObj,haxes);
                localDrawnow(hObj);
            end
        end
    end
    
    % cameratoolbar mode helpers
    methods
        function setmode(hObj, hfig, newmode)
            axHandles = findobj(hfig, 'Type', 'axes');
            resetplotview(axHandles,'InitializeCurrentView');
            if isempty(hObj.mode)
                hObj.wcb = getWindowCallBacks(hObj, hfig);
                hObj.cursor = getWindowCursor(hObj, hfig);
            end
            if strcmp(newmode, 'nomode')
                nomode(hObj,hfig);
            else
                scribeclearmode(hfig, @hObj.nomode, hfig);
                hObj.mode = newmode;
                hObj.wcb = getWindowCallBacks(hObj, hfig);
                hObj.cursor = getWindowCursor(hObj, hfig);
                %Keep track of the number of buttons down.
                hObj.buttonsDown = 0;
                updateToolbar(hObj, hfig)
            end
        end
        
        function setmodegui(hObj, hfig, newmode)
            %setmodegui differs from setmode in that setting the same
            %mode as the current mode will toggle it off
            if strcmp(hObj.mode, newmode)
                nomode(hObj,hfig);
                updateToolbar(hObj, hfig);
            else
                setmode(hObj, hfig, newmode);
            end
            matlab.graphics.internal.CameraToolBarManager.showInfoDlg;
        end
        
        function setcoordsys(hObj, hfig, newcoordsys)
            haxes = hfig.CurrentAxes;
            if ~matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                return;
            end
            
            axHandles = findobj(hfig, 'Type', 'axes');
            resetplotview(axHandles,'InitializeCurrentView');
            hObj.coordsys = newcoordsys;
            if ishghandle(haxes,'axes')
                if length(hObj.coordsys)==1
                    coordsysval =  lower(hObj.coordsys) - 'x' + 1;
                    
                    d = [0 0 0];
                    d(coordsysval) = 1;
                    
                    up = camup(haxes);
                    if up(coordsysval) < 0
                        d = -d;
                    end
                    
                    % Check if the camera up vector is parallel with the view direction;
                    % if not, set the up vector
                    if any(matlab.graphics.internal.CameraToolBarManager.crossSimple(d,campos(haxes)-camtarget(haxes)))
                        camup(haxes,d)
                        validateScenelights(hObj,haxes)
                        updateScenelightPosition(hObj,haxes);
                    end
                end
            end
            updateToolbar(hObj,hfig)
        end
        
        function nomode(hObj,hfig)
            hObj.mode = '';
            if ~isempty(hObj.wcb)
                restoreWindowCallbacks(hObj,hfig);
                restoreWindowCursor(hObj,hfig);
            end
            updateToolbar(hObj,hfig)
            removeContextMenu(hObj,hfig);
            %Edge case: If we right-click on an object and then click to change
            %modes without executing the context-menu functions.
            if hObj.doContext && ~isempty(hObj.CurrentObj)
                set(hObj.CurrentObj,'UIContextMenu',hObj.CurrentObj.UIContextMenu);
                set(hObj.CurrentObj,'ButtonDownFcn',hObj.CurrentObj.ButtonDownFcn);
            end
        end
        
        function stopmoving(hObj)
            hObj.moving = false;
        end
        
        function setprojection(~,hfig, proj)
            haxes = hfig.CurrentAxes;
            if matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                camproj(haxes,lower(proj));
            end
        end
        
        function resettarget(hObj,hfig)
            haxes = hfig.CurrentAxes;
            if matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                camtarget(haxes,'auto');
                validateScenelights(hObj,haxes)
                updateScenelightPosition(hObj,haxes);
            end
        end
        
        function resetCameraProps(hObj,haxes)
            hObj.buttonsDown = 0;
            resetplotview(haxes,'ApplyStoredView');
        end
        
        function resetcameraandscenelight(hObj,hfig)
            haxes = hfig.CurrentAxes;
            if matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                resetCameraProps(hObj,haxes)
                resetScenelight(hObj,haxes);
            end
        end
        
        function togglescenelight(hObj,hfig)
            haxes = hfig.CurrentAxes;
            if ~matlab.graphics.internal.CameraToolBarManager.isValid3DAxes(haxes)
                return;
            end
            
            validateScenelights(hObj,haxes)
            sl = hObj.scenelights;
            ax = haxes;
            if isempty(sl)
                val = 1;
            else
                val = ~strcmp(sl([sl.ax]==ax).on,'on');
            end
            
            if ~val && strcmp(hObj.mode, 'orbitscenelight')
                hObj.mode = 'orbit';
                updateToolbar(hObj,hfig)
            end
            updateScenelightOnOff(hObj,haxes,val);
            updateScenelightPosition(hObj,haxes);
        end
        
        function localDrawnow(hObj)
            % Calling drawnow will result in hang (see g201318 and g645555)
            if hObj.moving
                drawnow;
            else
                drawnow expose
            end
        end
    end

    % Contextmenu
    methods
        function removeContextMenu(~,hfig)
            menuTag='CameratoolbarContextMenu';
            h = findall(hfig,'Type','UIContextMenu','Tag',menuTag);
            delete(h);
        end
        
        function h=postContextMenu(hObj,hfig,haxes)
            
            menuTag='CameratoolbarContextMenu';
            
            h = findall(hfig,'Type','uicontextmenu','Tag',menuTag);
            if isempty(h)
                h=uicontextmenu('Parent',hfig,...
                    'HandleVisibility','off',...
                    'Tag',menuTag);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:CameraMotion'));
                props.Parent = h;
                props.Separator = 'off';
                props.Tag = 'CameraMotionMode';
                props.Callback = '';
                cM = uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:OrbitCamera'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_orbit';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'orbit'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:OrbitSceneLight'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_orbitscenelight';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'orbitscenelight'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:PanTurnTilt'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_pan';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'pan'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:MoveHorizontallyVertically'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_dollyhv';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'dollyhv'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:MoveForwardBack'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_dollyfb';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'dollyfb'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:Zoom_1'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_zoom';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'zoom'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:Roll_1'));
                props.Parent = cM;
                props.Separator = 'off';
                props.Tag = 'CameraMode_roll';
                props.Callback = {@hObj.localUICallback,@setmodegui,{hObj,hfig,'roll'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:CameraAxes'));
                props.Parent = h;
                props.Separator = 'off';
                props.Tag = 'CameraPAx';
                props.Callback = '';
                cA = uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:XPrincipalAxis'));
                props.Parent = cA;
                props.Separator = 'off';
                props.Tag = 'CameraAxis_x';
                props.Callback = {@hObj.localUICallback,@setcoordsys,{hObj,hfig,'x'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:YPrincipalAxis'));
                props.Parent = cA;
                props.Separator = 'off';
                props.Tag = 'CameraAxis_y';
                props.Callback = {@hObj.localUICallback,@setcoordsys,{hObj,hfig,'y'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:ZPrincipalAxis'));
                props.Parent = cA;
                props.Separator = 'off';
                props.Tag = 'CameraAxis_z';
                props.Callback = {@hObj.localUICallback,@setcoordsys,{hObj,hfig,'z'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:NoPrincipalAxis'));
                props.Parent = cA;
                props.Separator = 'off';
                props.Tag = 'CameraAxis_none';
                props.Callback = {@hObj.localUICallback,@setcoordsys,{hObj,hfig,'none'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:CameraReset'));
                props.Parent = h;
                props.Separator = 'off';
                props.Tag = 'CameraReset_parent';
                props.Callback = '';
                cR = uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:ResetCameraSceneLight'));
                props.Parent = cR;
                props.Separator = 'off';
                props.Tag = 'CameraReset_camera_scene_light';
                props.Callback = {@hObj.localUICallback,@resetcameraandscenelight,{hObj,hfig},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:ResetTargetPoint'));
                props.Parent = cR;
                props.Separator = 'off';
                props.Tag = 'CameraReset_target_point';
                props.Callback = {@hObj.localUICallback,@resettarget,{hObj,hfig},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:ResetSceneLight'));
                props.Parent = cR;
                props.Separator = 'off';
                props.Tag = 'CameraReset_scene_light';
                props.Callback = {@hObj.localUICallback,@resetScenelightIfValid,{hObj,hfig},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:Projection'));
                props.Parent = h;
                props.Separator = 'on';
                props.Tag = 'CameraProj';
                props.Callback = '';
                cP = uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:Orthographic'));
                props.Parent = cP;
                props.Separator = 'off';
                props.Tag = 'CameraProj_orthographic';
                props.Callback = {@hObj.localUICallback,@setprojection,{hObj,hfig,'orthographic'},hfig};
                uimenu(props);
                
                props = [];
                props.Label = getString(message('MATLAB:uistring:cameratoolbar:Perspective'));
                props.Parent = cP;
                props.Separator = 'off';
                props.Tag = 'CameraProj_perspective';
                props.Callback = {@hObj.localUICallback,@setprojection,{hObj,hfig,'perspective'},hfig};
                uimenu(props);
                
            else
                h=h(1);
            end
            
            %initialize camera motion mode check
            hCameraMotion=findobj(h,'Tag','CameraMotionMode');
            hCameraMotionChildren=get(hCameraMotion,'Children');
            set(hCameraMotionChildren,'Checked','off');
            hCameraMotionTarget=findobj(hCameraMotionChildren,'Tag',['CameraMode_' hObj.mode]);
            set(hCameraMotionTarget,'Checked','on');
            
            %initialize camera principal axis check
            paxParent=findall(h,'Tag','CameraPAx');
            paxItems=allchild(paxParent);
            offon={'off','on'};
            isActive=ismember(hObj.mode, {'orbit' 'pan' 'walk'});
            set(paxItems,'Checked','off','Enable',offon{isActive+1});
            
            if isActive
                currPAx=hObj.coordsys;
                activeItem=findall(paxItems,'Tag',['CameraAxis_' currPAx]);
                set(activeItem,'Checked','on');
            end
            
            %initialize projection
            projParent =  findall(h,'Tag','CameraProj');
            projItems=allchild(projParent);
            set(projItems,'Checked','off');
            activeItem=findall(projItems,'Tag',['CameraProj_' get(haxes,'projection')]);
            set(activeItem,'Checked','on');
            
            %initialize axis vis3d item
            if strcmp(get(haxes,'warptofill'),'off')
                check='off';
                cbk={@hObj.localUICallback,@axis,{haxes,'normal'},hfig};
            else
                check='on';
                cbk={@hObj.localUICallback,@axis,{haxes,'vis3d'},hfig};
            end
            vis3dItem=findall(h,'Tag','CameraBash');
            set(vis3dItem,'Checked',check,'Callback',cbk);
            
            %post menu==========================
            if isprop(hObj.CurrentObj,'UIContextMenu')
                set(hObj.CurrentObj,'UIContextMenu',h);
            end
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function localUICallback(hObj,~,~,fun,params,hfig)
            %Evaluate callback function:
            fun(params{:});
            %Restore Window motion function and callbacks:
            restoreCallbacks(hObj,hfig);
        end
        
        function restoreCallbacks(hObj,hfig)
            if ~isempty(hObj.CurrentObj)
                set(hObj.CurrentObj,'UIContextMenu',hObj.CurrentObj.UIContextMenu);
                if isprop(hObj.CurrentObj,'ButtonDownFcn')
                    set(hObj.CurrentObj,'ButtonDownFcn',hObj.CurrentObj.ButtonDownFcn);
                end
            end
            %Restore motion function
            set(hfig,'WindowButtonMotionFcn',hObj.wcb{2});
            hObj.doContext = false;
        end
    end
    
    % helpers
    methods(Static)
        function ret = isValid3DAxes(haxes)
            % Check for empty, invalid, polar and yyaxis
            ret = false;
            if ~isempty(haxes) && ishghandle(haxes) && ...
                    ~isa(haxes,'matlab.graphics.axis.PolarAxes') && ...
                    ~isa(haxes,'matlab.graphics.chart.Chart') && ...
                    numel(haxes.YAxis) == 1  % this check must be AFTER polar since it does not have a YAxis
                
                ret = true;
            end
        end
        
        function c=crossSimple(a,b)
            c(1) = b(3)*a(2) - b(2)*a(3);
            c(2) = b(1)*a(3) - b(3)*a(1);
            c(3) = b(2)*a(1) - b(1)*a(2);
        end
        
        function dlgShown = showInfoDlg
            persistent CameratoolbarInfoDialogShown
            
            if isempty(CameratoolbarInfoDialogShown)
                CameratoolbarInfoDialogShown=0;
            end
            
            if ~CameratoolbarInfoDialogShown
                CameratoolbarInfoDialogShown=1;
                [~,dlgShown]=uigetpref('cameratoolbar','donotshowinfodlg',...
                    getString(message('MATLAB:uistring:cameratoolbar:PreferenceDialogHeading')),...
                    sprintf(getString(message('MATLAB:uistring:cameratoolbar:PreferenceDialog'))),...
                    {'Ok'; getString(message('MATLAB:uistring:cameratoolbar:Ok'))},...
                    'DefaultButton','Ok',...
                    'HelpString',getString(message('MATLAB:uistring:cameratoolbar:Help')),...
                    'HelpFcn','helpview(fullfile(docroot,''matlab'',''helptargets.map''), ''axes_aspect_ratio'',''CSHelpWindow'',gcbf)',...
                    'DialogProps',struct('WindowStyle','modal'));
            else
                dlgShown=0;
            end
        end
    end
end