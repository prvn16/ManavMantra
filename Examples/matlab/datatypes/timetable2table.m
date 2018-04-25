function t = timetable2table(tt,varargin)
%TIMETABLE2TABLE Convert timetable to table.
%   T = TIMETABLE2TABLE(TT) converts the M-by-N timetable TT to an
%   M-by-(N+1) table T. TT's time vector is the first variable in T.
%
%   T = TIMETABLE2TABLE(TT,'ConvertRowTimes',false) converts the M-by-N
%   timetable TT to an M-by-N table T. TT's time vector is not preserved
%   in T. TIMETABLE2TABLE(TT,'ConvertRowTimes',true) is identical to
%   TIMETABLE2TABLE(TT).
%
%   See also TIMETABLE, TABLE2TIMETABLE.

%   Copyright 2016 The MathWorks, Inc.

if ~istimetable(tt)
    error(message('MATLAB:timetable2table:NonTimetable'))
end

pnames = {'ConvertRowTimes'};
dflts =  {            true };
convertRowTimes = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});

% Create a table from the timetable's variables.
vars = getVars(tt,false);
t = table.init(vars,height(tt),{},width(tt),tt.Properties.VariableNames,tt.Properties.DimensionNames{2});

% Copy over all the metadata, except the row times and the first dim name.
props = rmfield(tt.Properties,'RowTimes');
props = rmfield(props,'DimensionNames');
props.RowNames = {};
t.Properties = props;

if convertRowTimes
    % Create a variable from the row times, named according to the first dim name,
    % at the front of the table.
    % Needs to be done after copying the props from tt to t.
    t.(tt.Properties.DimensionNames{1}) = tt.Properties.RowTimes;
    nvars = width(t);
    t = t(:,[nvars 1:nvars-1]);
end