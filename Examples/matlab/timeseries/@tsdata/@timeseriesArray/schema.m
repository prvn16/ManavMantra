function schema

% Copyright 2004-2006 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('tsdata'),'timeseriesArray');

% Public properties
schema.prop(c,'LoadedData','MATLAB array');




