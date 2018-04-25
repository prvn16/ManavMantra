% matlab.settings.Setting   Setting object  
% A Setting object represents an individual setting within the settings hierarchical tree.
%
% Settings are organized by product in a tree-based hierarchy of SettingsGroup objects. At the top of the
% tree is the root SettingsGroup object. Directly under the root object are the product SettingsGroups. 
% Each product SettingsGroup then contains its own hierarchy of settings. For example:
%
%                             root
%                             /  \
%                         matlab   ...
%                          /  \ 
%                     general  editor 
%
% To access and modify a Setting object, use the settings function to access the root of the settings tree.
% For example, this code accesses the Editor MaxWidth setting.
%    s = settings
%    s.matlab.editor.language.matlab.comments.MaxWidth
%                                           
% A Setting object has three levels of values, listed in order of precedence, from highest to lowest: 
% 
%    TemporaryValue     : Setting value at 'Temporary' level. Value is available only for the current 
%             MATLAB session and is cleared at the end of the session. 
%    PersonalValue      : Setting value at 'Personal' level. Value is available across MATLAB sessions 
%             for an individual user.
%    FactoryValue       : Setting value at 'Factory' Level. Value is read-only and is the default product 
%             setting value.
%
% The active value of a setting is determined as follows:
%    If the setting has a temporary value, then the active value is the temporary value
%    If the setting has no temporary value, but it has a personal value, then the active value is the personal value.
%    If the setting has no temporary value or personal value, then the active value is the factory value.
%
% For example, suppose you have a setting with these values:
%    Temporary value: 12
%    Personal value: no value
%    Factory value: 10
% In this case, the active value for the setting is the temporary value, 12.
%
% Setting Object Functions:
%    hasTemporaryValue()   : Determine whether the setting has a temporary value set 
%    hasPersonalValue()    : Determine whether the setting has a personal value set
%    hasFactoryValue()     : Determine whether the setting has a factory value set
%    clearTemporaryValue() : Clear the temporary value for a setting
%    clearPersonalValue()  : Clear the personal value for a setting
%                        
%   See also matlab.settings.SettingsGroup, settings

%   Copyright 2015-2018 The MathWorks, Inc.

