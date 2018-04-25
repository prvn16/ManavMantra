function [out,warnmsg] = variableEditorClearDataCode(this, varName, rowIntervals, colIntervals)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generates the MATLAB command to delete the content specified by the
% rowIntervals and colIntervals of the datetime variable.

% Copyright 2014-2015 The MathWorks, Inc.

warnmsg = '';

rowSubsref = localBuildSubsref(rowIntervals(1,1),rowIntervals(1,2),size(this,1));    
for row=2:size(rowIntervals,1)
    rowSubsref = sprintf('%s,%s',rowSubsref,localBuildSubsref(rowIntervals(row,1),rowIntervals(row,2),size(this,1)));
end
if size(rowIntervals,1)>1 % Multiple intervals need to be wrapped in []
    rowSubsref = sprintf('[%s]',rowSubsref);
end

colSubsref = localBuildSubsref(colIntervals(1,1),colIntervals(1,2),size(this,2));
for col=2:size(colIntervals,1)
    colSubsref = sprintf('%s,%s',colSubsref,localBuildSubsref(colIntervals(col,1),colIntervals(col,2),size(this,2)));
end
if size(colIntervals,1)>1
    colSubsref = sprintf('[%s]',colSubsref);
end
out = sprintf('%s(%s,%s) = ''NaT'';',varName,rowSubsref,colSubsref);


function subsrefexp = localBuildSubsref(startIndex,endIndex,len)

% Create a sub-index expression for the interval startCol:endCol
if startIndex==1 && endIndex==len
    subsrefexp = ':';
elseif startIndex==endIndex
    subsrefexp = sprintf('%d',startIndex);
else
    subsrefexp = sprintf('%d:%d',startIndex,endIndex);
end

