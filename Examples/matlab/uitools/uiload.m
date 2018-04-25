function uiload
% This function is undocumented and will change in a future release

%UILOAD Present file selection dialog and load result using LOAD
%
%   Example:
%       uiload %type in command line
%
% See also UIGETFILE UIPUTFILE OPEN UIIMPORT 

% Copyright 1984-2008 The MathWorks, Inc.

evalin('caller','uiopen(''load'');');

