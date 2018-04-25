function varX = var(varargin)
%VAR Variance
%   Y = VAR(X)
%   Y = VAR(X,FLAG) where FLAG is 0 or 1
%   Y = VAR(X,FLAG,DIM)
%   Y = VAR(...,MISSING)
%
%   Limitations:
%   1) Weight vector is not supported.
%
%   See also: VAR, TALL.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1, 4);
tall.checkNotTall(upper(mfilename), 1, varargin{2:end});
[args, flags] = splitArgsAndFlags(varargin{:});
if numel(args) == 1
    % No flag provided, let's provide one
    args{2} = 0;
end

dimCell = cell(1, numel(args) - 2);
[x, normFlag, dimCell{:}] = deal(args{:});
% First argument must be numeric or logical for VAR
x = tall.validateType(x, mfilename, {'numeric', 'logical'}, 1);

if ~(isnumeric(normFlag) && ~isobject(normFlag) && isscalar(normFlag))
    error(message('MATLAB:bigdata:array:WeightVectorNotSupported', upper(mfilename)));
end

if normFlag ~= 0 && normFlag ~= 1
    error(message('MATLAB:bigdata:array:VarFlagZeroOrOne'));
end

adaptor = x.Adaptor;
missingFlagCell = adaptor.interpretReductionFlags(upper(mfilename), flags);
assert(~isempty(missingFlagCell));
missing = missingFlagCell{1};


% If no dimension specified, try to deduce it (will stay empty if we can't).
if isempty(dimCell)
    dim = matlab.bigdata.internal.util.deduceReductionDimension(adaptor);
else
    dim = dimCell{1};
end

useDefaultDim = isempty(dim);

if useDefaultDim || isequal(dim, 1)
    % Reduction
    if useDefaultDim
        aggregateFcn = @(chunk, myDim) chunkVar(chunk, normFlag, myDim, missing);
        reduceFcn = @(chunk, myDim) updateVar(chunk, myDim, missing);
        tmpCellPA = reduceInDefaultDim({aggregateFcn, reduceFcn}, x);
        tmpCell = tall(tmpCellPA);
    else
        % DIM is 1
        aggregateFcn = @(chunk) chunkVar(chunk, normFlag, 1, missing);
        reduceFcn = @(chunk) updateVar(chunk, 1, missing);
        tmpCell = aggregatefun(aggregateFcn, reduceFcn, x);
    end

    % output is in the first element of the cell array.
    varX = clientfun(@normalizeOutput, tmpCell, normFlag, size(x), useDefaultDim);
    if ~useDefaultDim
        % set the output size
        varX.Adaptor = computeReducedSize(varX.Adaptor, x.Adaptor, dim, false);
    end
else
    varX = slicefun(@(x) var(x, normFlag, dim, missing), x);
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outCell = chunkVar(data, flag, dim, missing)
locIsEmpty = isempty(data);

if dim == 1
    locVar = var(data, 1, dim, missing);
    locMean = mean(data, dim, missing);
    
    if locIsEmpty
        % Ensure that a possibly empty chunk does not corrupt the reduction
        % with NaN by setting to zero while preserving the size.
        locVar(:) = 0;
        locMean(:) = 0;
    end
    
    % locVar is scaled by locCount
    if strcmpi(missing, 'includenan')
        locCount = size(data, dim);
    else
        locCount = sum(~isnan(data), dim);
    end
else
    % Conforming size for vertcat
    locVar = var(data, flag, dim, missing);
    locMean = ones(size(data,1),1);    %size(data,1) should be 1 or 0.
    locCount = ones(size(data,1),1);
end
outCell = {locVar, locMean, locCount, locIsEmpty};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function outCell = updateVar(inCell, dim, missing)
if size(inCell,1) == 1
    outCell = inCell;
else
    assert(dim == 1);
    vVar = cat(1, inCell{:,1});
    vMean = cat(1, inCell{:,2});
    vCount = cat(1, inCell{:,3});
    vIsEmpty = cat(1, inCell{:,4});
    if size(vVar, dim) == 1 || size(vVar, dim) == 0  % return itself
        locVar = vVar;
        locMean = vMean;
        locCount = vCount;
        locIsEmpty = vIsEmpty;
    else
        locCount = sum(vCount,dim);
        if strcmpi(missing,'omitnan')
            vMean(vCount == 0) = 0;
            vVar(vCount == 0) = 0;
        end
        locMean = sum(vCount .* vMean, dim) ./ locCount;
        locVar = sum(vCount .* vVar, dim) ./ locCount;
        % When one input is empty, avoid applying the variance adjustment
        % altogether. This is to avoid Inf * 0 calculations when the mean
        % of the other input is greater than sqrt(realmax).
        countProd = prod(vCount ./ locCount, dim) .* ones(size(locVar));
        locVarAdjust = diff(vMean, 1, dim) .^ 2 .* countProd;
        locVar(countProd ~= 0) = locVar(countProd ~= 0) + locVarAdjust(countProd ~= 0);
        locIsEmpty = all(vIsEmpty);
        
        if locIsEmpty
            % If we're combining empty chunks, then locMean and locVar will have become NaN,
            % we need to revert to 0.
            locVar(:) = 0;
            locMean(:) = 0;
        end
    end
    outCell = {locVar, locMean, locCount, locIsEmpty};
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function varX = normalizeOutput(inCell, normFlag, sizeX, dimUnspecified)
varX = inCell{1};
n = inCell{3};
allEmpty = inCell{4};
type = class(varX);

if isequal(sizeX, [0 0]) && dimUnspecified
    % Special case for 0x0 empty input
    % Must expand the output to 1x1 NaN when user did not provide a dim arg
    varX = nan(type);
    return;
end

if allEmpty
    % All chunks were empty so we fill the output with nans of correct type
    % and return early since normFlag does not apply.
    varX(:) = nan(type);
    return;
end

% Bias correct the result
if normFlag == 0
    nm1 = max(n - 1, 1);
    % Bias-correct the result
    varX = varX .* (n./nm1);
end
end
