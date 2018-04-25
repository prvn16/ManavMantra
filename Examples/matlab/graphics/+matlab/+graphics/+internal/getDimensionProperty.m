function val = getDimensionProperty(obj, propBase, dim)
%getDimensionProperty Get a graphics object property for a named dimension
%    val = getDimensionProperty(obj, propBase, dim) sets val to
%    obj.([name propBase]) where name is element dim of obj.DimensionNames.
%
%    Examples:
%    ax = axes;
%    getDimensionProperty(ax, 'Lim', 1) % gets XLim
%    h = line('Parent',ax);
%    getDimensionProperty(h, 'Data', 1) % gets XData
%
%    ax = polaraxes;
%    getDimensionProperty(ax, 'Lim', 1) % gets ThetaLim
%    h = line('Parent',ax);
%    getDimensionProperty(h, 'Data', 1) % gets ThetaData

%   Copyright 2015 The MathWorks, Inc.

narginchk(3,3);
names = obj.DimensionNames;
prop = [names{dim} propBase];
val = obj.(prop);
