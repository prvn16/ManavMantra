function rowNames = variableEditorRowNames(this)
% This function is for internal use only and will change in a
% future release.  Do not use this function.

% Undocumented method used by the Variable Editor to determine the names of
% table rows.

%   Copyright 2011-2016 The MathWorks, Inc.

if iscellstr(this.rowDim.labels)
    rowNames = this.rowDim.labels;
else
    % Return no row names for tables without cellstr row names (for
    % example, time data which is datetime or duration).  In those cases,
    % the time data in the row names is retrieved along with the data.
    rowNames = {};
end
