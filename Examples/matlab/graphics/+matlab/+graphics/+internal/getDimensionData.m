function val = getDimensionData(obj, dim)
%getDimensionData
%    val = getDimensionData(obj, dim) sets val to contain data
%    for the requested object and axis dimension. If the object does
%    not define this method itself the properties used are
%    obj.([name 'Data']) where name is element dim of obj.DimensionNames.
%    If no such property exists then the result is [].
%    The data returned may not correspond to a named property or may
%    be for a swapped property (e.g. barh X returns YData).
%
%    Examples:
%    h = plot(1:10);
%    getDimensionData(h, 1) % gets XData
%    getDimensionData(h, 2) % gets YData
%    getDimensionData(h, 3) % gets ZData
%
%    h = bar(1:10);
%    getDimensionData(h, 1) % gets XData
%    h.Horizontal = 'on';
%    getDimensionData(h, 1) % gets YData
%
%   see also matlab.graphics.internal.getDimensionProperty

%   Copyright 2016 The MathWorks, Inc.

narginchk(2,2);
try
    % try a method if the object needs customized behaviors
    val = getDimensionData(obj, dim);
catch
    names = obj.DimensionNames;
    prop = [names{dim} 'Data'];
    if isprop(obj, prop)
        val = obj.(prop);
    else
        val = [];
    end
end
