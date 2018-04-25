function schema
% Defines properties for @VirtualArray class.

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('hds');
c = schema.class(p,'VirtualArray',findclass(p,'ValueArray'));

% Public properties
schema.prop(c,'Storage','MATLAB array');  % Array container

