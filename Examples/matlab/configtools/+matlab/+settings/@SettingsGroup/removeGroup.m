function removeGroup(obj, varargin)
% removeGroup    Remove group from settings tree
%
% removeGroup(OBJ,GROUPNAME) removes the settings group GROUPNAME and all 
% of its child settings groups and settings from the settings group OBJ.
%
% This method returns an error if you do not have write permission on the settings file, 
% or if GROUPNAME does not exist.
%
% Examples:
%    Assume the settings tree contains the following user groups and settings:
%                          Settings_Root_Group
%                             /  \       \
%                       matlab simulink  mytoolbox
%                           ......           \
%                                          mainwindow   
%                                              \    
%                                            BgColor
%                                                 
%    
%  Remove the child settings group 'mainwindow' from the settings group 'mytoolbox'. This also removes all the
%  child groups and settings:
% 
%      >> s = settings;
%      >> removeGroup(s.mytoolbox, 'mainwindow');
%
%   See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addGroup

%   Copyright 2015-2018 The MathWorks, Inc.

    results = matlab.settings.internal.parseGroupPropertyValues(varargin);
    % parseSettingPropertyValues function parses and validates user-input for optional property-value pairs with inputParser.
    obj.removeGroupHelper(results.Name);
end
