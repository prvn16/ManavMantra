function out = median(tX,varargin)
%MEDIAN Median value.
%   M = MEDIAN(A)
%   M = MEDIAN(A,DIM)
%   M = MEDIAN(...,NANFLAG)
%
%   Limitations:
%   1) Computations of median along the first dimension
%      is only supported for column vector A.
%
%   See also MEDIAN

%   Copyright 2016-2017 The MathWorks, Inc.

tall.checkNotTall(upper(mfilename), 1, varargin{:});
tall.checkIsTall(upper(mfilename), 1, tX);
[args, flags] = splitArgsAndFlags(varargin{:});

tX = tall.validateType(tX, mfilename, ...
    {'numeric', 'duration', 'datetime','categorical'}, 1);
adaptor = tX.Adaptor;
classIn = adaptor.Class;
dim = iParseParameters(adaptor, args, varargin{:});

nanFlagCell = adaptor.interpretReductionFlags(upper(mfilename), flags);
assert(~isempty(nanFlagCell)); % We need the nan flag at the client to switch implementations.
nanFlag = nanFlagCell{1};

% Check if it's a simple slice-wise call
if dim ~= 1
    medianFunctionHandle = @(x) median(x, varargin{:});
    out = slicefun(medianFunctionHandle, tX);
    out.Adaptor = tX.Adaptor;
    out.Adaptor = computeReducedSize(out.Adaptor, tX.Adaptor, dim, false);
    return;
end

% If we get here, we need to reduce the tall dimension
tX = tall.validateColumn(tX, 'MATLAB:bigdata:array:MedianMustBeColumn');

if any(strcmp(nanFlag,'omitnan'))
    tX = filterslices(~ismissing(tX),tX);
end

switch classIn
    case 'categorical'
        half = length(tX)/2;
        medianXtmp = iMiddleCategorical(tX, half);
        medianX = clientfun(@iCategoricalMean, medianXtmp);
        % TODO(g1548470): Condition and else branch to be removed when tall/histcounts will be
        % extended for datetime objects (meanwhile we just sort everything)
    case {'datetime','duration'}
        half = length(tX)/2;
        tX = sort(tX,1);
        % form a vector of 1:size(tX,1)
        absoluteIndices = tall(matlab.bigdata.internal.lazyeval.getAbsoluteSliceIndices(hGetValueImpl(tX)));
        medianXtmp = filterslices(absoluteIndices == floor(half+1) | ...
            absoluteIndices == round(half), tX);
        medianX = clientfun(@iMeanOfDateOrDuration, medianXtmp, classIn);
    otherwise
        medianXtmp = percentileDataBin(tX, 50);
        medianX = clientfun(@mean, medianXtmp, 1, 'native');
end

medianX.Adaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(classIn);
% Return missing if there is any
out = ternaryfun(any(ismissing(tX)), head(filterslices(ismissing(tX),tX),1), medianX);
out.Adaptor = tX.Adaptor;
out.Adaptor = computeReducedSize(out.Adaptor, tX.Adaptor, dim, false);
end

function dim = iParseParameters(adaptor, args, varargin)
% Check that the input parameters are valid and supported
try
    % This works as a parameter check for different datatypes
    if strcmp(adaptor.Class,'datetime')
        median(datetime, varargin{:});
    else
        median(1, varargin{:});
    end
    
    % If no dimension specified, try to deduce it (will be empty if we can't).
    if numel(args) == 0
        dim = matlab.bigdata.internal.util.deduceReductionDimension(adaptor);
    else
        dim = args{1};
    end
    
    if isempty(dim)
        error(message('MATLAB:bigdata:array:MedianDimRequired'));
    end
    
catch err
    throwAsCaller(err);
end
end

function medianXtmp = iMiddleCategorical(tX, half)
% Compute middle elements for categorical array
n = countcats(tX,1); % countcats instead as this gives me the same
n = cumsum(n,1);
cats = categories(tX);
valueset = tall(matlab.bigdata.internal.lazyeval.getAbsoluteSliceIndices(hGetValueImpl(cats)));
cat1 = nnz(n < round(half)) + 1;                   % lower middle category index
cat1 = categorical(cat1, valueset, cats, 'Ordinal', true); % lower middle category
cat2 = nnz(n < floor(half+1)) + 1;                 % upper middle category index
cat2 = categorical(cat2, valueset, cats, 'Ordinal', true); % upper middle category
% Until tall/vertcat is not in place we just use clientfun
medianXtmp = clientfun(@vertcat, cat1, cat2);
medianXtmp.Adaptor = tX.Adaptor;
end

function yMean = iMeanOfDateOrDuration(x, classIn)
% Compute the mean for different datatypes
% TODO(g1526055): To be removed when tall/MEAN supports DATETIME (g1514449)
% together with the correspondent helper
if strcmp(classIn,'datetime')
    yMean = iDatetimeMean(x);
else
    yMean = mean(x,'native');
end
end

function yDatetimeMean = iDatetimeMean(xDatetime)
% Compute the mean of tall/datetime through tall/duration
if isempty(xDatetime)
    d0 = NaT;
else
    d0 = xDatetime(1);
end
yDatetimeMean = mean(xDatetime - d0) +  d0;
end

function yCategoricalMean = iCategoricalMean(xCategorical)
% Compute the "mean" of two-elements categorical
if isempty(xCategorical) || isempty(categories(xCategorical)) || any(ismissing(xCategorical))
    % TODO(g1548484) use cast like
    xCategorical(1) = missing;
    yCategoricalMean = xCategorical(1);
else
    midCategoryIndx = round(mean(double(xCategorical)));
    cats = categories(xCategorical);
    yCategoricalMean = categorical(midCategoryIndx, 1:numel(cats), cats, 'Ordinal', true);
end
end
