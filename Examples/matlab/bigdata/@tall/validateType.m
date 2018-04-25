function varargout = validateType(varargin)
%validateType Possibly deferred argument type validation
%   [TX1,TX2,...] = validateType(TX1,TX2,...,METHOD,VALIDTYPES,ARGIDXS)
%   validates that each of TX1, TX2, ... is one of the types VALIDTYPES. ARGIDXS
%   describes the positions of TX1,TX2 in the original call to METHOD - i.e. a
%   numeric vector. If possible, the validation is done immediately; otherwise,
%   the validation is done lazily.
%
%   Note that if the required type is a type that must be known at the client
%   (aka a "strong" type) the validation is always performed immediately.

% Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

dataArgs   = varargin(1:end-3);
methodName = varargin{end-2};
types      = varargin{end-1};
argIdxs    = varargin{end};
assert(numel(argIdxs) == numel(dataArgs) && ...
       ischar(methodName) && isrow(methodName) && ...
       iscellstr(types) && isnumeric(argIdxs), ...
       'Invalid inputs to validateType.');

% Forbidden types start with "~"
isForbiddenType = strncmp('~', types, 1);
forbiddenTypes = types(isForbiddenType);
forbiddenTypes = strrep(forbiddenTypes, '~', '');
allowedTypes = types(~isForbiddenType);

msgArgsFcn = @(idx) {'MATLAB:bigdata:array:InvalidArgumentType', idx, ...
                    upper(methodName), strjoin(allowedTypes, ' ')};
forbiddenMsgArgsFcn = @(idx) {'MATLAB:bigdata:array:UnsupportedArgumentType', idx, ...
                    upper(methodName), strjoin(forbiddenTypes, ' ')};

% It's a mistake not to capture all the outputs since they might be modified.
nData = numel(dataArgs);
nargoutchk(nData, nData);
varargout = cell(1, nData);

for idx = 1:nData
    try
        varargout{idx} = iValidateArg(dataArgs{idx}, allowedTypes, forbiddenTypes, ...
                                      msgArgsFcn(argIdxs(idx)), forbiddenMsgArgsFcn(argIdxs(idx)));
    catch err
        throwAsCaller(err);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function arg = iValidateArg(arg, allowedTypes, forbiddenTypes, msgArgs, forbiddenMsgArgs)

adaptor = matlab.bigdata.internal.adaptors.getAdaptor(arg);
argClass = adaptor.Class;
classIsKnown = ~isempty(argClass);
strongTypes = matlab.bigdata.internal.adaptors.getStrongTypes();

% First we can check if the type is known that it isn't a forbidden
% type. Forbidden types must all be known at the client.
assert(all(ismember(forbiddenTypes, strongTypes)));
if classIsKnown && ismember(argClass, forbiddenTypes)
    error(message(forbiddenMsgArgs{:}));
end

if isempty(allowedTypes)
    % any type is permitted
    return
end

% If all of the allowed types are those that must be known up front, then we can
% perform the check fully at the client.
classMustBeKnown = all(ismember(allowedTypes, strongTypes));

if (classMustBeKnown || classIsKnown) ...
        && ~matlab.bigdata.internal.util.isSupportedClass(argClass, allowedTypes)
    error(message(msgArgs{:}));
else
    % Class need not be known up front, must perform a lazy validation.
    if istall(arg) && ( ~classIsKnown || strcmp(argClass, 'cell') )
        arg = lazyValidate(arg, {@(x) iIsCorrectType(x, allowedTypes), ...
                            msgArgs{:}}); %#ok<CCAT> must use braces to concatenate function_handle
    else
        assert(classIsKnown, 'Class should be known for non-tall argument.');
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ok = iIsCorrectType(x, validTypes)
actualClass = class(x);
ok = ismember(actualClass, validTypes) || ...
     (ismember('numeric', validTypes) && isnumeric(x)) || ...
     (ismember('cellstr', validTypes) && iscellstr(x)) || ...
     (ismember('integer', validTypes) && isinteger(x)) || ...
     (ismember('float', validTypes)   && isfloat(x));
end
