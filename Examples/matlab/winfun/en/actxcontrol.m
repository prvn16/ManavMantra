%ACTXCONTROL Create an ActiveX control.
%  H = ACTXCONTROL('PROGID') creates an ActiveX control of a type
%  determined by programmatic identifier PROGID in a figure window and
%  returns a handle H to the control.
%
%  H = ACTXCONTROL('PROGID', 'param1', value1,...) creates an ActiveX
%  control with optional parameter name/value pairs. Parameter names are:
%   position-   A vector specifying control's position with format
%               [x y width height] where the units are in pixels.
%   parent-     Handle to a parent figure, model or command window.
%   callback-   Single file name: handles all events.
%               Cell array of event name and event handler pair:
%               handles specific events. (see example)
%   filename-   Sets the control's initial conditions to those
%               found in previously saved control.
%   licensekey- License key to create licensed ActiveX controls.
%
%  Example:
%  h = actxcontrol('mwsamp.mwsampctrl.2', 'position', [0 0 200 200],...
%       'parent', gcf, 'callback', {'Click' 'sampev'; 'DblClick' 'sampev';...
%       'MouseDown' 'sampev'} );
%
%  The following syntaxes are deprecated and will not become obsolete.  They
%  are included for reference, but the above syntaxes are preferred.
%
%  H = ACTXCONTROL('PROGID', POSITION) creates an ActiveX control having
%  the location and size specified in the vector POSITION, with format
%  [x y width height] where the units are in pixels.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE) creates an ActiveX
%  control in the figure with handle FIG_HANDLE.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE, 'EVENT_HANDLER')
%  creates a ActiveX control in the figure with handle FIG_HANDLE that
%  uses the MATLAB file EVENT_HANDLER to handle all events.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE,...
%  {'EVENT1', 'EVENTHANDLER1'; 'EVENT2', 'EVENTHANDLER2';...})
%  creates an ActiveX control that responds to EVENT1 by using
%  EVENTHANDLER1, EVENT2 using EVENTHANDLER2, and so on.
%
%  H = ACTXCONTROL('PROGID', POSITION, FIG_HANDLE, 'EVENT_HANDLER',
%  'FILENAME') creates a COM control with the first four arguments, and
%  sets its initial conditions to those found in previously saved control
%  'FILENAME'.
%
%  H = ACTXCONTROL returns a cell array of all registered ActiveX controls
%  in the system. This call is the same as actxcontrollist command.
%
%  Example:
%  h = actxcontrol('mwsamp.mwsampctrl.2', [0 0 200 200], gcf, {'Click', ...
%  'sampev'; 'DblClick' 'sampev'; 'MouseDown' 'sampev'});
%
%  See also ACTXSERVER, REGISTEREVENT, UNREGISTEREVENT, EVENTLISTENERS,
%  ACTXCONTROLLIST

%   Copyright 2011 The MathWorks, Inc.
