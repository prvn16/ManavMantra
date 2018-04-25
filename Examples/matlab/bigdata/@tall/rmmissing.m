function [B, I] = rmmissing(A,varargin)
%RMMISSING   Remove rows or columns with missing entries
%
%   B = rmmissing(A)
%   B = rmmissing(A,dim)
%   B = rmmissing(___,Name,Value)
%   [B,I] = rmmissing(___)
%
%   Limitations:
%   1) 'DataVariables' cannot be specified as a function_handle
%   2) rmmissing(A,2) is not supported for tall tables.
%
%   See also RMMISSING

% Copyright 2017 The MathWorks, Inc.

narginchk(1,6);
nargoutchk(0,2);
tall.checkIsTall(upper(mfilename), 1, A);
tall.checkNotTall(upper(mfilename), 1, varargin{:});

A = tall.validateType(A, mfilename, ...
    {'numeric', 'logical', 'categorical', ...
    'datetime', 'duration', 'calendarDuration', ...
    'string', 'char', 'cellstr', ...
    'table', 'timetable'}, 1);

if A.Adaptor.NDims > 2
    error(message('MATLAB:rmmissing:NDArrays'));
end

if iIsTabular(A)
    for ii = 1 : width(A)
        S = substruct('.', ii);
        A = subsasgn(A, S, tall.validateMatrix(subsref(A, S), 'MATLAB:rmmissing:NDArrays'));
    end
else
    A = tall.validateMatrix(A, 'MATLAB:rmmissing:NDArrays');
end

[dim, minNumMissing, dataVars] = iParseInputs(A, varargin{:});

% First find where the missing values are
if iIsTabular(A)
    I = slicefun(@(t) ismissing(t(:, dataVars)), A);
else
    I = ismissing(A);
end

% Create filters for removing either missing rows or missing columns.
% Row filter is a slice-wise operation to create a tall logical column
% vector with the same tall size as the input
Irows = slicefun(@(tf) sum(tf, 2) >= minNumMissing, I);

if strcmpi(A.Adaptor.Class, 'timetable')
    % For timetables, also need to remove any missing row times
    rmMissingRowTimes = @(t, ism) ism | ismissing(t.Properties.RowTimes);
    Irows = slicefun(rmMissingRowTimes, A, Irows);
end

Irows.Adaptor = setKnownSize(Irows.Adaptor, [NaN 1]);
Irows.Adaptor = copyTallSize(Irows.Adaptor, A.Adaptor);

% Column filter is a reduction down to a logical row vector that has the
% same length as A is wide
Icols = reducefun(@(tf) sum(tf, 1) >= minNumMissing, I);

Icols.Adaptor = setKnownSize(Icols.Adaptor, [1 NaN]);

if A.Adaptor.isSmallSizeKnown
    Icols.Adaptor = resetSmallSizes(Icols.Adaptor, A.Adaptor.SmallSizes);
end

[dimIsKnown, dimValue] = iCheckDim(dim);

if dimIsKnown
    if dimValue == 1
        % Use the row filter to remove missing rows
        I = Irows;
        B = filterslices(~I, A);
        B.Adaptor = A.Adaptor;
        B.Adaptor = resetTallSize(B.Adaptor);
    else
        % Use the column filter to remove missing cols
        I = Icols;
        B = slicefun(@(a, ic) a(:, ~ic), A, I);
        B.Adaptor = A.Adaptor;
        B.Adaptor = resetSmallSizes(B.Adaptor, NaN);
    end
    
    I = setKnownType(I, 'logical');
else
    % Conditionally apply the correct filter, depending on the value of dim
    [B, I] = partitionfun(@iRmRowsOrCols, A, Irows, Icols, dim, isscalar(A));
    [B, I] = iSetOutputAdaptors(A, B, I);
    % As B and I are derived from partitionfun, the framework assumes these
    % contain partition dependent data. We must correct this before them to
    % the user.
    [B, I] = copyPartitionIndependence(B, I, A);
end
end

%--------------------------------------------------------------------------
function [hasFinished, B, I] = iRmRowsOrCols(info, A, Irows, Icols, dim, inputIsScalar)
% Remove either rows or cols that contain at least minNumMissing values,
% depending on the deferred value of dim.

if dim == 1 || inputIsScalar
    % Remove rows
    B = A(~Irows, :);
    I = Irows;
else
    % Remove cols
    B = A(:, ~Icols);
    
    % Conditionally emit the column filter for the second output
    if info.PartitionId == 1
        I = Icols;
    else
        I = matlab.bigdata.internal.util.indexSlices(Icols, []);
    end
end

hasFinished = info.IsLastChunk;
end

%--------------------------------------------------------------------------
function [dim, minNumMissing, dataVars] = iParseInputs(A, varargin)
% Parse and validate optional inputs for tall/rmmissing

% Defaults
if iIsTabular(A)
    % Table & timetable default to removing rows with missing entries
    dim = tall.createGathered(1);
    
    % DataVariables defaults to using all the variable names
    dataVars = subsref(A, substruct('.', 'Properties', '.', 'VariableNames'));
else
    % Arrays follow the first non-singleton dim rule
    dim = findFirstNonSingletonDim(A);
    dim = lazyValidate(dim, {@(d) d==1 || d==2, 'MATLAB:rmmissing:NDArrays'});
    dataVars = [];
end

minNumMissing = 1;

if isempty(varargin)
    % No optional inputs - use defaults
    return;
end

optionalInputs = varargin;
argId = 1;

if ~isNonTallScalarString(optionalInputs{argId})
    dim = matlab.internal.math.getdimarg(varargin{1});
    
    if dim > 2
        error(message('MATLAB:rmmissing:DimensionInvalid'));
    end
    
    if dim == 2 && iIsTabular(A)
        error(message('MATLAB:bigdata:array:RmmissingUnsupportedTableColRemoval'));
    end
    
    dim = tall.createGathered(dim);
    
    argId = argId + 1;
end

if rem(length(optionalInputs) - argId + 1, 2) ~= 0
    error(message('MATLAB:rmmissing:NameValuePairs'));
end

for ii = argId:2:length(optionalInputs)
    name = optionalInputs{ii};
    value = optionalInputs{ii+1};
    
    if iMatchNameArg(name, 'MinNumMissing')
        minNumMissing = iCheckMinNumMissingArg(value);
    elseif iMatchNameArg(name, 'DataVariables')
        dataVars = checkDataVariables(A, value, mfilename);
    else
        error(message('MATLAB:rmmissing:NameValueNames'));
    end
end
end

%--------------------------------------------------------------------------
function tf = iIsTabular(A)
% tf is true when input A is either a table or timetable

inputClass = A.Adaptor.Class;
tf = any(strcmpi(inputClass, {'table', 'timetable'}));
end

%--------------------------------------------------------------------------
function tf = iMatchNameArg(arg, name)
% Performs case-insensitive partial matching of arg to name

tf = isNonTallScalarString(arg) && startsWith(name, arg, 'IgnoreCase', true);
end

%--------------------------------------------------------------------------
function arg = iCheckMinNumMissingArg(arg)
% Validate 'MinNumMissing' value is a nonnegative integer

% Condition logic copied from toolbox/matlab/datafun/rmmissing.m
if (~isnumeric(arg) && ~islogical(arg)) || ~isscalar(arg) || ~isreal(arg) || fix(arg) ~= arg || ~(arg >= 0)
    error(message('MATLAB:rmmissing:MinNumMissing'));
end
end

%--------------------------------------------------------------------------
function [B, I] = iSetOutputAdaptors(A, B, I)
% Setup the output adaptors for the case where the dim could not be
% determined upfront

import matlab.bigdata.internal.adaptors.getAdaptorForType

% We at least know that both outputs are 2-D
szVec = [NaN NaN];
B.Adaptor = resetSizeInformation(A.Adaptor);
B.Adaptor = setKnownSize(B.Adaptor, szVec);

I.Adaptor = getAdaptorForType('logical');
I.Adaptor = setKnownSize(I.Adaptor, szVec);
end

%--------------------------------------------------------------------------
function [dimIsKnown, dimValue] = iCheckDim(dim)
% Given deferred dim, check whether the result is known and its local
% value.  The value will be [] when the dim is unknown.

import matlab.bigdata.internal.util.isGathered

[dimIsKnown, dimValue] = isGathered(hGetValueImpl(dim));
end
