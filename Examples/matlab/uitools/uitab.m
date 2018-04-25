function h = uitab(varargin)
%UITAB Container that will be hosted by a UITABGROUP.
%   UITAB(parent, 'PropertyName1', Value1, 'PropertyName2', Value2, ...) or
%   UITAB('Parent', parent, 'PropertyName1', Value1, 'PropertyName2', Value2, ...)
%   creates a container and adds it to the parent uitabgroup. The uitab can
%   have the same child objects as a uipanel. Calling uitab without a
%   parent handle will create a uitabgroup and parent it to that.
%
%   HANDLE = UITAB(parent, ...) or
%   HANDLE = UITAB('Parent', parent, ...) creates a tab and returns a
%   handle to it in HANDLE. 
%
%   Example:
%
%   h = uitabgroup();
%   t1 = uitab(h, 'title', 'Panel 1');
%   a = axes('parent', t1); surf(peaks);
%   t2 = uitab(h, 'title', 'Panel 2');
%   closeb = uicontrol(t2, 'String', 'Close Me', ...
%            'Position', [180 200 200 60], 'Call', 'close(gcbf)');
%
%   See also UITABGROUP, UIPANEL.

%   Copyright 2014 The MathWorks, Inc.

%   Release: R14SP2. This feature will not work in MATLAB R13 and before.

h = usev0tab(varargin{:});
if isempty(h)
    if (usev0dialog(varargin{:}))
         warning(message('MATLAB:uitab:MigratingFunction'));
        h = uitab_deprecated(varargin{2:end});
    else
        % Replace this with a call to the documented uitab when ready.
        h = uitab_deprecated(varargin{:});
    end
end
