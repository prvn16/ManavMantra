function h = uitabgroup(varargin)
%UITABGROUP Container to manage tabs.
%   UITABGROUP('PropertyName1, Value1, 'PropertyName2', Value2, ...)
%   creates a container for hosting uitabs. The tabgroup will display and
%   manage the tabs. 
%
%   HANDLE = UITABGROUP(...) creates a tabgroup component and returns a
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
%   See also UITAB, UIPANEL

%   Copyright 2014 The MathWorks, Inc.

%   Release: R14SP2. This feature will not work in MATLAB R13 and before.

h = usev0tabgroup(varargin{:});
if isempty(h)
    if (usev0dialog(varargin{:}))
        % Replace this with a call to the documented uitabgroup when ready.
        warning(message('MATLAB:uitabgroup:MigratedFunction'));
        h = uitabgroup_deprecated(varargin{2:end});
    else
        h = uitabgroup_deprecated(varargin{:});
    end
end
