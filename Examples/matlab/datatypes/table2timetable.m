function tt = table2timetable(t,varargin)
%TABLE2TIMETABLE Convert table to timetable.
%   TT = TABLE2TIMETABLE(T) converts the M-by-N table T to an M-by-(N-1)
%   timetable TT. The first datetime or duration variable in T becomes TT's time
%   vector, while the remaining variables in T become variables in TT.
%
%   TT = TABLE2TIMETABLE(T,'RowTimes',TIMEVARNAME) creates TT using the
%   specified datetime or duration variable in T as the time vector. TIMEVARNAME
%   is the name or index of a variable in T.
%
%   TT = TABLE2TIMETABLE(T,'RowTimes',ROWTIMES) converts the M-by-N table T to
%   an M-by-N timetable TT using the specified datetime or duration vector as
%   the time vector. All of T's variables become variables in TT.
%
%   If T contains row names, TABLE2TIMETABLE adds them to TT as a variable, and
%   TT is M-by-N.
%
%   See also TIMETABLE, ARRAY2TIMETABLE, TIMETABLE2TABLE.

%   Copyright 2016 The MathWorks, Inc.

import matlab.internal.datatypes.isCharString
import matlab.internal.datatypes.isScalarInt

if ~istable(t)
    error(message('MATLAB:table2timetable:NonTable'));
end

vars = getVars(t,false);
varnames = t.Properties.VariableNames;

if nargin == 1
    % Take the time vector as the first datetime/duration variable in the table.
    % If the table is n-by-p, the timetable will be n-by-(p-1).
    rowtimesCandidates = varfun(@(x)isdatetime(x) || isduration(x),t,'OutputFormat','uniform');
    rowtimesIndex = find(rowtimesCandidates,1);
    if isempty(rowtimesIndex)
        error(message('MATLAB:table2timetable:NoTimeVarFound'));
    end
    rowtimesName = varnames{rowtimesIndex};
else
    % Take the time vector as the RowTimes input, or as the specified variable in the table.
    % If the table is n-by-p, the timetable will be n-by-p, or n-by-(p-1), respectively.
    pnames = {'VariableNames'  'RowTimes'};
    dflts =  {            []           []};
    [~,rowtimes,supplied] = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    
    if supplied.VariableNames
        error(message('MATLAB:table2timetable:VariableNamesNotAccepted'));
    elseif supplied.RowTimes
        if isdatetime(rowtimes) || isduration(rowtimes)
            % The input table defines the size of the output timetable. The time
            % vector must have the same length as the table has rows, even if
            % the table has no vars.
            if numel(rowtimes) ~= height(t)
                error(message('MATLAB:table2timetable:IncorrectNumberOfRowTimes'));
            end
            rowtimesName = 'Time';
            rowtimesIndex = [];
        elseif isCharString(rowtimes)
            % The row times are specified as a variable in the table.
            rowtimesName = rowtimes;
            rowtimesIndex = find(strcmp(rowtimes,varnames));
            if isempty(rowtimesIndex)
                error(message('MATLAB:table:UnrecognizedVarName',rowtimesName));
            end
        elseif isScalarInt(rowtimes,1)
            rowtimesIndex = rowtimes;
            if rowtimesIndex > width(t)
                error(message('MATLAB:table:VarIndexOutOfRange'));
            end
            rowtimesName = varnames{rowtimesIndex};
        else
            error(message('MATLAB:table2timetable:InvalidRowTimes'));
        end
    else % supplied.VariableNames
        error(message('MATLAB:table2timetable:VariableNamesNotAccepted'));
    end
end

% Take the time vector from the table
if ~isempty(rowtimesIndex)
    rowtimes = vars{rowtimesIndex};
    vars(rowtimesIndex) = [];
    varnames(rowtimesIndex) = [];
    t.(rowtimesIndex) = []; % remove it from the table, updating the metadata in the process.
end

nvars = length(vars);
% Need to look at the original table for number of rows, in case there are no vars
% from which to get this info.
nrows = height(t); 
tt = timetable.init(vars,nrows,rowtimes,nvars,varnames);
% Assign dimension names: row times from above and variable dimension from the table.
tt.Properties.DimensionNames = {rowtimesName,t.Properties.DimensionNames{2}};

% Copy over all the metadata, except the row times and the dim names.
props = rmfield(t.Properties,'RowNames');
props = rmfield(props,'DimensionNames');
props = rmfield(props,'VariableNames');
tt = setProperties(tt,props);

% Include the table's row names, if any
rownames = t.Properties.RowNames;
if isvector(rownames)
    % Needs to be done after copying the props from tt to t.
    tt.(t.Properties.DimensionNames{1}) = rownames;
    nvars = width(tt);
    tt = tt(:,[nvars 1:nvars-1]);
end

