function ME = subs2indsErrorHandler(t,varName,ME,callerID)
% SUBS2INDSERRORHANDLER Catch errors from subs2inds and throw a more helpful
% error in two cases related to row labels.

%   Copyright 2016 The MathWorks, Inc.

if strcmp(ME.identifier,{'MATLAB:table:UnrecognizedVarName'})
    rowDimName = t.metaDim.labels{1};
    defaultRowDimName = t.defaultDimNames{1};
    if any(strcmp(varName,rowDimName))
        % Helpful error if row labels are not allowed in this context.
        ME = t.throwSubclassSpecificError([callerID ':RowLabelsCannotBeDataVar']);
    elseif any(strcmp(varName,defaultRowDimName))
        % Helpful error if the var name is the default 'Row'/'Time' but the table's/timetable's
        % row labels has been renamed to something else
        ME = t.throwSubclassSpecificError([callerID ':RowLabelsCannotBeDataVarNondefaultName'],defaultRowDimName,rowDimName);
    end
end

if nargout == 0
    throwAsCaller(ME);
end
