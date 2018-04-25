function varargout = funfunCommon(funfun, userfun, validTypes, varargin)
%funfunCommon Common implementation for arrayfun and cellfun
%   VARARGOUT = funfunCommon(FUNFUN, USERFUN, VALIDTYPES, ARGS...) calls
%   FUNFUN(USERFUN,ARGS...). FUNFUN is expected to be @cellfun or
%   @arrayfun. USERFUN is the user-supplied function handle (or char-vector).
%   VALIDTYPES is a cell array of valid types for the data arguments, or
%   {} if no list of valid types is known.

%   Copyright 2016-2017 The MathWorks, Inc.

funfunName = func2str(funfun);
FUNFUNNAME = upper(funfunName);

if ~isa(userfun, 'function_handle')
    iThrowFunfunError(funfunName, 'MATLAB:iteratorClass:funArgNotHandle');
end

% ErrorHandler is not supported - error if set
[errHandler, otherArgs] = iStripPVPair('ErrorHandler', [], varargin);
if ~isempty(errHandler)
    error(message('MATLAB:bigdata:array:FunFunErrorHandlerNotSupported', FUNFUNNAME));
end

% Extract and validate UniformOutput flag (must be scalar logical or double)
defaultUniformOutput = true;
[isUniform, otherArgs] = iStripPVPair('UniformOutput', defaultUniformOutput, otherArgs);
if ~isValidUniformOutputValue(isUniform)
    iThrowFunfunError(funfunName, 'MATLAB:iteratorClass:NotAParameterPair', ...
                      length(otherArgs) + 3, 'logical', 'UniformOutput');
end

for idx = 1:numel(otherArgs)
    if ~istall(otherArgs{idx})
        error(message('MATLAB:bigdata:array:AllArgsTall', FUNFUNNAME));
    end
    
    if ~isempty(validTypes)
        % otherArgs start at position 2.
        otherArgs{idx} = tall.validateType(otherArgs{idx}, funfunName, validTypes, 1 + idx);
    end
end

% Just in case the user function samples random numbers, fix the RNG state.
opts = matlab.bigdata.internal.PartitionedArrayOptions('RequiresRandState', true);

fcnWrapper = @(varargin) iCallFunFun(funfun, userfun, varargin{:}, 'UniformOutput', isUniform);
[varargout{1:nargout}] = elementfun(opts, fcnWrapper, otherArgs{:});

if ~isUniform
    [varargout{:}] = setKnownType(varargout{:}, 'cell');
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% isValidUniformOutputValue - check that the input is a valid value for the
% UniformOutput flag
function tf = isValidUniformOutputValue(arg)

% valid if scalar logical, or scalar double with value 0 or 1
tf = (islogical(arg) && isscalar(arg)) ...
    || (isa(arg,'double') && isscalar(arg) && ismember(arg, [0 1]));

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iCallFunFun - wrap call to funfun, ensuring that the output type is allowed
function varargout = iCallFunFun(funfun, userfun, varargin)
[varargout{1:nargout}] = funfun(userfun, varargin{:});
outTypes = cellfun(@class, varargout, 'UniformOutput', false);
allowedTypes = matlab.bigdata.internal.adaptors.getAllowedTypes();
if any(~ismember(outTypes, allowedTypes))
    % Got disallowed types
    forbiddenTypes = setdiff(outTypes, allowedTypes);
    iThrowFunfunError(func2str(funfun), ...
        'MATLAB:iteratorClass:UnimplementedOutputArrayType', ...
        forbiddenTypes{1});
end

% Forbid outputs that aren't: numeric, logical, char, or cell (the "classic"
% list of allowed uniform output types - strictly speaking, we only need to
% forbid "strong" types - but what if we change that list?)
isOkOutputFcn = @(x) isnumeric(x) || islogical(x) || ischar(x) || iscell(x);
outputOkFlag  = cellfun(isOkOutputFcn, varargout);
if any(~outputOkFlag)
    firstBadOutput = find(~outputOkFlag, 1, 'first');
    firstBadClass  = outTypes{firstBadOutput};
    error(message('MATLAB:bigdata:array:FunFunInvalidOutputType', ...
                  upper(func2str(funfun)), firstBadClass));
end

% Mark the outputs whose type is not known. This is to allow that type to
% be inferred by other chunks of the output.
for ii = 1 : nargout
    if size(varargout{ii}, 1) == 0 && isa(varargout{ii}, 'double')
        varargout{ii} = matlab.bigdata.internal.UnknownEmptyArray.build(size(varargout{ii}));
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Throw a cellfun/arrayfun error. iteratorClassID should be a message from the
% MATLAB:iteratorClass catalog.
function iThrowFunfunError(funfunName, iteratorClassID, varargin)
msgStr = getString(message(iteratorClassID, varargin{:}));
funfunID = strrep(iteratorClassID, 'iteratorClass', funfunName);
error(funfunID, '%s', msgStr);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [value, remainingArgs] = iStripPVPair(propName, defaultValue, args)

% Here, we happen to know that the property arguments to all funfuns are unique,
% so we only need to check to see if the putative property name starts with the
% correct sequence of characters.

if length(args) > 2 ...
    && isNonTallScalarString(args{end-1}) ...
    && iMatches(args{end-1}, propName)
    value = args{end};
    remainingArgs = args(1:end-2);
else
    value = defaultValue;
    remainingArgs = args;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TRUE if name (as char or string) matches propName
function tf = iMatches(name, propName)
if isstring(name)
    name = char(name);
end
tf = strncmpi(name, propName, numel(name));
end
