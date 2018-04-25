function schema
% Defines properties for @ValueArray base class.

%   Copyright 1986-2004 The MathWorks, Inc.

% Register class 
c = schema.class(findpackage('hds'),'ValueArray');

% Public properties
p = schema.prop(c,'GridFirst','bool');      % Controls if grid dimensions appear first or last
p.FactoryValue = true;
schema.prop(c,'SampleSize','MATLAB array'); % Size of individual data point

p = schema.prop(c,'MetaData','handle');     % @metadata object
p.SetFunction = @privateSetMetaData;

schema.prop(c,'Variable','handle');         % @variable description
