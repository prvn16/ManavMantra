function out = addGroup(obj, varargin)
% addGroup    Add group to settings tree
%
%  addGroup(OBJ, GROUPNAME) adds a new child settings group, GROUPNAME, to the
%  SettingsGroup object, OBJ. This method optionally returns the newly
%  added child settings group as an output. GROUPNAME can be any valid MATLAB 
%  variable name that is unique child of the calling SettingsGroup object.
%
%  The addGroup method creates and saves the settings group GROUPNAME in the user settings file 
%  in the preferences directory for future MATLAB sessions. This operation returns an
%  error if GROUPNAME is the name of an existing setting or group for the calling object.
%  If you do not have write permission to update the settings file, the
%  settings group is added to the tree in current session, but the newly added 
%  settings group is not saved in the settings file. 
%
%  addGroup(OBJ, GROUPNAME, NAME1, VALUE1, ...) support the optional Name/Value arguments
%  with the following property names:
%
% Hidden:
%   The 'Hidden' property indicates whether this group is a visible child settings group.
%   When 'Hidden' is set to true, any child settings groups and settings 
%   contained by this group are not displayed. The default value of this
%   property is false.
%
% ValidationFcn:
%   The 'ValidationFcn' property that specifies a validation function is a 
%   function handle. When specified, it is used as a default validation function 
%   for all the settings directly and indirectly connected to the settings group being added. 
%   This validation function is used for validating the child settings values 
%   that do not have their own validation function defined. 
%
%  Examples:
%  Assume the settings tree contains the following settings groups
%
%                          Settings_Root_Group
%                            /  \       
%                       matlab simulink  
%                           ......            
%
%  Add the settings group 'mytoolbox' to the root settings group:
%    >> s = settings;
%    >> addGroup(s, 'mytoolbox');
%
%  This results in this settings tree
%
%                          Settings_Root_Group
%                            /  \       \
%                       matlab simulink  mytoolbox
%                           ...... 
%
%  Add the settings group 'mytoolbox2' to the root settings group,
%  setting the 'Hidden' property to true and adding the validation function 'ValidateValue'. 
%
%    >> s = settings;
%    >> addGroup(s, 'mytoolbox2', 'Hidden', true, 'ValidationFcn', @validateValue);
%
%  This results in this settings tree
%
%                             Settings_Root_Group
%                            /  \       \        \     
%                      matlab simulink mytoolbox  mytoolbox2
%                           ...... 
%
% The hidden settings group 'mytoolbox2' is not displayed in the display of
% parent root settings group:
%
%    >> s = 
%
%    s =
%
%      SettingsGroup with properties:
%
%           matlab: [1x1 SettingsGroup]
%         simulink: [1x1 SettingsGroup]
%        mytoolbox: [1x1 SettingsGroup]
%
%   See also matlab.settings.SettingsGroup, matlab.settings.SettingsGroup/addSetting

%   Copyright 2015-2018 The MathWorks, Inc.

    [results, defaultsUsed] = matlab.settings.internal.parseGroupPropertyValues(varargin);
    % parseGroupPropertyValues function parses and validates user-input for optional property-value pairs with inputParser.
    out = obj.addGroupHelper(results,defaultsUsed);    
end
