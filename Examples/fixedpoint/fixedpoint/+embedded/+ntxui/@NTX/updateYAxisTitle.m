function updateYAxisTitle(ntx)
% Update the y-axis title string

%   Copyright 2010-2012 The MathWorks, Inc.

OccurrencesStr = ...
    getString(message('fixed:NumericTypeScope:UI_OccurrencesStr'));

if ntx.HistVerticalUnits == 1
    % Frequency (Percentage)
    tmpStr = strcat( sprintf('%s (', OccurrencesStr), '%', ')' );
else
    % Bin count
    tmpStr = sprintf('%s (%s)', OccurrencesStr, ...
        getString(message('fixed:NumericTypeScope:UI_CountStr')));
end

eng = ntx.BinCountVerticalUnitsStr;
if ~isempty(eng)
    str = sprintf('%s (%s)', tmpStr, eng);
else
    str = tmpStr;
end

hy = get(ntx.hHistAxis,'YLabel');
set(hy,'String',str);
