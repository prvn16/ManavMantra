function [out, warnmsg] = variableEditorColumnDeleteCode(a, varName, colIntervals)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to delete columns positions defined by the
% 2-column colIntervals matrix. It is assumed that column intervals are
% disjoint,  in monotonic order,  and bounded by the number of columns in
% the calendarDuration variable array.

% Copyright 2014-2015 The MathWorks,  Inc.

warnmsg = '';
if size(colIntervals,1)==1
    s = size(a);
    if s(1,1) == 1
        out = sprintf('%s(%s) = [];', varName, ...
            localBuildSubsref(colIntervals(1), colIntervals(2)));
    else
        out = sprintf('%s(:,%s) = [];', varName, ...
            localBuildSubsref(colIntervals(1), colIntervals(2)));
    end
else
    columnSubsref = localBuildSubsref(colIntervals(1,1), ...
        colIntervals(1,2));
    for row=2:size(colIntervals,1)
        columnSubsref = sprintf('%s,%s', columnSubsref, ...
            localBuildSubsref(colIntervals(row,1),colIntervals(row,2)));
    end
    % e.g. x(:, [1:2 5]) = [];
    out = sprintf('%s(:,[%s]) = [];', varName, columnSubsref); 
end

function subsrefexp = localBuildSubsref(startCol,endCol)

% Create a sub-index expression for the interval startCol:endCol
if startCol==endCol
    subsrefexp = sprintf('%d',startCol);
else
    subsrefexp = sprintf('%d:%d',startCol,endCol);
end
