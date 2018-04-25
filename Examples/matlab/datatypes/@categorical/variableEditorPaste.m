function this = variableEditorPaste(this, rows, columns, data)
% These functions are for internal use only and will change in a
% future release.  Do not use this function.

% Performs a paste operation on data from the clipboard which was not
% obtained from another categorical array.

%   Copyright 2013-2016 The MathWorks, Inc.

if matlab.internal.datatypes.istabular(data)
    % try converting the table to an array.  If it is an array of
    % categoricals, the paste will succeed.  Otherwise, if it can't be
    % converted to an array or it isn't an array of categoricals, it will
    % fail below and the user will receive an appropriate error message.
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
 
% Paste data onto existing categorical variables
s = struct('type', {'()'}, 'subs', {{rows,columns}});
if isa(data,'categorical')            
    this = subsasgn(this, s, data);
elseif iscell(data)
    this = subsasgn(this, s, data);
else
    this = subsasgn(this, s, cellstr(data));
end



