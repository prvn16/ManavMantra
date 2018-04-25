function varargout = wrapUnderlyingMethod(underlyingMethod, opts, fcns, varargin)
%WRAPUNDERLYINGMETHOD Wrap a method of the ValueImpl of a tall
%   varargout = wrapUnderlyingMethod(METHOD, OPTS, FCNS, varargin) extracts
%   the PartitionedArray from each tall input in varargin and passes
%   through non-tall inputs unmodified. It then calls the corresponding
%   underlying method METHOD of PartitionedArray. OPTS is a
%   PartitionedArrayOptions object or is empty. FCNS is a cell array of
%   function handles which are leading arguments to METHOD.

%   Copyright 2015-2017 The MathWorks, Inc.

% Not all primitives require opts. If not specified, shuffle the inputs
% down.

% This prevents this frame and anything below it being added to the gather
% error stack.
frameMarker = matlab.bigdata.internal.InternalStackFrame; %#ok<NASGU>

try
    if ~isa(opts, 'matlab.bigdata.internal.PartitionedArrayOptions')
        varargin = [{fcns}, varargin];
        fcns = opts;
        opts = [];
    end
    
    % Dispatch will recurse if any element of fcns is a tall array
    assert(iscell(fcns), "FCNS must be a cell array.")
    assert( ~any(cellfun(@istall, fcns)), "FCNS must not contain any tall arrays.")
    
    inputs = unpackValueImpls(varargin);

    if isempty(opts)
        % Run with no options struct
        [outputs{1:max(1, nargout)}] = underlyingMethod(fcns{:}, inputs{:});
    else
        % Run with given options struct
        [outputs{1:max(1, nargout)}] = underlyingMethod(opts, fcns{:}, inputs{:});
    end
catch err
    matlab.bigdata.internal.util.assertNotInternal(err);
    rethrow(err);
end

varargout = cellfun(@tall, outputs, 'UniformOutput', false);
end
