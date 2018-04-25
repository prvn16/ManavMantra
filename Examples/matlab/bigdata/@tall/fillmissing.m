function [F, TF] = fillmissing(A, method, varargin)
%FILLMISSING - Fill missing values
%
%   F = FILLMISSING(A,'constant',v)
%   F = FILLMISSING(A,method)
%   F = FILLMISSING(A,movmethod,window)
%   F = FILLMISSING(___,dim)
%   F = FILLMISSING(___,Name,Value)
%   [F,TF] = v(___)
%
%   Limitations:
%   1) FILLMISSING(A,'spline') is not supported
%   2) FILLMISSING(___,'SamplePoints',X) is not supported
%   3) 'DataVariables' cannot be specified as a function_handle
%   4) For FILLMISSING(A,'constant',v) v must be a scalar
%   5) FILLMISSING(___,'EndValues',Value), Value must be 'extrap'
%   6) FILLMISSING(A,movmethod,window) is not supported when A is a 
%      tall timetable
%   7) FILLMISSING(A,___) does not support character vector
%      variables when A is a tall table or tall timetable.
%
%   See also FILLMISSING

% Copyright 2017 The MathWorks, Inc.

narginchk(2,9);
nargoutchk(0,2);
tall.checkIsTall(upper(mfilename), 1, A);
tall.checkNotTall(upper(mfilename), 1, method, varargin{:});

allowedArrayTypes = ...
    {'numeric', 'logical', 'categorical', ...
    'datetime', 'duration', 'calendarDuration', ...
    'string', 'char', 'cellstr'};

A = tall.validateType(A, mfilename, ...
    [allowedArrayTypes {'table', 'timetable'}], 1);

fillOpts = iParseInputs(A, method, varargin{:});

if iIsTabular(A)
    % Validate the table variables selected by the DataVariables filter
    validateVarFcn = ...
        @(t) iCheckTableVarType(t, fillOpts.Method, fillOpts.DataVariables);
    adaptor = A.Adaptor;
    A = elementfun(validateVarFcn, A);
    A.Adaptor = adaptor;
    
end

if strcmpi(fillOpts.Method, 'spline')
    error(message('MATLAB:bigdata:array:FillmissingSplineUnsupported'));
end

if strcmpi(fillOpts.Method, 'constant')
    [F, TF] = iFillConstant(A, fillOpts);
else
    [F, TF] = iFillStencil(A, fillOpts);
end

% Ensure that the outputs have correct adaptors set
[F, TF] = iSetOutputAdaptors(A, F, TF);
end

%--------------------------------------------------------------------------
function [F, TF] = iSetOutputAdaptors(A, F, TF)
% Both outputs will always have same size as input.
F.Adaptor = A.Adaptor;
TF.Adaptor = A.Adaptor;

% Second output is always logical
TF = setKnownType(TF, 'logical');
end

%--------------------------------------------------------------------------
function [F, TF] = iFillStencil(A, opts)
% Fill missing values using a stencil method

import matlab.bigdata.internal.util.isGathered

% The primitive used depends on the dimension we are filling in as well as
% the fill method.  The following sets up the following execution branches:
%
% 1) Fill along tall dimension uses a primitive that manages boundary
%    communication between partitions according to the interp method rules.
% 2) Fill in any other dimension is processed using slicefun.

if startsWith(opts.Method, 'mov')
    % Fill in tall dimension using a fixed window-size with stencilfun
    [stencilF, stencilTF] = stencilfun(...
        @(varargin) iFillMovStencilFcn(varargin{:}, opts.Method, opts.DataVariables),...
        opts.MethodArg, A);
    
    [sliceF, sliceTF] = slicefun(...
        @(x, dim) fillmissing(x, opts.Method, opts.MethodArg, dim), ...
        A, opts.Dim);
else
    % Fill in tall dimension using interp methods by using a variable-width
    % window defined by non-missing values
    [stencilF, stencilTF] = fillmissingInterpStencil(A, opts.Method, opts.DataVariables);

    [sliceF, sliceTF] = slicefun(...
        @(x, dim) fillmissing(x, opts.Method, dim), ...
        A, opts.Dim);
end

[dimIsKnown, dimValue] = isGathered(hGetValueImpl(opts.Dim));

if dimIsKnown
    % Dim is known on the client so can directly select the correct
    % execution branch.
    [F, TF] = iFillMovInDim(stencilF, stencilTF, sliceF, sliceTF, dimValue);
    % No need to set adaptors as they are set by the caller
else
    % Dim is unknown, defer conditional selection using an elementfun to
    % pick the correct execution branch
    % First ensure that the output adaptors are set for the two possible
    % execution branches
    [stencilF, stencilTF] = iSetOutputAdaptors(A, stencilF, stencilTF);
    [sliceF, sliceTF] = iSetOutputAdaptors(A, sliceF, sliceTF);
    
    [F, TF] = elementfun(...
        @iFillMovInDim, ...
        stencilF, stencilTF, sliceF, sliceTF, opts.Dim);
    % No need to set adaptors as they are set by the caller
end
end

%--------------------------------------------------------------------------
function [F, TF] = iFillMovStencilFcn(info, x, movMethod, dataVars)
% Fills missing values in tall dimension using moving window method

import matlab.bigdata.internal.util.indexSlices

if istable(x) || istimetable(x)
    % Fillmissing on a tabular type has correct default behavior of filling
    % along the tall dimension.
    [F,TF] = fillmissing(x, movMethod, info.Window, 'DataVariables', dataVars);
else
    % Always supply the dim argument for non-tabular types
    tallDim = 1;
    [F,TF] = fillmissing(x, movMethod, info.Window, tallDim);
end

% Remove padding slices
validSlices = 1 + info.Padding(1) : size(x,1) - info.Padding(2);
F = indexSlices(F, validSlices);
TF = indexSlices(TF, validSlices);
end

%--------------------------------------------------------------------------
function [F, TF] = iFillMovInDim(stencilF, stencilTF, sliceF, sliceTF, dim)
% Selects between the two possible execution branches for fillmissing using
% a moving window.

if dim == 1
    % Tall Dim => emit the stencilfun result
    F = stencilF;
    TF = stencilTF;
else
    % Any other dim => emit slicefun result
    F = sliceF;
    TF = sliceTF;
end
end

%--------------------------------------------------------------------------
function [F, TF] = iFillConstant(A, fillOpts)
% Set up elementwise operation to fill using supplied constant

import matlab.bigdata.internal.broadcast

lazyDim = fillOpts.Dim;
fillOpts.Dim = [];

[F, TF] = elementfun(@iFillConstantFcn, A, broadcast(size(A)), lazyDim, broadcast(fillOpts));
% No need to set adaptor as it is set by the caller
end

%--------------------------------------------------------------------------
function [F, TF] = iFillConstantFcn(A, sizeA, dim, fillOpts)
% Fill missing values using supplied constant
% Assumes that 'EndValues' is 'extrap' so that the same fill method is used
% in every partition

% Make sure array and fill constant are consistent with one another
% Check the types as well as handle empty input
C = fillOpts.MethodArg;
iCheckConstantType(A, C);
iCheckForEmpty(sizeA, dim, C);

% Fillmissing errors when A is empty and constant is not
% Guard against empty partitions by emitting empties of the correct
% type & shape.
if isempty(A)
    F = A;
    TF = false(size(A));
    return;
end

% Call fillmissing(A,'constant',___) with the correct arguments
fillArgs = {'constant', C};

if ~(istable(A) || istimetable(A))
    % Non-tabular: Always supply the overall dim argument so that we fill
    % along the correct dimension regardless of the partitioning
    fillArgs = [fillArgs, dim];
end

nvPairs = {'EndValues', 'extrap'};

if ~isempty(fillOpts.DataVariables)
    nvPairs = [nvPairs {'DataVariables', fillOpts.DataVariables}];
end

[F, TF] = fillmissing(A, fillArgs{:}, nvPairs{:});
end

%--------------------------------------------------------------------------
function opts = iParseInputs(A, method, varargin)
% Parse and check inputs for tall/fillmissing

opts.Method = iCheckFillMethod(method);

% Setup defaults
opts.MethodArg = [];
opts.EndMethod = 'extrap';

inputIsTabular = iIsTabular(A);

if inputIsTabular
    % Table & timetable default to filling rows with missing entries
    opts.Dim = tall.createGathered(1);
    
    % DataVariables defaults to using all the variable names
    varNames = subsref(A, substruct('.', 'Properties', '.', 'VariableNames'));
    opts.DataVariables = (1:numel(varNames));
else
    % Arrays follow the first non-singleton dim rule
    opts.Dim = findFirstNonSingletonDim(A);
    opts.DataVariables = [];
end

% constant, movmean, and movmedian methods require an additional arg to
% determine how missing values will be filled
argId = 1;

if iRequiresMethodArg(opts.Method)
    if nargin < 3
        error(message(['MATLAB:fillmissing:' opts.Method 'Input']));
    end
    
    if startsWith(opts.Method, 'mov')
        if strcmpi(tall.getClass(A), 'timetable')
            error(message('MATLAB:bigdata:array:FillmissingMovmethodTimetable', opts.Method));
        end
        
        movOpts = parseMovOpts(str2func(opts.Method), varargin{argId});
        opts.MethodArg = movOpts.window;
    else
        opts.MethodArg = iCheckFillConstantArg(varargin{argId});
    end
    argId = argId + 1;
end

if isempty(varargin(argId:end))
    % No optional inputs - use defaults
    return;
end

if isnumeric(varargin{argId}) || islogical(varargin{argId})
    % dim arg supplied
    % Not supported for table inputs
    if inputIsTabular
        error(message('MATLAB:fillmissing:DimensionTable'));
    end
    
    try
        opts.Dim = matlab.internal.math.getdimarg(varargin{argId});
        opts.Dim = tall.createGathered(opts.Dim);
        argId = argId + 1;
    catch
        error(message('MATLAB:fillmissing:DimensionInvalid'));
    end
end

if rem(length(varargin(argId:end)), 2) ~= 0
    error(message('MATLAB:fillmissing:NameValuePairs'));
end

% Parse out N-V pairs
for ii = argId:2:length(varargin)
    name = varargin{ii};
    value = varargin{ii+1};
    
    if iMatchNameArg(name, 'SamplePoints')
        error(message('MATLAB:bigdata:array:SamplePointsNotSupported'));
    elseif iMatchNameArg(name, 'EndValues')
        opts.EndMethod = iCheckEndValuesArg(value);
    elseif iMatchNameArg(name, 'DataVariables')
        opts.DataVariables = checkDataVariables(A, value, mfilename);
    else
        error(message('MATLAB:fillmissing:NameValueNames'));
    end
end

end

%--------------------------------------------------------------------------
function method = iCheckFillMethod(method)
% Check and resolve the supplied fill method

validMethods = {'constant','previous','next','nearest','linear',...
    'spline','pchip','movmean','movmedian'};
try
    method = validatestring(method, validMethods);
catch
    error(message('MATLAB:fillmissing:MethodInvalid'));
end
end

%--------------------------------------------------------------------------
function arg = iCheckFillConstantArg(arg)
if isempty(arg)
    % Whether an empty fill constant is valid depends on the input size and
    % filling dim.
    return;
end

if ischar(arg)
    if ~isrow(arg)
        error(message('MATLAB:fillmissing:CharRowVector'));
    end
else
    if ~isscalar(arg)
        error(message('MATLAB:bigdata:array:FillmissingUnsupportedConstant'));
    end
end
end

%--------------------------------------------------------------------------
function endValue = iCheckEndValuesArg(endValue)
% Check and resolve the supplied 'EndValues' arg

% Only 'extrap' is supported for tall arrays
validEndValues = {'extrap'};
try
    endValue = validatestring(endValue, validEndValues);
catch
    error(message('MATLAB:bigdata:array:FillmissingUnsupportedEndValues'));
end
end

%--------------------------------------------------------------------------
function tf = iMatchNameArg(arg, name)
% Performs case-insensitive partial matching of arg to name

tf = isNonTallScalarString(arg) && startsWith(name, arg, 'IgnoreCase', true);
end

%--------------------------------------------------------------------------
function tf = iRequiresMethodArg(method)
tf = ismember(method, {'constant', 'movmean', 'movmedian'});
end

%--------------------------------------------------------------------------
function tf = iIsTabular(tX)
inputClass = tX.Adaptor.Class;
tf = any(strcmpi(inputClass, {'table', 'timetable'}));
end

%--------------------------------------------------------------------------
% All functions below contain logic or even entire helper functions copied
% toolbox/matlab/datafun/fillmissing.m
% necessary modifications applied to make this work for tall
%--------------------------------------------------------------------------
function iCheckForEmpty(sizeA, dim, C)
% Check that the fill constant C has size consistent with the input array A
% This is necessary to ensure the correct behavior for empty inputs.
%
% Copied and modified from datafun/fillmissing>checkConstantSize

inputIsEmpty = prod(sizeA) == 0;

if inputIsEmpty && ~isempty(C)
    % Input is not allowed to be empty when the fill constant is not empty
    error(message('MATLAB:fillmissing:SizeConstantEmpty'));
end

if ischar(C) || isscalar(C)
    % Valid case for non-empty tall array: char row vector or scalar of any
    % other type 
    return;
end

% Dealing with a combination of empty inputs that may or may not be valid.
% Use the input size and filling dim to work out whether to error
ndimsA = numel(sizeA);
if dim <= ndimsA
    sizeA(dim) = [];
    nVects = prod(sizeA);
else
    % fillmissing(A,'constant',c) supported
    % fillmissing(A,METHOD,'EndValues',constant_value) supported
    numelA = prod(sizeA);
    nVects = numelA;
end

if numel(C) ~= nVects
    error(message('MATLAB:bigdata:array:FillmissingUnsupportedConstant'));
end
end

%--------------------------------------------------------------------------
function iCheckConstantType(A,C)
% Check if constant type matches the array type
%
% Copied and modified from datafun/fillmissing>checkConstantType

if isnumeric(A) && ~isnumeric(C) && ~islogical(C)
    error(message('MATLAB:fillmissing:ConstantNumeric'));
elseif isdatetime(A) && ~isdatetime(C)
    error(message('MATLAB:fillmissing:ConstantDatetime'));
elseif isduration(A) && ~isduration(C)
    error(message('MATLAB:fillmissing:ConstantDuration'));
elseif iscalendarduration(A) && ~iscalendarduration(C)
    error(message('MATLAB:fillmissing:ConstantCalendarDuration'));
elseif iscategorical(A)
    if (~ischar(C) && ~iscellstr(C) && ~isstring(C))
        % categorical fill constants not supported
        error(message('MATLAB:fillmissing:ConstantCategorical'));
    end
elseif ischar(A) && ~ischar(C)
    error(message('MATLAB:fillmissing:ConstantChar'));
elseif iscellstr(A)
    if ~(ischar(C) || iscellstr(C))
        % string constants not supported
        error(message('MATLAB:fillmissing:ConstantCellstr'));
    end
elseif isstring(A) && ~isstring(C)
    % char and cellstr constants not supported
    error(message('MATLAB:fillmissing:ConstantString'));
end
end

%--------------------------------------------------------------------------
function A = iCheckTableVarType(A, method, dataVars)
% Check if array types match
%
% Copied and modified from datafun/fillmissing>checkArrayType

for jj = dataVars
    Avar = A{:, jj};
    
    if ~iIsSupportedArray(Avar)
        error(message('MATLAB:fillmissing:UnsupportedTableVariable',class(Avar)));
    end
    
    if ~(isnumeric(Avar) || islogical(Avar) || isduration(Avar) || isdatetime(Avar)) && ...
            ~ismember(method, {'nearest','next','previous','constant'})
        error(message('MATLAB:fillmissing:InterpolationInvalidTableVariable',method));
    end
    
    if ischar(Avar)
        error(message('MATLAB:bigdata:array:FillmissingUnsupportedCharVar'));
    end
end
end

%--------------------------------------------------------------------------
function tf = iIsSupportedArray(A)
% Copied and modified from datafun/fillmissing>isSupportedArray

tf = isnumeric(A) || islogical(A) || ...
     isstring(A) || iscategorical(A) || iscellstr(A) || ischar(A) || ...
     isdatetime(A) || isduration(A) || iscalendarduration(A);
end
