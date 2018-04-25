function tt = timetable(varargin)
%TIMETABLE Build a tall timetable from tall arrays
%   TT =  TIMETABLE(TROWTIMES, TVAR1, TVAR2, ...) creates a tall timetable
%   TT from tall arrays TVAR1, TVAR2, ..., using the tall datetime or
%   duration vector TROWTIMES as the time vector. All arrays must be tall
%   and have the same number of rows.
%
%   TT = TIMETABLE(TVAR1, VTAR2, ..., 'RowTimes',TROWTIMES) creates a timetable
%   using the specified tall datetime or duration vector, TROWTIMES, as the time
%   vector. Other datetime or duration inputs become variables in TT.       
%
%   TT = TIMETABLE(..., 'VariableNames', {'name1', ..., 'name_M'}) creates a
%   timetable containing variables that have the specified variable names.
%   The names must be valid MATLAB identifiers, and unique.
%
%   See also tall, timetable.

% Copyright 2016-2017 The MathWorks, Inc.

% Attempt to deal with trailing p-v pairs.
numVars = countVarInputs(varargin);
vars = varargin(1:numVars);

if numVars < nargin
    pnames = {'VariableNames'  'RowTimes'};
    dflts =  {            []           []};
    [varnames,rowtimes,supplied] ...
            = matlab.internal.datatypes.parseArgs(pnames, dflts, varargin{numVars+1:end});
else
    supplied.VariableNames = false;
    supplied.RowTimes = false;
end

if ~supplied.VariableNames
    % Get the workspace names of the input arguments from inputname if
    % variable names were not provided. Need these names before looking
    % through vars for the time vector.
    varnames = repmat({''},1,numVars);
    for i = 1:numVars
        varnames{i} = inputname(i);
    end
end

% Setup rowtimes 
rowtimesName = getString(message('MATLAB:timetable:uistrings:DfltRowDimName'));
if ~supplied.RowTimes
    rowtimes = vars{1};
    % Without rowtimes, first argument must be datetime or duration
    rowtimes = tall.validateType(rowtimes, mfilename, {'datetime', 'duration'}, 1);
    vars(1) = [];
    if ~supplied.VariableNames
        if ~isempty(varnames{1})
            rowtimesName = varnames{1};
        end
        varnames(1) = [];
    end
end

% Check for tall 
if ~istall(rowtimes)
    % rowtimes must be tall.
    error(message('MATLAB:bigdata:array:AllTableArgsTall'))
end
if ~all(cellfun(@istall, vars))
    % all data must be tall
    error(message('MATLAB:bigdata:array:AllTableArgsTall'));
end

if ~supplied.VariableNames
    % Fill in default names for data args where inputname couldn't. Do
    % this after removing the time vector from the other vars, to get the
    % default names numbered correctly.
    empties = cellfun('isempty',varnames);
    if any(empties)
        varnames(empties) = matlab.internal.tabular.defaultVariableNames(find(empties)); %#ok<FNDSB>
    end
    % Make sure default names or names from inputname don't conflict
    varnames = matlab.lang.makeUniqueStrings(varnames,{},namelengthmax);
else
    % Check that supplied names are strings and are unique
    if ~matlab.internal.datatypes.isCharStrings(varnames,true,false)
        error(message('MATLAB:table:InvalidVarNames'));
    end
    if numel(unique(varnames)) ~= numel(varnames)
        % Find the duplicate name
        [~,~,idx] = unique(varnames);
        dup = find(accumarray(idx,ones(size(idx)))>1,1,'first');
        error(message('MATLAB:table:DuplicateVarNames', varnames{dup}));
    end
end

if ismember(rowtimesName, varnames)
    error(message('MATLAB:table:DuplicateDimNamesVarNames', rowtimesName));
end

if numel(varnames) ~= numel(vars)
    error(message('MATLAB:table:IncorrectNumberOfVarNames'));
end

varDimNames = getString(message('MATLAB:timetable:uistrings:DfltVarDimName'));
dimNames = {rowtimesName, varDimNames};
tt = makeTallTimetableWithDimensionNames(dimNames, rowtimes, varnames, ...
                                         MException.empty(), vars{:});
end

function numVars = countVarInputs(args)
% Counting number of inputs, any string or char row vector is considered
% the beginning of p-v pair
numVars = 0;
for i = 1:length(args)
    numVars = i;
    if matlab.internal.datatypes.isCharString(args{i})
        numVars = numVars - 1;
        return
    end
end
end
