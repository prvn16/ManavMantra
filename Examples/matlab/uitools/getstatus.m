function statusString = getstatus(figHandle)
%GETSTATUS Obsolete function.
%   GETSTATUS may be removed in a future version.

%GETSTATUS Get status text string in figure.
%   STATUS = GETSTATUS(FIGHANDLE) returns the 'String'
%   property value of the uicontrol text object with 'Tag'
%   equal to 'Status'.  If such an object does not exist,
%   GETSTATUS returns [].
%
%   STATUS = GETSTATUS is equivalent to STRING =
%   GETSTATUS(gcf).
%
%   Example:
%       fig = figure
%       uicontrol('Parent', fig, 'Style', 'text', 'Tag', 'Status',...
%                 'String', 'Hello')
%       status = getstatus(fig)
%
%   See also SETSTATUS.

%  Steven L. Eddins, October 1994
%  Copyright 1984-2008 The MathWorks, Inc.

obsolete = true;

narginchk(0,1);

if (nargin == 0)
  figHandle = gcf;
end

statusBar = findobj(get(figHandle, 'Children'), 'flat', 'Tag', 'Status');
if (isempty(statusBar))
  statusString = [];
else
  statusString = get(statusBar(1), 'String');
end
