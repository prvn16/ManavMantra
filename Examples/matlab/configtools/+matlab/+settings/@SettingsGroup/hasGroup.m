% HASGROUP    Query if settings group contains a subgroup with specified name
%
% hasGroup(OBJ, GROUPNAME) returns 1 (true) if a child settings group 
% GROUPNAME exists as a child of this settings group OBJ. 
%
%  Examples:
%
%    Assume the settings tree contains the following settings groups and settings:
%
%                          Settings_Root_Group
%                             /  \       \
%                       matlab simulink  mytoolbox
%                           ......         /    \
%                                    FontSize  mainwindow   
%
%  Check if 'mytoolbox' contains the subgroup 'mainwindow' 
%
%    >> s = settings;
%    >> hasGroup(s.mytoolbox, 'mainwindow')
%
%       ans =
%
%            1
%
%
%  See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addGroup, matlab.settings.SettingsGroup/removeGroup

%  Copyright 2015-2017 The MathWorks, Inc.
