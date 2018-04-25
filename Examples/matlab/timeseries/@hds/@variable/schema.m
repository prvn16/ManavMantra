function schema
% Defines properties for @variable class (data set variable).

%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('hds'),'variable');

% Public properties
p = schema.prop(c,'Name','string'); % Variable name
p.AccessFlags.PublicSet = 'off';
p.AccessFlags.AbortSet = 'off';
p.AccessFlags.Init = 'off';