% HASSETTING   Query if settings group contains a setting with specified name
%
% hasSetting(OBJ, SETTINGNAME) returns 1 (true) if a child setting 
% SETTINGNAME exists as a child of this settings group OBJ. 
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
%  Query if settings group 'mytoolbox' contains the setting 'FontSize'
%
%    >> s = settings;
%    >> hasSetting(s.mytoolbox, 'FontSize')
%
%       ans =
%
%            1
%
%
%  See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addSetting, matlab.settings.SettingsGroup/removeSetting

%  Copyright 2015-2017 The MathWorks, Inc.
