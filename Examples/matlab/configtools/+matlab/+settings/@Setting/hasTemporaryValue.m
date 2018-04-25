% HASTEMPORARYVALUE    Determine whether the setting has a temporary value set
%
%    HASTEMPORARYVALUE(S) returns 1 (true) if S has a temporary value set.  
%    Otherwise, HASTEMPORARYVALUE returns 0 (false).
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
%    >> s = settings;
%
%    Then, check whether the FontSize setting has a temporary value
%    >> hasTemporaryValue(s.mytoolbox.FontSize)
%
%       ans =
%            0
%
%   See also settings
 
%   Copyright 2015-2018 The MathWorks, Inc.

