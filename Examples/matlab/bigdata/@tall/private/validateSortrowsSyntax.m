function validateSortrowsSyntax(func, rowNameWarnId, rowNameNewErrId, tX, varargin)
% Check the inputs against adaptor information for table and timetable types
% with SORTROWS and TOPKROWS

% Copyright 2016-2017 The MathWorks, Inc.

% If we don't know the number of columns, assume for validation purposes
% that we have enough.
if numel(varargin) >= 1 && isnumeric(varargin{1})
    % Input includes COL
    defaultNumColsForValidation = max(varargin{1} (:));
    defaultNumColsForValidation = max(ceil(defaultNumColsForValidation), 1);
elseif numel(varargin) >= 1 && iscell(varargin{1})
    % Input includes DIRECTION
    defaultNumColsForValidation = numel(varargin{1});
else
    defaultNumColsForValidation = 1;
end

% Sortrows issues a warning if you attempt to sort by row name and row
% names don't exist. We convert this warning into an error.
warningState = warning('error', rowNameWarnId); %#ok<CTPCT>
warningStateCleanup = onCleanup(@() warning(warningState));
try
    % All supported non-strong types act like double for parameter validation.
    tall.validateSyntax(func, [{tX}, varargin], ...
        'DefaultType', 'double', ...
        'DefaultSize', [1, defaultNumColsForValidation]);
catch err
    if strcmp(err.identifier, rowNameWarnId)
        err = MException(message(rowNameNewErrId));
    end
    throwAsCaller(err);
end
