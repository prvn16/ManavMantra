function [out,warnmsg] = variableEditorSortCode(~, varName, columnIndexStrings, direction)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Generate MATLAB command to sort duration rows. The direction input
% is true for ascending sorts, false otherwise.

% Copyright 2014-2015 The MathWorks, Inc.

warnmsg = '';
if iscell(columnIndexStrings)
    columnIndexExpression = ['[' strjoin(columnIndexStrings,' ') ']'];
else
    columnIndexExpression = columnIndexStrings;
end

if direction
    out = [varName ' = sortrows(' varName ',' ...
        columnIndexExpression ');'];
else
    out = [varName ' = sortrows(' varName ',-' ...
        columnIndexExpression ');'];
end
