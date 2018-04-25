function varargout = lazyValidate(varargin)
%lazyValidate Deferred argument validation using predicate.
%   [TX1,TX2,...] = lazyValidate(TX1,TX2,...,{PREDICATE,ARGS...}) checks that
%   PREDICATE(X1,X2) returns TRUE, otherwise error(message(ARGS...)) is thrown.

% Copyright 2016-2017 The MathWorks, Inc.

% This prevents this frame and anything below it being added to the gather
% error stack.
internalFrame = matlab.bigdata.internal.InternalStackFrame(); %#ok<NASGU>

dataArgs = varargin(1:end-1);

% It's a mistake not to capture all the outputs
nargoutchk(numel(dataArgs), numel(dataArgs));

predicateAndArgs = varargin{end};

% Ensure that lazyValidate does not appear in the error stack.
fh = @(varargin) iLazyValidate(varargin, predicateAndArgs{:});
fh = matlab.bigdata.internal.FunctionHandle(fh, 'NumIgnoredStackFrames', 1);

[varargout{1:nargout}] = elementfun(fh, dataArgs{:});
% Since we know the elementfun didn't change anything about the values, we can
% simply copy the adaptors across for tall inputs
isInputTall = cellfun(@istall, dataArgs);
varargout(isInputTall) = cellfun(@iCopyAdaptor, varargout(isInputTall), dataArgs(isInputTall), ...
                                 'UniformOutput', false);

% Non-tall inputs we should hand back unmodified.
varargout(~isInputTall) = dataArgs(~isInputTall);

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = iCopyAdaptor(x, arg)
x.Adaptor = arg.Adaptor;
% Since the operation never modifies any values, we can safely copy all
% metadata.
hSetMetadata(x.ValueImpl, hGetMetadata(arg.ValueImpl));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varargout = iLazyValidate(xCell, pred, varargin)
if ~pred(xCell{:})
    error(message(varargin{:}));
end
varargout = xCell;
end
