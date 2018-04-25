function [out,warnmsg] = variableEditorColumnDeleteCode(~,varName,colIntervals)
% These functions are for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to delete columns positions defined
% by the 2-column colIntervals matrix. It is assumed that column intervals
% are disjoint, in monotonic order, and bounded by the number of columns 
% in the categorical variable array.

%   Copyright 2013-2015 The MathWorks, Inc.

warnmsg = '';
if size(colIntervals,1)==1
    out = sprintf('%s(:,%s) = [];',varName,localBuildSubsref(colIntervals(1),colIntervals(2)));
else
    columnSubsref = localBuildSubsref(colIntervals(1,1),colIntervals(1,2));
    for row=2:size(colIntervals,1)
        columnSubsref = sprintf('%s,%s',columnSubsref,localBuildSubsref(colIntervals(row,1),colIntervals(row,2)));
    end
    out = sprintf('%s(:,[%s]) = [];',varName,columnSubsref); % e.g. x(:,[1:2 5]) = [];
end

function subsrefexp = localBuildSubsref(startCol,endCol)

% Create a sub-index expression for the interval startCol:endCol
if startCol==endCol
    subsrefexp = sprintf('%d',startCol);
else
    subsrefexp = sprintf('%d:%d',startCol,endCol);
end
