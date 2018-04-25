function this = variableEditorPaste(this, rows, columns, data)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Performs a paste operation on data from the clipboard which was not
% obtained from another datetime array.

% Copyright 2014-2016 The MathWorks, Inc.

if isa(data, 'table')
    % try converting the table to an array.  If it is an array of
    % datetimes, the paste will succeed.  Otherwise, if it can't be
    % converted to an array or it isn't an array of datetimes, it will fail
    % below and the user will receive an appropriate error message.
    try
        data = table2array(data);
    catch
    end
end

ncols = size(data, 2);
nrows = size(data, 1);

% If the number of pasted columns does not match the number of selected
% columns, just paste columns starting at the left-most column
if length(columns) ~= ncols && ncols > 1
    columns = columns(1):columns(end) + ncols - 1;
end

% If the number of pasted rows does not match the number of selected rows,
% just paste rows starting at the top-most row
if length(rows) ~= nrows && nrows > 1
    rows = rows(1):rows(end) + nrows - 1;
end

% Paste data onto existing datetime variables
s = struct('type', {'()'}, 'subs', {{rows,columns}});
if isa(data, 'datetime')
    this = subsasgn(this, s, data);
elseif iscell(data)
    this = subsasgn(this, s, data);
else
    this = subsasgn(this, s, cellstr(data));
end
