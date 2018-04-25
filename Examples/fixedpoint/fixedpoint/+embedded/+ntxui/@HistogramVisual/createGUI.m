function hInstall = createGUI(this)
% Create a default UI

%   Copyright 2009-2017 The MathWorks, Inc.

p = createGUI@matlabshared.scopes.visual.Visual(this);

% Create different menus if the NTX feature is turned "On".
% Add NTX related menus to the framework.
hmenus = createNTXMenus(this);
hInstall = uimgr.Installer([p;...
                    hmenus]);

%------------------------------------------
