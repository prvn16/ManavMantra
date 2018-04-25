function rootgroup = settings()
% SETTINGS    Access the SettingsGroup root object.
%
%    SETTINGS returns the root SettingsGroup object in the settings
%    hierarchical tree
%
%  Example
%    Assume the settings tree contains these SettingsGroup and Setting objects:
%
%                             root
%                             /  \     
%                       matlab   mytoolbox
%                       /         /    \
%                    ...    FontSize  MainWindow   
%
%    Use the SETTINGS function to access the root SettingsGroup object.
%    >> S = settings;
%
%    Then, access the desired Setting object in the settings tree. 
%    For example,
%    >> S.mytoolbox.FontSize
%
%       ans = 
%       Setting 'mytoolbox.FontSize' with properties:
%
%            ActiveValue: 12
%         TemporaryValue: 12
%          PersonalValue: <no value>
%           FactoryValue: 10
%
%
%   See also matlab.settings.Setting, matlab.settings.SettingsGroup

%    Copyright 2014-2018 The MathWorks, Inc.
    
    rootgroup = matlab.settings.internal.settings;
end
