function schema
%SCHEMA   Define the SPLITPANE class.

%   Copyright 2004-2013 The MathWorks, Inc.

    pk = findpackage('hdftool');
    c  = schema.class(pk, 'splitpane');

    schema.prop(c, 'OldPosition',     'MATLAB array');
    schema.prop(c, 'Invalid',         'bool');
    schema.prop(c, 'NorthWest',       'MATLAB array');
    schema.prop(c, 'SouthEast',       'MATLAB array');
    schema.prop(c, 'LayoutDirection', 'MATLAB array');
    schema.prop(c, 'Dominant',        'MATLAB array');
    schema.prop(c, 'DividerWidth',    'double');
    schema.prop(c, 'DividerHandle',   'MATLAB array');
    schema.prop(c, 'AutoUpdate',      'bool');
    schema.prop(c, 'Active',          'MATLAB array');
    schema.prop(c, 'Panel',           'MATLAB array');
    schema.prop(c, 'DominantExtent',   'double');
    schema.prop(c, 'MinDominantExtent','double');
    schema.prop(c, 'MinNonDominantExtent','double');
    schema.prop(c, 'hFig',            'MATLAB array');
    schema.prop(c, 'Listeners',       'handle.listener vector'); ...

end
