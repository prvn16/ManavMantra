%ZOOM   Zoom in and out on a 2-D plot.
%   ZOOM with no arguments toggles the zoom state.
%   ZOOM(FACTOR) zooms the current axis by FACTOR.
%       Note that this does not affect the zoom state.
%   ZOOM ON turns zoom on for the current figure.
%   ZOOM XON or ZOOM YON turns zoom on for the x or y axis only.
%   ZOOM OFF turns zoom off in the current figure.
%
%   ZOOM RESET resets the zoom out point to the current zoom.
%   ZOOM OUT returns the plot to its current zoom out point.
%   If ZOOM RESET has not been called this is the original
%   non-zoomed plot.  Otherwise it is the zoom out point
%   set by ZOOM RESET.
%
%   When zoom is on, click the left mouse button to zoom in on the
%   point under the mouse. Each time you click, the axes limits will be
%   changed by a factor of 2 (in or out).  You can also click and drag
%   to zoom into an area. It is not possible to zoom out beyond the plots'
%   current zoom out point.  If ZOOM RESET has not been called the zoom
%   out point is the original non-zoomed plot.  If ZOOM RESET has been
%   called the zoom out point is the zoom point that existed when it
%   was called. Double clicking zooms out to the current zoom out point -
%   the point at which zoom was first turned on for this figure
%   (or to the point to which the zoom out point was set by ZOOM RESET).
%   Note that turning zoom on, then off does not reset the zoom out point.
%   This may be done explicitly with ZOOM RESET.
%
%   ZOOM(FIG,OPTION) applies the zoom command to the figure specified
%   by FIG. OPTION can be any of the above arguments.
%
%   H = ZOOM(FIG) returns the figure's zoom mode object for customization.
%        The following properties can be modified:
%
%        ButtonDownFilter <function_handle>
%        The application can inhibit the zoom operation under circumstances
%        the programmer defines, depending on what the callback returns. 
%        The input function handle should reference a function with two 
%        implicit arguments (similar to handle callbacks):
%        
%             function [res] = myfunction(obj,event_obj)
%             % OBJ        handle to the object that has been clicked on.
%             % EVENT_OBJ  handle to event object (empty in this release).
%             % RES        a logical flag to determine whether the zoom
%                          operation should take place or the 
%                          'ButtonDownFcn' property of the object should 
%                          take precedence.
%
%        ActionPreCallback <function_handle>
%        Set this callback to listen to when a zoom operation will start.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object.
%
%             The event object has the following read only 
%             property:
%             Axes             The handle of the axes that is being zoomed.
%
%        ActionPostCallback <function_handle>
%        Set this callback to listen to when a zoom operation has finished.
%        The input function handle should reference a function with two
%        implicit arguments (similar to handle callbacks):
%
%            function myfunction(obj,event_obj)
%            % OBJ         handle to the figure that has been clicked on.
%            % EVENT_OBJ   handle to event object. The object has the same
%                          properties as the EVENT_OBJ of the
%                          'ModePreCallback' callback.
%
%        Enable  'on'|{'off'}
%        Specifies whether this figure mode is currently 
%        enabled on the figure.
%
%        FigureHandle <handle>
%        The associated figure handle. This property supports GET only.
%
%        Motion 'horizontal'|'vertical'|{'both'}
%        The type of zooming for the figure.
%
%        Direction {'in'}|'out'
%        The direction of the zoom operation.
%
%        RightClickAction 'InverseZoom'|{'PostContextMenu'}
%        The behavior of a right-click action. A value of 'InverseZoom' 
%        will cause a right-click to zoom out. A value of 'PostContextMenu'
%        will display a context menu. This setting will persist between 
%        MATLAB sessions.
%
%        UIContextMenu <handle>
%        Specifies a custom context menu to be displayed during a
%        right-click action. This property is ignored if the
%        'RightClickAction' property has been set to 'InverseZoom'.
%
%   FLAGS = isAllowAxesZoom(H,AXES)
%       Calling the function ISALLOWAXESZOOM on the zoom object, H, with a
%       vector of axes handles, AXES, as input will return a logical array
%       of the same dimension as the axes handle vector which indicate
%       whether a zoom operation is permitted on the axes objects.
%
%   setAllowAxesZoom(H,AXES,FLAG)
%       Calling the function SETALLOWAXESZOOM on the zoom object, H, with
%       a vector of axes handles, AXES, and a logical scalar, FLAG, will
%       either allow or disallow a zoom operation on the axes objects.
%
%   INFO = getAxesZoomMotion(H,AXES)
%       Calling the function GETAXESZOOMMOTION on the zoom object, H, with 
%       a vector of axes handles, AXES, as input will return a character
%       cell array of the same dimension as the axes handle vector which
%       indicates the type of zoom operation for each axes. Possible values
%       for the type of operation are 'horizontal', 'vertical' or 'both'.
%
%   setAxesZoomMotion(H,AXES,STYLE)
%       Calling the function SETAXESZOOMMOTION on the zoom object, H, with a
%       vector of axes handles, AXES, and a character array, STYLE, will
%       set the style of zooming on each axes.
%
%   EXAMPLE 1:
%
%   plot(1:10);
%   zoom on
%   % zoom in on the plot
%
%   EXAMPLE 2:
%
%   plot(1:10);
%   h = zoom;
%   h.Motion = 'horizontal';
%   h.Enable = 'on';
%   % zoom in on the plot in the horizontal direction.
%
%   EXAMPLE 3:
%
%   ax1 = subplot(2,2,1);
%   plot(1:10);
%   h = zoom;
%   ax2 = subplot(2,2,2);
%   plot(rand(3));
%   setAllowAxesZoom(h,ax2,false);
%   ax3 = subplot(2,2,3);
%   plot(peaks);
%   setAxesZoomMotion(h,ax3,'horizontal');
%   ax4 = subplot(2,2,4);
%   contour(peaks);
%   setAxesZoomMotion(h,ax4,'vertical');
%   % zoom in on the plots.
%
%   EXAMPLE 4: (copy into a file)
%       
%   function demo
%   % Allow a line to have its own 'ButtonDownFcn' callback.
%   hLine = plot(rand(1,10));
%   hLine.ButtonDownFcn = 'disp(''This executes'')';
%   hLine.Tag = 'DoNotIgnore';
%   h = zoom;
%   h.ButtonDownFilter = @mycallback;
%   h.Enable = 'on';
%   % mouse click on the line
%
%   function [flag] = mycallback(obj,event_obj)
%   % If the tag of the object is 'DoNotIgnore', then return true.
%   objTag = obj.Tag;
%   if strcmpi(objTag,'DoNotIgnore')
%      flag = true;
%   else
%      flag = false;
%   end
%
%   EXAMPLE 5: (copy into a file)
%
%   function demo
%   % Listen to zoom events
%   plot(1:10);
%   h = zoom;
%   h.ActionPreCallback = @myprecallback;
%   h.ActionPostCallback = @mypostcallback;
%   h.Enable = 'on';
%
%   function myprecallback(obj,evd)
%   disp('A zoom is about to occur.');
%
%   function mypostcallback(obj,evd)
%   newLim = evd.Axes.XLim;
%   msgbox(sprintf('The new X-Limits are [%.2f %.2f].',newLim));
%
%   Use LINKAXES to link zooming across multiple axes.
%
%   See also PAN, ROTATE3D, LINKAXES.
%

%   Copyright 2011-2014 The MathWorks, Inc.
