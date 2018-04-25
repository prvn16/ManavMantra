function tt = table2timetable(t,varargin)
%TABLE2TIMETABLE Convert tall table to tall timetable.
%   TT = TABLE2TIMETABLE(T)
%   TT = TABLE2TIMETABLE(T,'RowTimes',TIMEVARNAME) 
%   TT = TABLE2TIMETABLE(T,'RowTimes',ROWTIMES)
%
%   See also TABLE2TIMETABLE.

%   Copyright 2016-2017 The MathWorks, Inc.

if ~istall(t)
    error(message('MATLAB:bigdata:array:ArgMustBeTall', 1, upper(mfilename)));
end
if ~strcmp(tall.getClass(t), 'table')
    error(message('MATLAB:table2timetable:NonTable'));
end

varNames = subsref(t, substruct('.', 'Properties', '.', 'VariableNames'));
varAdaptors = cellfun(@(x) getVariableAdaptor(t.Adaptor, x), varNames, ...
                      'UniformOutput', false);
if nargin == 1
    % Take the time vector as the first datetime/duration variable in the table.
    % If the table is n-by-p, the timetable will be n-by-(p-1).
    varClasses = cellfun(@(x) getVariableClass(t.Adaptor, x), varNames, ...
                      'UniformOutput', false);
    rowtimesCandidates = ismember(varClasses,{'datetime','duration'});
    rowtimesIndex = find(rowtimesCandidates,1);
    if isempty(rowtimesIndex)
        error(message('MATLAB:table2timetable:NoTimeVarFound'));
    end
    tt = slicefun(@table2timetable,t);
else
    % Take the time vector as the RowTimes input, or as the specified variable in the table.
    % If the table is n-by-p, the timetable will be n-by-p, or n-by-(p-1), respectively.
    pnames = {'VariableNames'  'RowTimes'};
    dflts =  {            []           []};
    [~,rowtimes,supplied] = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{:});
    if supplied.VariableNames
        error(message('MATLAB:table2timetable:VariableNamesNotAccepted'));
    end
    if supplied.RowTimes
        if istall(rowtimes)
            if ~any(strcmp(tall.getClass(rowtimes),{'datetime','duration'}))
                error(message('MATLAB:table2timetable:InvalidRowTimes'));
            end
            rowtimesName = 'Time';
            rowtimesIndex = [];
            rowtimesAdaptor = rowtimes.Adaptor;
            tt = slicefun(@(x,y)table2timetable(x,'RowTimes',y),t,rowtimes);
        else
            if matlab.internal.datatypes.isCharString(rowtimes)
                % The row times are specified as a variable in the table.
                rowtimesName = rowtimes;
                rowtimesIndex = find(strcmp(rowtimes,varNames));
                if isempty(rowtimesIndex)
                    error(message('MATLAB:table:UnrecognizedVarName',rowtimesName));
                end
            elseif matlab.internal.datatypes.isScalarInt(rowtimes,1)
                rowtimesIndex = rowtimes;
                if rowtimesIndex > width(t)
                    error(message('MATLAB:table:VarIndexOutOfRange'));
                end
                rowtimesName = varNames{rowtimesIndex};
            else
                error(message('MATLAB:table2timetable:InvalidRowTimes'));
            end
            tt = slicefun(@(x)table2timetable(x,'RowTimes',rowtimesIndex),t); 
        end
    end
end

% Propagate Properties
props = subsref(t, substruct('.', 'Properties'));
% Take the time vector from the table
if ~isempty(rowtimesIndex)
    rowtimesName = varNames{rowtimesIndex};
    rowtimesAdaptor = varAdaptors{rowtimesIndex};
    varNames(rowtimesIndex) = [];
    varAdaptors(rowtimesIndex) = [];
    if ~isempty(props.VariableDescriptions)
        props.VariableDescriptions(rowtimesIndex) = [];
    end
    if ~isempty(props.VariableUnits)
        props.VariableUnits(rowtimesIndex) = [];
    end
    if ~isempty(props.VariableContinuity)
        props.VariableContinuity(rowtimesIndex) = [];
    end
end
newdDimNames = props.DimensionNames;
newdDimNames{1} = rowtimesName; 
props = rmfield(props,'RowNames');
props = rmfield(props,'DimensionNames');
props = rmfield(props,'VariableNames');
% Construct Adaptor
tt.Adaptor = matlab.bigdata.internal.adaptors.TimetableAdaptor(varNames, ...
    varAdaptors, newdDimNames, rowtimesAdaptor, props);
