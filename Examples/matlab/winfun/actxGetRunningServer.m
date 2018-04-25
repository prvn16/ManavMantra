%actxGetRunningServer Get a handle to a running instance 
%                     of the Automation server.
%  H = actxGetRunningServer('PROGID') gets a reference to 
%  a running instance of the OLE Automation server, where 
%  PROGID is the programmatic identifier of the Automation 
%  server object, and H is the handle to the server object's 
%  default interface.
%  The function issues an error if the server specified
%  by PROGID is not currently running or if the server object 
%  is not registered. When there are multiple instances of the
%  Automation server already running, the behavior of this
%  function is controlled by the operating system. 
% 
%  Example:
%  h = actxGetRunningServer('Excel.Application')
%
% See also: ACTXSERVER, ACTXCONTROL
