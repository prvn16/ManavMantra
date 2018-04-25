function str = getDataTipString(hObj, point)
% Get a data tip string for a heatmap cell.

% Copyright 2017 The MathWorks, Inc.

% Get the XData, YData, and ColorDisplayData
xval = hObj.XDisplay_I;
yval = hObj.YDisplay_I;
[cd, errID, counts] = hObj.getColorDisplayData(...
    hObj.ColorData, hObj.XData_I, hObj.YData_I, ...
    xval(:,1), yval(:,1), hObj.MissingDataValue, hObj.CalculatedCounts);

% Throw an error if the XData or YData size did not match
% ColorData.
if ~isempty(errID)
    error(message(errID));
end

% Make sure the data point is valid.
x = point(1);
y = point(2);
sz = size(cd);
if y < 1 || y > sz(1) || x < 1 || x > sz(2)
    str = '';
    return
end

% Get the x-label, y-label, and cell label.
ind = sub2ind(sz, y, x);
valstr = sprintf(hObj.CellLabelFormat,cd(ind));
xval = xval(x,:);
yval = yval(y,:);

% Get the message catalog prefix.
msgPrefix = 'MATLAB:Chart:Datatip';

% Generate the string for the x-value. The first value is the
% XDisplayData value, the second is the XDisplayLabel value.
% XDisplayData cannot be empty, but XDisplayLabel may be empty.
if xval(2) == ""
    xval(2) = xval(1);
end

% Use the x label for the x prefix, unless it is empty. In the
% table case this will default to the table variable name.
xLabel = truncateLabel(hObj.XLabel);
if xLabel == ""
    msg = message([msgPrefix 'X'], xval(2));
else
    msg = message([msgPrefix 'XY'], xLabel, xval(2));
end
xstr = msg.getString();

% Generate the string for the y-value. The first value is the
% YDisplayData value, the second is the YDisplayLabel value.
% YDisplayData cannot be empty, but YDisplayLabel may be empty.
if yval(2) == ""
    yval(2) = yval(1);
end

% Use the y label for the y prefix, unless it is empty. In the
% table case this will default to the table variable name.
yLabel = truncateLabel(hObj.YLabel);
if yLabel == ""
    msg = message([msgPrefix 'Y'], yval(2));
else
    msg = message([msgPrefix 'XY'], yLabel, yval(2));
end
ystr = msg.getString();

% Use the color method for the value prefix, unless it is
% 'none', in which case just use 'Value'.
colorMethod = hObj.ColorMethod;
colorMethod(1) = upper(colorMethod(1));
msgID = [msgPrefix colorMethod];
valstr = getString(message(msgID, valstr));

% Generate the counts if necessary.
if hObj.UsingTableForData && ~strcmpi(colorMethod, 'count') && ...
        ~strcmpi(colorMethod, 'none') && all(size(counts) == sz)
    % Generate the string for the counts.
    msgID = [msgPrefix 'Count'];
    countstr = sprintf(hObj.CellLabelFormat,counts(ind));
    countstr = getString(message(msgID, countstr));
    
    % Collect all the strings together.
    str = sprintf('%s\n%s\n%s\n%s', xstr, ystr, countstr, valstr);
else
    % Collect all the strings together.
    str = sprintf('%s\n%s\n%s', xstr, ystr, valstr);
end

end

function lbl = truncateLabel(lbl)

% Convert into a string array.
lbl = string(lbl);

% Find the first non-empty string.
ind = find(lbl ~= "", 1);

% Truncate the string at 25 characters.
if isempty(ind)
    lbl = '';
else
    lbl = lbl(ind);
    n = min(25, strlength(lbl))+1;
    lbl = char(extractBefore(lbl, n));
end

end
