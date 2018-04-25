function toolstrip = showcaseHTML()
% Demonstrate how to build toolstrip hierarchy in MATLAB and render it in
% a web browser.
%
%   "obj = matlab.ui.internal.toolstrip.showcase()" provides examples about
%   how to create controls, build layout and attach callback functions
%   using the Toolstrip MCOS API. It displays toolstrip inside a web
%   browser.  It also returns a "matlab.ui.internal.toolstrip.Toolstrip"
%   object.
%
%   To destroy the toolstrip, delete the toolstrip MCOS object or clear it
%   from workspace.  The UI will also be destroyed in the web browser.

%   Author(s): Rong Chen
%   Copyright 2015-2017 The MathWorks, Inc.

import matlab.ui.internal.toolstrip.*

%% Make sure connector service is available
connector.ensureServiceOn;

%% Toolstrip
toolstrip = matlab.ui.internal.toolstrip.Toolstrip();
toolstrip.Tag = 'toolstrip';
toolstrip.DisplayStateChangedFcn = @PropertyChangedCallback;            

%% TabGroup
disp('building toolstrip hierarchy...')
tabgroup = matlab.ui.internal.desktop.showcaseBuildTabGroup('javascript');
toolstrip.add(tabgroup);

%% Render
disp('rendering toolstrip...')
toolstrip.render('/ToolstripShowcaseChannel');
toolstrip.addToHost('ToolStripShowcaseDIV');

%% Launch Web Brower
web(connector.getUrl('/toolbox/matlab/toolstrip/web/showcase.html'),'-browser');

% callback function
function PropertyChangedCallback(~, data)
fprintf('Property "%s" is changed from "%s" to "%s".\n',data.EventData.Property,data.EventData.OldValue,data.EventData.NewValue);

