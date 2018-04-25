function out = addSetting(obj,varargin)
% addSetting    Add setting to parent settings group
%
% addSetting(OBJ, SETTINGNAME) adds a new setting with SETTINGNAME to the 
% SettingsGroup object, OBJ. This method optionally returns the newly
% added child settings group as an output. SETTINGNAME can be any valid MATLAB 
% variable name that is unique child of the calling SettingsGroup object.
%
% The addSetting method saves the newly added setting SETTINGNAME in the 
% the user settings file in the preferences directory. This method errors if SETTINGNAME is the name of
% an existing setting or group for the calling object. If you do not have write permission to update the settings file, the
% setting is added to the tree in current session, but you will get the error indicating that the
% newly added setting is not saved in the settings file. 
%
% addSetting(OBJ, SETTINGNAME, NAME1, VALUE1, ...) support the optional Name/Value arguments
% with the following property names:
%
% Hidden:
%   The 'Hidden' property is a boolean value (default false). When this property 
%   is set to true, this setting is not displayed.
%
% ReadOnly:
%   The 'ReadOnly' property is a boolean value (default false). When this property 
%   is set to true, value of this setting cannot be changed.
%
% PersonalValue:
%   This property assigns a personal level value to setting while adding it. 
%
% ValidationFcn:
%   The 'ValidationFcn' property is a function handle identifying the validation 
%   function for this setting. It is used to validate settings values. MATLAB 
%   invokes a validation function when the value of a setting is about to 
%   change. 
%
% Examples:
%
%  Add a 'FontSize' setting to the existing toolbox settings group 'mytoolbox'
%
%      >> s = settings;
%      >> addSetting(s.mytoolbox, 'FontSize');
%
%  This results in this settings tree 
%
%                          Settings_Root_Group
%                             /  \       \
%                       matlab simulink  mytoolbox
%                           ......         /    \
%                                    FontSize   FontColor 
%
%
%   Add a hidden setting 'FontSize' to the existing toolbox settings group 'mytoolbox', with a validation function 'validateValue'. 
%
%      >> s = settings;
%      >> addSetting(s.mytoolbox, 'FontSize', 'Hidden', false, 'ValidationFcn', @validateValue);
%      >> addSetting(s.mytoolbox, 'FontColor', Hidden', true);
%
%      >> s.mytoolbox
%
%      ans = 
%
%       SettingsGroup 'mytoolbox' with properties:
%
%          FontSize: [1×1 Setting]
%
%        Show values for all settings in this group
%      
%
%   See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addGroup, matlab.settings.SettingsGroup/removeSetting

%   Copyright 2015-2018 The MathWorks, Inc.

    [results, defaultsUsed] = matlab.settings.internal.parseSettingPropertyValues(varargin);
    % parseSettingPropertyValues function parses and validates user-input for optional property-value pairs with inputParser.
    out = obj.addSettingHelper(results,defaultsUsed);

end
