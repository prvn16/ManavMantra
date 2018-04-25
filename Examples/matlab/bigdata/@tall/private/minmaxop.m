function [out, varargout] = minmaxop(fcn, arg1, arg2, varargin) %#ok<STOUT>
%MINMAXOP Common helper for MIN and MAX.

% Copyright 2015-2017 The MathWorks, Inc.

narginchk(2, 5);

FCN_NAME = upper(func2str(fcn));

if nargout > 1
    % Currently don't support the index output for min/max.
    error(message('MATLAB:bigdata:array:MinMaxSingleOutput'));
end

tall.checkNotTall(FCN_NAME, 2, varargin{:});

ALLOWED_TYPES = {'numeric', 'logical', 'categorical', 'duration', 'datetime', 'char'};
% We can check 'arg1' right now - we can't check arg2 until we've worked out
% whether it is intended to be data or not.
arg1 = tall.validateType(arg1, FCN_NAME, ALLOWED_TYPES, 1);

% If we have a second argument, it might be: a tall data argument; a small data
% argument; [] to indicate we're in reduction mode (provided a dimension is
% specified); or (erroneously) a flag.
if nargin > 2
    
    isValidDimFcn = @(x) isscalar(x) && (isnumeric(x) || islogical(x));
    
    if nargin == 5 || (nargin == 4 && ~iIsScalarString(varargin{1}) )
        dim = varargin{1};
        flags = varargin(2:end);
        operation = 'ReduceInDim';
        if ~iIsSmallEmpty(arg2) % Must be []
            error(message(sprintf('MATLAB:%s:caseNotSupported', lower(FCN_NAME))));
        end
        if ~isValidDimFcn(dim)
            error(message('MATLAB:getdimarg:dimensionMustBePositiveInteger'));
        end
    elseif iIsSmallEmpty(arg2)
        % If the third input was a dimension it would be captured above, so
        % either it is a flag or we actually intended an elementwise
        % compare.
        if nargin > 3
            operation = 'ReduceInDefaultDim';
        else
            operation = 'Comparison';
        end
        flags = varargin;
    else
        % Treat as comparison
        operation = 'Comparison';
        flags = varargin;
    end
else
    % Must be reduction in default dimension. No flags permitted.
    operation = 'ReduceInDefaultDim';
    flags = {};
end

% Can we convert ReduceInDefaultDim to ReduceInDim by observing the size?
if strcmp(operation, 'ReduceInDefaultDim')
    deducedDim = matlab.bigdata.internal.util.deduceReductionDimension(arg1.Adaptor);
    if ~isempty(deducedDim)
        dim = deducedDim;
        operation = 'ReduceInDim';
    end
end

% Derive the output adaptor - need this to interpret reduction flags
switch operation
    case 'Comparison'
        % Take the opportunity to validate arg2 now that we know it is data.
        arg2       = tall.validateType(arg2, FCN_NAME, ALLOWED_TYPES, 2);
        outAdaptor = iDeriveComparisonAdaptor(arg1, arg2);
    case 'ReduceInDim'
        outAdaptor = iDeriveReduceInDimAdaptor(arg1, dim);
    case 'ReduceInDefaultDim'
        outAdaptor = iDeriveReduceInDefaultDimAdaptor(arg1);
end

[nanFlagCell, precisionFlagCell] = interpretReductionFlags(outAdaptor, FCN_NAME, flags);

% Note that by this point we know that in the reduction cases the first
% input is tall since the second must be a non-tall empty.
assert(ismember(operation, {'Comparison','ReduceInDim','ReduceInDefaultDim'}), ...
    'Unexpected reduction case.');
switch operation
    case 'Comparison'
        % Take care over time types with local char inputs since we need to
        % treat char vectors as a single element when comparing.
        if ismember(outAdaptor.Class, ["categorical", "duration", "datetime"])
            if ischar(arg1)
                arg1 = string(arg1);
            end
            if ischar(arg2)
                arg2 = string(arg2);
            end
        end
        
        % Perform the elementwise comparison (we know that one of arg1 or arg2
        % is tall since no other argument is allowed to be).
        out = elementfun(@(x,y) fcn(x, y, nanFlagCell{:}, precisionFlagCell{:}), arg1, arg2);
        % Preserve the size information produced by elementfun
        out.Adaptor = copySizeInformation(outAdaptor, out.Adaptor);
        
    case 'ReduceInDim'
        if dim == 1
            % Try to use metadata if present (which doesn't support precision)
            if isempty(precisionFlagCell)
                if isequal(fcn, @min)
                    fcnPiece = 'Min1';
                else
                    fcnPiece = 'Max1';
                end
                if isempty(nanFlagCell) || strcmpi('omitnan', nanFlagCell{1})
                    nanPiece = 'OmitNaN';
                else
                    nanPiece = 'IncludeNaN';
                end
                metadataName = [fcnPiece, nanPiece];
                metadata = hGetMetadata(hGetValueImpl(arg1));
                if ~isempty(metadata)
                    [gotValue, value] = getValue(metadata, metadataName);
                    if gotValue
                        out = tall.createGathered(value);
                        return
                    end
                end
            end
            out = reducefun(@(x) fcn(x, [], dim, nanFlagCell{:}, precisionFlagCell{:}), arg1);
        else
            out = slicefun(@(x) fcn(x, [], dim, nanFlagCell{:}, precisionFlagCell{:}), arg1);
        end
        % computeReducedSize will already have computed the correct size information, so
        % no need to respect the size information set up by SLICEFUN.
        out.Adaptor = outAdaptor;
        
    case 'ReduceInDefaultDim'
        outPA = reduceInDefaultDim(@(x, dim) fcn(x, [], dim, ...
            nanFlagCell{:}, precisionFlagCell{:}), arg1);
        out = tall(outPA, outAdaptor);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adaptor = iDeriveComparisonAdaptor(arg1, arg2)
% Calculate the output type for a comparison MIN/MAX.

% We must be careful to consider that arg1 and arg2 aren't necessarily both
% tall, and that char inputs are immediately cast to double.
adaptor1 = iConvertCharAdaptorsToDouble(matlab.bigdata.internal.adaptors.getAdaptor(arg1));
adaptor2 = iConvertCharAdaptorsToDouble(matlab.bigdata.internal.adaptors.getAdaptor(arg2));

if isequal(adaptor1.Class, adaptor2.Class) && ~isempty(adaptor1.Class)
    % Same - pick one, remembering that the size can be influenced by singleton
    % expansion.
    adaptor = resetSizeInformation(adaptor1);
elseif isempty(adaptor1.Class) && isempty(adaptor2.Class)
    % Both empty - default to generic.
    adaptor = matlab.bigdata.internal.adaptors.GenericAdaptor();
else
    % Got some information. In this case, we need to propagate
    % datetime/duration/calendarDuration. We preferentially pick the first
    % adaptor.
    timeClasses = {'datetime', 'duration', 'calendarDuration'};
    if ismember(adaptor1.Class, timeClasses)
        adaptor = resetSizeInformation(adaptor1);
    elseif ismember(adaptor2.Class, timeClasses)
        adaptor = resetSizeInformation(adaptor2);
    elseif strcmp(adaptor1.Class, 'categorical')
        % Handle categoricals: if either is categorical, copy that adaptor.
        adaptor = resetSizeInformation(adaptor1);
    elseif strcmp(adaptor2.Class, 'categorical')
        adaptor = resetSizeInformation(adaptor2);
    else
        % Don't know how to combine classes. This might result in a run-time error.
        adaptor = matlab.bigdata.internal.adaptors.GenericAdaptor();
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adaptor = iDeriveReduceInDefaultDimAdaptor(arg1)
tmp = iConvertCharAdaptorsToDouble(arg1.Adaptor);
% We might one day add size information here.
adaptor = resetSizeInformation(tmp);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function adaptor = iDeriveReduceInDimAdaptor(arg1, dim)
tmp = iConvertCharAdaptorsToDouble(arg1.Adaptor);
% Update the reduced dimension in the adaptor
allowEmpty = true;
adaptor = computeReducedSize(tmp, arg1.Adaptor, dim, allowEmpty);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% min/max on char data always returns double. All other types are preserved.
function newAdaptor = iConvertCharAdaptorsToDouble(oldAdaptor)
if strcmp(oldAdaptor.Class, 'char')
    newAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType('double');
    newAdaptor = copySizeInformation(newAdaptor, oldAdaptor);
else
    newAdaptor = oldAdaptor;
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsSmallEmpty(arg)
% Check for a non-tall empty array
tf = ~istall(arg) && isempty(arg);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsScalarString(arg)
tf = ischar(arg) || (isstring(arg) && isscalar(arg));
end
