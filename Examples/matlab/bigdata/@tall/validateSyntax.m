function validateSyntax(fcn, inputs, varargin)
% Validate invoked syntax of a tall method by calling the non-tall equivalent.
%
% This function should ONLY be used for:
%  1. Validating correctness of non-tall input arguments.
%  2. Guarding against unsupported strong types (table, timetable,
%     string, categorical, datetime, duration or calendarDuration).
%
% This function should NOT be used if:
%  1. Validation of parameters depends on the actual data.
%  2. Validation is different between any two non-strong types. This
%     includes numeric types (both floating and integer), logical and cell.
%
% Further:
%  3. If validation depends on the size of actual data, you must use the
%     DefaultSize property with an appropriate size.
%
% Syntax:
%
%  tall.validateSyntax(FCN,INPUTS,'DefaultType',TYPE) converts any tall in
%    cell array INPUTS to a fabricated sample of height 1 and then invokes
%    FCN on INPUTS with a single output argument. All tall arrays of
%    unknown type adopt the default type TYPE.
%
%  tall.validateSyntax(..'DefaultSize',SIZE) provides a default size for tall
%    inputs. If unspecified, the default size is [1,1].
%
%  tall.validateSyntax(..'NumOutputs',NUMOUTPUTS) specifies the number of
%    outputs to invoke the function with. If unspecified, the default
%    number of outputs is 1.
%
% This invokes the given function handle with all tall input arguments
% replaced by fabricated samples. These samples are not guaranteed to be
% accurate:
%  1. The values will be not be accurate. They will be all ones.
%  2. The size will not always be accurate. If size is not known, a default
%     is used.
%  3. The type will not always be accurate. If type is not known, a default
%     is used. You can only trust the type if it is a strong type.
%
% Example of use:
%
%  function out = sort(tX, varargin)
%
%  % 1. Ensure that parameter input arguments are not tall.
%  tall.checkIsTall(upper(mfilename), 1, tX);
%  tall.checkNotTall(upper(mfilename), 1, varargin{:});
%
%  % 2. Deal with validation of the tall input. The sort function has
%  %    different behaviour between cell and any other type. We handle this
%  %    explicitly not supporting cell.
%  if strcmp(tall.getClass(tX), 'cell')
%      error(message('MATLAB:bigdata:array:SortCellUnsupported','SORT'));
%  end
%  tX = lazyValidate(tX, {@(x)~iscell(x), 'MATLAB:bigdata:array:SortCellUnsupported'});
%
%  % 3. Now use validateSyntax to check the parameters. As we disallowed
%  %    cell, all remaining non-strong types now act like double.
%  tall.validateSyntax(@sort, [{tX}, varargin], 'DefaultType', 'double');
%
%  % 4. We can now assume parameters are correct.
%  if nargin == 1 || nargin >= 2 && ~isnumeric(varargin{1})
%      error(message('MATLAB:bigdata:array:SortDimRequired'));
%  end
%  dim = varargin{1};
%
%  %...
%

% Copyright 2017 The MathWorks, Inc.

assert(isa(fcn, 'function_handle'), ...
    'Assertion failed: validateSyntax expects FCN to be a function handle.');
assert(iscell(inputs), ...
    'Assertion failed: validateSyntax expects INPUTS to be a cell array of inputs.');

[defaultType, defaultSize, numOutputs] = iParseOtherInputs(varargin{:});

assert(~isempty(defaultType), ...
    'Assertion failed: validateSyntax requires a non-empty default type.');

for ii = 1 : numel(inputs)
    if istall(inputs{ii})
        adaptor = matlab.bigdata.internal.adaptors.getAdaptor(inputs{ii});
        inputs{ii} = buildSample(adaptor, defaultType, defaultSize);
    end
end

try
    [varargout{1 : numOutputs}] = fcn(inputs{:}); %#ok<NASGU>
catch err
    throwAsCaller(err);
end

function [defaultType, defaultSize, numOutputs] = iParseOtherInputs(varargin)
% Parse the name-value pairs supported by validateSyntax.
p = inputParser;
p.addParameter('DefaultType', '');
p.addParameter('DefaultSize', [1, 1]);
p.addParameter('NumOutputs', 1);
p.parse(varargin{:});

defaultType = p.Results.DefaultType;
assert(isNonTallScalarString(defaultType), ...
    'Assertion Failed: validateSyntax expects DefaultType to be a string or character row vector.');
defaultType = char(defaultType);

defaultSize = p.Results.DefaultSize;
assert(isnumeric(defaultSize) && isrow(defaultSize), ...
    'Assertion Failed: validateSyntax expects DefaultSize to be a numeric row vector.');
defaultSize = double(defaultSize);

numOutputs = p.Results.NumOutputs;
assert(isnumeric(numOutputs) && isscalar(numOutputs) && mod(numOutputs, 1) == 0 && numOutputs >= 0, ...
    'Assertion Failed: validateSyntax expects NumOutputs to be a non-negative scalar integer.');
numOutputs = double(numOutputs);
