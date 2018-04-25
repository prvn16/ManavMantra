function tt = array2timetable(ta, varargin)
%ARRAY2TIMETABLE Convert tall matrix to timetable
%   TT = ARRAY2TIMETABLE(TX,"RowTimes",ROWTIMES)
%   TT = ARRAY2TIMETABLE(TX,"RowTimes",ROWTIMES,"VariableNames",VARNAMES)
%
%   See also ARRAY2TIMETABLE, TALL, TIMETABLE.

% Copyright 2017 The MathWorks, Inc.

tall.checkIsTall(mfilename, 1, ta);

p = inputParser();
p.addParameter("VariableNames", [], @iCheckVariableNames);
p.addParameter("RowTimes", [], @iCheckRowTimes);
p.parse(varargin{:});

varNames = p.Results.VariableNames;
if iscell(varNames)
    adaptor = ta.Adaptor;
    numActualVariables = getSizeInDim(adaptor, 2);
    if ~isnan(numActualVariables) && numActualVariables ~= numel(varNames)
        error(message("MATLAB:table:IncorrectNumberOfVarNames"));
    end
else
    % Assume unspecified
    varNames = iDetermineVariableNames(ta, inputname(1));
end

% RowTimes must be supplied, and must be a tall vector with the same height
% as the array.
if ismember("RowTimes", p.UsingDefaults)
    error(message("MATLAB:array2timetable:RowTimeRequired"));
end
rowtimes = p.Results.RowTimes;
if ~istall(rowtimes)
    error(message('MATLAB:bigdata:array:Array2timetableInvalidRowTimes'));
end
[ta, rowtimes] = validateSameTallSize(ta, rowtimes);

% Apply the transformation
tt = slicefun(@(a,t) array2timetable(a, "RowTimes", t, "VariableNames", varNames), ...
    ta, rowtimes);

% We must correctly set the adaptor for both the timetable and all of its
% constituent variables.
adaptor = resetSizeInformation(ta.Adaptor);
adaptor = copyTallSize(adaptor, ta.Adaptor);
adaptor = setSmallSizes(adaptor, 1);
varAdaptors = repmat({adaptor}, 1, numel(varNames));
tt.Adaptor = matlab.bigdata.internal.adaptors.TimetableAdaptor( ...
    varNames, varAdaptors, {'Time','Variables'}, rowtimes.Adaptor);

end

% Determine the variable names from inputname and an input array
function varNames = iDetermineVariableNames(ta, name)
numVariables = getSizeInDim(ta.Adaptor, 2);
if isnan(numVariables)
    numVariables = gather(size(ta, 2));
end

if numVariables == 1 && ~isempty(name)
    varNames = {name};
    return;
end

if isempty(name)
    name = 'Var';
end
varNames = cellstr(string(name) + (1 : numVariables));
end


function tf = iCheckVariableNames(names)
% Check that the VariableNames name-value input parameter is valid.
checkVariableNames(names)
tf = true;
end


function tf = iCheckRowTimes(rowtimes)
% Check that the RowTimes name-value input parameter is valid.
% Must be a tall array of datetime or duration

adap = matlab.bigdata.internal.adaptors.getAdaptor(rowtimes);
tf = ismember(adap.Class, ["datetime", "duration"]);
end