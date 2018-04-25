function removeSetting(obj, varargin)
% removeSetting    Remove setting from settings tree
%
% removeSetting(OBJ,SETTINGNAME) removes the whole subgroup SETTINGNAME from the settings group OBJ.
%
% This method returns an error if you do not have write permission on the settings file, or if SETTINGNAME does not exist.
%
%  Examples:
%  Assume the settings tree contains the following user groups and settings:
%
%                           Settings_Root_Group
%                             /  \       \
%                        matlab simulink  mytoolbox
%                           ......           \
%                                          mainwindow   
%                                              \    
%                                            BgColor
%                                                 
%
%  Remove the setting 'BgColor' from the settings group 'mainwindow' 
%
%      >> s = settings;
%      >> removeSetting(s.mytoolbox.mainwindow, 'BgColor');
% 
%
%   See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addSetting

%   Copyright 2015-2018 The MathWorks, Inc.

    results = matlab.settings.internal.parseSettingPropertyValues(varargin);
    % parseSettingPropertyValues function parses and validates user-input for optional property-value pairs with inputParser.
    obj.removeSettingHelper(results.Name);
end
