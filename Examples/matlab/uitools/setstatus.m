function setstatus(figHandle, string)
%SETSTATUS Obsolete function.
%   SETSTATUS  may be removed in a future version.

%SETSTATUS Set status text string in figure.
%   SETSTATUS(FIGHANDLE, STRING) sets the 'String' property
%   of the uicontrol text object with 'Tag' equal to
%   'Status', if one exists.
%
%   SETSTATUS(STRING) is equivalent to SETSTATUS(gcf,
%   STRING). 
%   
%   Example:
%       fig = figure
%       uicontrol('Parent', fig, 'Style', 'text', 'Tag', 'Status',...
%                 'String', 'Hello')
%       %the next line changes the string
%       setstatus(fig, 'Goodbye')
%
%   See also GETSTATUS.

%   Steven L. Eddins, 1 July 1994
%   Copyright 1984-2008 The MathWorks, Inc.

obsolete = true;

narginchk(1,2);

if (nargin == 1)
  string = figHandle;
  figHandle = gcf;
end

statusBar = findobj(get(figHandle, 'Children'), 'flat', 'Tag', 'Status');
if (~isempty(statusBar))
  set(statusBar, 'String', string);
end
