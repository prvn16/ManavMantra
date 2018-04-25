function schema
% Defines properties for @MetaData class

%   Copyright 1986-2005 The MathWorks, Inc.

% Register class 
p = findpackage('hds');
c = schema.class(p,'metadata');
schema.prop(c,'Units','string');       % units
