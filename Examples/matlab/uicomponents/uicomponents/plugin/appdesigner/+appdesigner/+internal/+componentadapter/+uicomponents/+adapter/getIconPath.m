function iconPath = getIconPath(iconFileName)
% getIcon Retrieves the full path for a palette icon
%
% It is assumed that the icon is located in a folder called 'icons' at the
% same level as this file.
% 
% Inputs:
% 
%  iconFileName - name of an icon to look up
%
%                 Ex: 'CircularGauge Palette Icon.png'
%
% Outputs:
%
%   fullIconPath - fully qualified file path to the icon
% 
%                  Ex: 'C:\matlab\...\+hmi\...\icons\CircularGauge Palette Icon.png'

% Copyright 2011 The MathWorks, Inc.

% Find the location of this file
%
% Ex: 'C:\matlab\toolbox\+hmi\...\getIcon.m'
thisFilePath = mfilename('fullpath');

% Gets only the folder name 
%
% Ex: 'C:\matlab\toolbox\+hmi\...\+adapter
thisFileDir = fileparts(thisFilePath);

% Appends the icons directory and icon name
%
% Ex: 'C:\matlab\toolbox\+hmi\...\+adapter\icons\CircularGauge Palette Icon.png'
iconPath = fullfile(thisFileDir, 'icons', iconFileName);  
