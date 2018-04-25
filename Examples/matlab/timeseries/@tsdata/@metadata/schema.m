function schema
%SCHEMA Defines properties for METADATA class

%   Copyright 1986-2014 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('tsdata'),'metadata');
c.Handle = 'off';

% Public properties
schema.prop(c,'Units','string'); %#OK_UDDSTRING
schema.prop(c,'Scale','MATLAB array');  
schema.prop(c,'Interpolation','handle');
schema.prop(c,'Offset','MATLAB array'); 
p = schema.prop(c,'GridFirst','bool');
p.FactoryValue = true;
 


