% HASFACTORYVALUE    Determine whether the setting has a factory value set
%
%    HASFACTORYVALUE(S) returns 1 (true) if S has a factory value set.  
%    Otherwise, HASFACTORYVALUE returns 0 (false).
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
%    Then, check whether the FontSize setting has a factory value
%    >> hasFactoryValue(S.mytoolbox.FontSize)
%
%       ans =
%            1
%
%   See also settings
 
%   Copyright 2015-2018 The MathWorks, Inc.
