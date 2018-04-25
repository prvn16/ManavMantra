% CLEARTEMPORARYVALUE    Clear the temporary value for a setting 
%
% CLEARTEMPORARYVALUE(S) clears the temporary value for the specified setting. 
% If the temporary value is not set or not writeable, CLEARTEMPORARYVALUE
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
%    Then, clear the temporary value for the FontSize setting
%    >> clearTemporaryValue(S.mytoolbox.FontSize);
%
%   See also settings, clearPersonalValue, hasTemporaryValue

%   Copyright 2015-2018 The MathWorks, Inc.
