function [bins, edges] = discretize(x, binspec, varargin)
% discretize  Group duration into bins or categories.
%    BINS = discretize(X,EDGES) returns the indices of the bins that the 
%    elements of X fall into. X is a duration array and EDGES is a duration 
%    vector that contains bin edges in monotonically increasing order. An 
%    element X(i) falls into the j-th bin if EDGES(j) <= X(i) < EDGES(j+1), 
%    for 1 <= j < N where N is the number of bins and length(EDGES) = N+1. 
%    The last bin includes the right edge such that it contains 
%    EDGES(N) <= X(i) <= EDGES(N+1). For out-of-range values where 
%    X(i) < EDGES(1) or X(i) > EDGES(N+1) or isnan(X(i)), BINS(i) returns NaN.
%     
%    [BINS, EDGES] = discretize(X,N) where N is a scalar integer, divides the
%    duration range of X into N uniform bins, and also returns the bin edges.
%
%    [BINS, EDGES] = discretize(X,DUR) divides X into uniform bins of DUR 
%    length of time. DUR can be a scalar duration, or one of the following 
%    character vectors: 'second', 'minute', 'hour', 'day', 'year'. To 
%    prevent from accidentally creating too many bins, a maximum of 65536 bins
%    can be created when specifying DUR. If DUR is too small such that 
%    more bins are needed, discretize uses a larger bin width corresponding 
%    to the maximum number of bins.
%
%    [BINS, EDGES] = discretize(...,VALUES) returns the corresponding element in 
%    VALUES, rather than the bin number. For example, if X(1) falls into 
%    bin 5 then BINS(1) would be VALUES(5) rather than 5. VALUES must be 
%    a vector with length equal to the number of bins. Out-of-range inputs 
%    return NaN.
%     
%    [C, EDGES] = discretize(...,'categorical') creates a categorical array from 
%    the binned result of X. C has the same number of categories 
%    as the number of bins. The category names will be in the form of 
%    "[A,B)", or "[A,B]" for the last bin, where A and B are consecutive 
%    values from EDGES. Out-of-range values will be undefined in C.
%  
%    [C, EDGES] = discretize(...,'categorical',FMT) uses the specified 
%    duration display format in the category names. FMT is a character 
%    vector constructed using the characters a-z to represent components of 
%    the durations. See the description of the Format property of duration 
%    for details.
%    
%    [C, EDGES] = discretize(...,'categorical',CATEGORYNAMES) additionally 
%    specifies names for the categories in C using CATEGORYNAMES.  
%    CATEGORYNAMES is a cell array of character vectors and has length 
%    equal to the number of bins.  
% 
%    [...] = discretize(...,'IncludedEdge',SIDE) specifies which bin edge 
%    is included in the bins. SIDE can be:
%        'left'    Each bin includes the left bin edge, except for the last bin
%                  which includes both bin edges. This is the default.
%        'right'   Each bin includes the right bin edge, except for the first 
%                  bin which includes both bin edges.
%    If SIDE is 'right', an element X(i) falls into the j-th bin if
%    EDGES(j) < X(i) <= EDGES(j+1), for 1 < j <= N where N is the number
%    of bins. The first bin includes the left edge such that it contains 
%    EDGES(1) <= X(i) <= EDGES(2).
% 
%    Example:
%       x = hours(randi(24,10,1));
%       bins = discretize(x,'hour');  % group into 24 bins, one for each hour
%
%    See also DURATION, DATETIME/DISCRETIZE, CATEGORICAL

%   Copyright 2016-2017 The MathWorks, Inc.

nin = nargin;
funcname = mfilename();

if ~isa(x, 'duration')
    error(message('MATLAB:duration:discretize:XNotDuration'));
end

fmt = '';
if isa(binspec, 'duration') && ~isscalar(binspec)
    edges = binspec;
    [xdata,edgesdata] = duration.compareUtil(x,edges);
    if ~isvector(edgesdata) || length(edgesdata) < 2
        error(message('MATLAB:duration:discretize:InvalidEdges'));
    elseif ~issorted(edgesdata) || any(isnan(edgesdata))
        error(message('MATLAB:duration:discretize:UnsortedEdges'));
    end
else
    % to determine the edges, we only use the finite data
    xfinite = x;
    xfinite.millis = x.millis(isfinite(x));
    xmin = min(xfinite);
    xmax = max(xfinite);
    if isempty(xfinite) % check for empty data
        xmin = seconds(0);  % just use 0 as reference
        xmax = xmin;
    end
    maxnbins = 65536;  %2^16
    if isnumeric(binspec)
        validateattributes(binspec, {'numeric'}, {'scalar', 'integer', 'positive'},...
            funcname, 'N', 2);
        edges = generateBinEdgesFromNumBins(binspec,xmin,xmax,false);
    elseif isa(binspec, 'duration')
        if ~(isscalar(binspec) && isfinite(binspec) && binspec > 0)
            error(message('MATLAB:duration:discretize:InvalidDur'));
        end
        edges = generateBinEdgesFromDuration(binspec,xmin,xmax,false,maxnbins);
    elseif ischar(binspec) && isrow(binspec)
        binspec = validatestring(binspec, {'year', 'day', 'hour', ...
            'minute', 'second'}, funcname, 'DUR', 2);
        edges = generateBinEdgesFromBinMethod(binspec,xmin,xmax,false,maxnbins);
    else
        error(message('MATLAB:duration:discretize:InvalidSecondInput'));
    end
    xdata = x.millis;
    edgesdata = edges.millis;
end

nbins = length(edgesdata)-1;
    
persistent p p2;
    
if nin > 2 && isrow(varargin{1}) && ~iscell(varargin{1}) && ~isstring(varargin{1})...
        && strncmpi(varargin{1},'categorical',max(length(varargin{1}),1))
    % create categorical output
    if nin > 3
        if isempty(p)
            p = inputParser;
            addOptional(p, 'categorynames', NaN, @(x) (iscellstr(x) && ...
                isvector(x)) || (ischar(x) && isrow(x) && ~isempty(x) && ...
                ~strncmpi(x,'I',1)))   % the check on the first letter is needed
                                      % to differentiate from Name Value
                                      % pair IncludedEdge
            addParameter(p, 'IncludedEdge', 'left', ...
                @(x) validateattributes(x,{'char'},{}))
        end
        parse(p,varargin{2:end})
        catnames = p.Results.categorynames;
        catnames_provided = iscell(catnames);
        if catnames_provided
            if length(catnames) ~= nbins
                error(message('MATLAB:duration:discretize:CategoryNamesInvalidSize',nbins));
            end
        elseif ischar(catnames)   % fmt provided
            fmt = catnames;
        end
        
        right = strcmp(validatestring(...
            p.Results.IncludedEdge,{'left','right'}),'right');
    else
        catnames_provided = false;
        right = false;
    end
    
    if ~catnames_provided
        catnames = gencatnames(edges,right,fmt);
    end
    
    bins = durationDiscretize(xdata, edgesdata, right);
    
    bins = categorical(bins, 1:nbins, catnames, 'Ordinal', true);
else
    % create numerical output
    if nin > 2
        if isempty(p2)
            p2 = inputParser;
            addOptional(p2, 'values', [], @(x) isvector(x) && ~isempty(x) ...
                && ~ischar(x) && ~isa(x,'function_handle'))
            addParameter(p2, 'IncludedEdge', 'left', ...
                @(x) validateattributes(x,{'char'},{}))
        end
        parse(p2,varargin{:})
        values = p2.Results.values;
        values_provided = ~isempty(values);
        if values_provided && length(values) ~= nbins
            error(message('MATLAB:duration:discretize:ValuesInvalidSize',nbins));
        end
        right = strcmp(validatestring(...
            p2.Results.IncludedEdge,{'left','right'}),'right');
    else
        values_provided = false;
        right = false;
    end
    
    bins = durationDiscretize(xdata, edgesdata, right);
    if values_provided
        nanbins = isnan(bins);
        if isa(values, 'duration')
            binindices = bins;
            if any(nanbins(:))
                values.millis(end+1) = NaN;
                binindices(nanbins) = length(values);
            end
            bins = values;  % bins needs to be duration
            % reshape needed when x and values are vectors of different orientation
            bins.millis = reshape(values.millis(binindices),size(x));        
        else 
            if any(nanbins(:))
                try
                    values(end+1) = NaN;
                catch
                    error(message('MATLAB:duration:discretize:ValuesClassNoNaN',class(values)));
                end
                bins(isnan(bins)) = length(values);
            end
            % reshape needed when x and values are vectors of different orientation
            bins = reshape(values(bins),size(x));
        end
        
    end
    
end

end

function names = gencatnames(edges,includeright,fmt)

if includeright
    leftedge = '(';
    rightedge = ']';
else
    leftedge = '[';
    rightedge = ')';    
end

nbins = length(edges)-1;
names = cell(1,nbins);

charedges = cellstr(edges,fmt);
for i = 1:nbins
    names{i} = sprintf('%s%s, %s%s',leftedge,charedges{i},charedges{i+1},rightedge);
end

if includeright
    names{1}(1) = '[';
else
    names{end}(end) = ']';
end

if length(unique(names)) < length(names)
    error(message('MATLAB:duration:discretize:DefaultCategoryNamesNotUnique'));
end

end



