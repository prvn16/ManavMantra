function txt = getDisplayableString(value)
% getDisplayableString - Utility method for converting any object to a string in displayable format
%
%   This method is used to prepare any arbitrary object for display in a
%   diagnostic result. This includes dealing with hotlinks and any truncation
%   necessary for large numeric or cell arrays.
%
%   It provides a consistent method for truncating large arrays. The method is
%   utilized internally when displaying the actual and expected value fields,
%   but may also provide value externally when displaying failed indices, for
%   example. Array truncation is performed by calling evalc on the displayed
%   value, and returning some maximum number of characters.

%  Copyright 2016 The MathWorks, Inc.

import matlab.unittest.internal.diagnostics.getDisplayableString;
import matlab.unittest.internal.diagnostics.getValueDisplay;
import matlab.unittest.internal.diagnostics.PlainString;
import matlab.unittest.internal.diagnostics.TruncatingString;
import matlab.unittest.internal.diagnostics.EmptyStringSubstitute;

if builtin('ischar',value) && ~isempty(value) && ismatrix(value)
    if ~isrow(value)
        value = strjoin(cellstr(value).', '\n');
    end
    txt = indent(PlainString(value));
    return;
end

% Array & buffer limits
maxPrintedRows = 100;
maxEvaledElems  = 5000;

if isPrimitiveArray(value) && numel(value) > maxEvaledElems
    % Preventing evalc output from reaching high memory usage due to large array length
    txt = sprintf('%s\n\n%s', getString(message('MATLAB:unittest:ConstraintDiagnostic:TruncatedArray', ...
        int2str(size(value)), maxEvaledElems, maxPrintedRows)), ...
        getDisplayableString(value(1:maxPrintedRows)));
elseif isa(value,'table') && size(value,1) > maxPrintedRows
    % Attempt to prevent evalc output from reaching high memory usage due to large row length
    txt = sprintf('%s\n\n%s', getString(message('MATLAB:unittest:ConstraintDiagnostic:TruncatedTableRows', ...
        size(value,1), maxPrintedRows)), ...
        getDisplayableString(value(1:maxPrintedRows,:)));
else
    txt = EmptyStringSubstitute(getValueDisplay(value), class(value), int2str(size(value)));
end

txt = TruncatingString(txt);
end

function bool = isPrimitiveArray(value)
bool = builtin('isnumeric',value) || ...
    builtin('isstring',value) || ...
    builtin('islogical',value) || ...
    builtin('iscell',value);
end

% LocalWords:  ismatrix Evaled Elems isstring
