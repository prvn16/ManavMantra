function meanX = mean(varargin)
%MEAN Average or mean value
%   S = MEAN(X)
%   S = MEAN(X,DIM)
%   S = MEAN(...,TYPE)
%   S = MEAN(...,MISSING)
%
%   Limitations:
%   Datetime inputs are not supported.
%
%   See also MEAN, TALL.

%   Copyright 2015-2017 The MathWorks, Inc.

narginchk(1,4);
tall.checkNotTall(upper(mfilename), 1, varargin{2:end});
[args, flags] = splitArgsAndFlags(varargin{:});

% We cannot support datetime/mean since we don't have the building blocks, but
% we allow it through the validateType so that we can throw a more specific
% error.
[args{:}] = tall.validateType(args{:}, mfilename, ...
                              {'numeric', 'logical', 'duration', 'datetime', 'char'}, ...
                              1:numel(args));
assert(istall(args{1})); % we have checked that args 2:end are not tall.
x = args{1};
adaptor = args{1}.Adaptor;

if strcmp(adaptor.Class, 'datetime')
    error(message('MATLAB:bigdata:array:FcnNotSupportedForType', ...
                  upper(mfilename), 'datetime'));
end

try
    [nanFlagCell, precisionFlagCell] = adaptor.interpretReductionFlags(upper(mfilename), flags);
catch E
    throw(E);
end

assert(~isempty(nanFlagCell)); % We need the nan flag at the client to switch implementations.
nanFlag = nanFlagCell{1};

% If no dimension specified, try to deduce it (will be empty if we can't).
if numel(args) == 1
    dim = matlab.bigdata.internal.util.deduceReductionDimension(adaptor);
else
    dim = args{2};
end

if isempty(dim)
    % Default dimension

    % Compute adaptors for results from reduceInDefaultDim
    sumXAdaptor = matlab.bigdata.internal.adaptors.getAdaptorForType(...
        computeSumResultType(x.Adaptor.Class, precisionFlagCell));
    szInRedDimAdaptor = matlab.bigdata.internal.adaptors.getScalarDoubleAdaptor();

    if isequal(nanFlag, 'includenan')
        % Mean including all elements
        [result, resolvedDimension] = ...
            reduceInDefaultDim(@(x, dim) sum(x, dim, 'includenan', precisionFlagCell{:}), x);
        result = tall(result, sumXAdaptor);
        % Note: we don't care about the type of resolvedDimension ...
        resolvedDimension = tall(resolvedDimension);
        szTv = size(x);
        
        % ... but we do care about the type of sizeInReductionDimension as we need it
        % for the type of 'result' to propagate through the RDIVIDE call.
        sizeInReductionDimension = clientfun(@iGetSizeinDim, szTv, resolvedDimension);
        sizeInReductionDimension.Adaptor = szInRedDimAdaptor;
        meanX = result ./ sizeInReductionDimension;
    else
        % Mean excluding NaNs
        result = reduceInDefaultDim(@(x, dim) sum(x, dim, 'omitnan', precisionFlagCell{:}), x);
        result = tall(result, sumXAdaptor);
        meanX = result ./ sum(~isnan(x));
    end
else
    % Specified dimension - note that here we rely on SUM and RDIVIDE to propagate
    % adaptors correctly where necessary to deal with duration.
    if isequal(nanFlag, 'includenan')
        % Mean including all elements
        meanX = sum(x, dim, 'includenan', precisionFlagCell{:}) ./ size(x, dim);
    else
        % Mean excluding NaNs
        meanX = sum(x, dim, 'omitnan', precisionFlagCell{:}) ./ sum(~isnan(x), dim);
    end
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sz = iGetSizeinDim(szVec, dim)
% Another special case as per g1364892. mean([]) returns NaN, which does not
% match any return that you get by specifying a dimension. Here we're working
% around yet another special case which is that sum([]) needs to return 0, and
% it does that by pretending that the reduction dimension is 3.
if isequal(szVec, [0 0])
    sz = 0;
else
    sz = szVec(dim);
end
end
