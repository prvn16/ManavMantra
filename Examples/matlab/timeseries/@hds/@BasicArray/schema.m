function schema
% Defines properties for @BasicArray class.

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
p = findpackage('hds');
c = schema.class(p,'BasicArray',findclass(p,'ValueArray'));

% Public properties
p = schema.prop(c,'Data','MATLAB array');       % Array value
p.AccessFlags.AbortSet = 'off';   % perf optimization

