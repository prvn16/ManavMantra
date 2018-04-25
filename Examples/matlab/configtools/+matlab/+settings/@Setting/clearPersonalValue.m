% CLEARPERSONALVALUE    Clear the personal value for a setting 
%
% CLEARPERSONALVALUE(S) clears the personal value for the specified setting. 
% If the personal value is not set or not writeable, CLEARPERSONALVALUE
% returns an error.
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
%    Use the settings function to access the root SettingsGroup object.
%    >> S = settings;
%
%    Then, clear the personal value for the FontSize setting
%    >> clearPersonalValue(S.mytoolbox.FontSize);
%
%   See also settings, clearTemporaryValue, hasPersonalValue

%   Copyright 2015-2018 The MathWorks, Inc.
