function setTickLabel(ruler, val)
% This function is undocumented and may change in a future release.

%   Copyright 2016 The MathWorks, Inc.

% If the ruler input is empty, there is nothing to do.
if isempty(ruler)
    return
end

% This line serves two purposes:
% 1. Get the number of ticks on each ruler
% 2. Make sure ticks are up-to-date
n = NaN(1,numel(ruler));
for r = 1:numel(ruler)
    n(r) = numel(ruler(r).TickValues);
end

% If the input is an array of strings, convert to a cell-array of caracter
% vectors.
if isstring(val)
    val = cellstr(val);
end

% Set the property value to validate and standardize the new labels.
ruler(1).TickLabels = val;

% Read back the property value. The value returned will either be a
% character matrix or a cell-array of character vectors.
val = ruler(1).TickLabels;

% Input is a character matrix, convert it to a cell-array of character
% vectors.
if ischar(val)
    val = cellstr(val);
end

for r = 1:numel(ruler)
    % If there are fewer labels than ticks, pad with blank labels.
    if numel(val) < n(r)
        val(numel(val)+1:n(r)) = {''};
    end
    
    % Set the tick labels
    ruler(r).TickLabels = val;
    
    % Set the TickValuesMode to 'manual' after setting the labels, so that the
    % mode is only changed if setting the labels succeeds.
    ruler(r).TickValuesMode = 'manual';
end

end
