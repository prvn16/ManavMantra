function result = hasYYAxes(ax)
% This is an undocumented function and may be removed in future.


% hasYYAxes returns 0 if an axes is a regular axes, if an axes has two Y
% rulers the function returns its current active dataspace index

%   Copyright 2015 The MathWorks, Inc.

result = 0;

if ishghandle(ax,'axes')
    if numel(ax.YAxis) > 1       
       result = ax.ActiveDataSpaceIndex;
    end
end


