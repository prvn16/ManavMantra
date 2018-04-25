function tt = array2table(ta, varargin)
%ARRAY2TABLE Convert tall matrix to table
%   TT = ARRAY2TABLE(TA)
%   TT = ARRAY2TABLE(..., 'VariableNames', {'name1', ..., 'name_M'}) 
%
%   Limitations:
%   The parameter 'RowNames' is not supported.
%
%   See also ARRAY2TABLE, TALL, TABLE.

% Copyright 2016-2017 The MathWorks, Inc.

tall.checkIsTall(mfilename, 1, ta);
tall.checkNotTall(mfilename, 1, varargin{:});

p = inputParser();
p.addParameter('VariableNames', [], @iCheckVariableNames);
p.addParameter('RowNames', [], @iCheckRowNames);
p.parse(varargin{:});

varNames = p.Results.VariableNames;
if ~iscell(varNames)
    varNames = iDetermineVariableNames(ta, inputname(1));
else
    adaptor = ta.Adaptor;
    numActualVariables = getSizeInDim(adaptor, 2);
    if ~isnan(numActualVariables) && numActualVariables ~= numel(varNames)
        error(message('MATLAB:table:IncorrectNumberOfVarNames'));
    end 
end

tt = slicefun(@(a) array2table(a, 'VariableNames', varNames), ta);

adaptor = resetSizeInformation(ta.Adaptor);
adaptor = copyTallSize(adaptor, ta.Adaptor);
adaptor = setSmallSizes(adaptor, 1);
adaptors = repmat({adaptor}, 1, numel(varNames));
tt.Adaptor = matlab.bigdata.internal.adaptors.TableAdaptor(varNames, adaptors);

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

function tf = iCheckVariableNames(names)
% Check that the VariableNames name-value input parameter is valid.

checkVariableNames(names)
tf = true;

function tf = iCheckRowNames(~) %#ok<STOUT>
% Check that the RowNames name-value input parameter is valid.

% This is only called if the user explicitly provides the RowNames
% name-value pair. As RowNames is not supported by table, we error.
error(message('MATLAB:bigdata:array:InvalidTableFlag'));
