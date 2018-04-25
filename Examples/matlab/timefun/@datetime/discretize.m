function [bins, edges] = discretize(x, binspec, varargin)
% discretize  Group datetimes into bins or categories.
%    BINS = discretize(X,EDGES) returns the indices of the bins that the 
%    elements of X fall into. X is a datetime array and EDGES is a datetime 
%    vector that contains bin edges in monotonically increasing order. An 
%    element X(i) falls into the j-th bin if EDGES(j) <= X(i) < EDGES(j+1), 
%    for 1 <= j < N where N is the number of bins and length(EDGES) = N+1. 
%    The last bin includes the right edge such that it contains 
%    EDGES(N) <= X(i) <= EDGES(N+1). For out-of-range values where 
%    X(i) < EDGES(1) or X(i) > EDGES(N+1) or isnat(X(i)), BINS(i) returns NaN.
%     
%    [BINS, EDGES] = discretize(X,N) where N is a scalar integer, divides the date
%    and time range of X into N uniform bins, and also returns the bin edges.
%
%    [BINS, EDGES] = discretize(X,DUR) divides X into uniform bins of DUR 
%    length of time. DUR can be a scalar duration or calendarDuration, or 
%    one of the following character vectors: 'second', 'minute', 'hour', 
%    'day', 'week', 'month', 'quarter', 'year', 'decade', 'century'. To 
%    prevent from accidentally creating too many bins, a maximum of 65536 bins
%    can be created when specifying DUR. If DUR is too small such that 
%    more bins are needed, discretize uses a larger bin width corresponding 
%    to the maximum number of bins.
%
%    [BINS, EDGES] = discretize(...,VALUES) returns the corresponding element in 
%    VALUES, rather than the bin number. For example, if X(1) falls into 
%    bin 5 then BINS(1) would be VALUES(5) rather than 5. VALUES must be 
%    a vector with length equal to the number of bins. Out-of-range inputs 
%    return NaN (if VALUES is numeric) or NaT (if VALUES is datetimes).
%     
%    [C, EDGES] = discretize(...,'categorical') creates a categorical array from 
%    the binned result of X. C has the same number of categories as the 
%    number of bins. 
%
%    [C, EDGES] = discretize(...,'categorical',FMT) uses the specified 
%    datetime format in the category names. FMT is a character vector constructed 
%    using the characters A-Z and a-z to represent date and time components 
%    of the datetimes. See the description of the Format property for details.
%    
%    [C, EDGES] = discretize(...,'categorical',CATEGORYNAMES) additionally 
%    specifies names for the categories in C using CATEGORYNAMES. 
%    CATEGORYNAMES is a cell array of character vectors and has length equal 
%    to the number of bins.  
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
%       x = datetime(2015, 1, randi(365,100,1));
%       bins = discretize(x,'month');  % group into 12 bins, one for each month
%
%    See also DATETIME, DATESHIFT, CATEGORICAL

%   Copyright 2016-2017 The MathWorks, Inc.

nin = nargin;
funcname = mfilename();

if ~isa(x, 'datetime')
    error(message('MATLAB:datetime:discretize:XNotDateTime'));
end

% parameter for displaying default category names
twoedgesformat = true;
if isa(binspec, 'datetime')
    edges = binspec;
    [xdata,edgesdata] = datetime.compareUtil(x,edges);
    if ~(isvector(edgesdata) && length(edgesdata) >= 2)       
        error(message('MATLAB:datetime:discretize:InvalidEdges'));
    elseif ~issorted([real(edgesdata(:)) imag(edgesdata(:))],'rows') || ...
            any(isnan(edgesdata))
        error(message('MATLAB:datetime:discretize:UnsortedEdges'));
    end
    fmt = edges.fmt;
else
    % to determine the edges, we only use the finite data
    xfinite = x;
    xfinite.data = x.data(isfinite(x));
    xmin = min(xfinite);
    xmax = max(xfinite);
    if isempty(xfinite) % check for empty data
        xmin = datetime('now', 'TimeZone', x.tz);  % use the current time
        xmax = xmin;
    end
    fmt = '';
    maxnbins = 65536;  %2^16, limit for using bin width and bin methods
    if isnumeric(binspec)
        validateattributes(binspec, {'numeric'}, {'scalar', 'integer', 'positive'},...
            funcname, 'N', 2);
        edges = generateBinEdgesFromNumBins(binspec,xmin,xmax,false);
    elseif isa(binspec, 'duration')
        if ~(isscalar(binspec) && isfinite(binspec) && binspec > 0)
            error(message('MATLAB:datetime:discretize:InvalidDur'));
        end
        edges = generateBinEdgesFromDuration(binspec,xmin,xmax,false,maxnbins);
    elseif isa(binspec, 'calendarDuration')
        if ~(isscalar(binspec) && isfinite(binspec))
            error(message('MATLAB:datetime:discretize:InvalidDur'));
        end
        [caly,calm,cald,calt] = split(binspec,{'year','month','day','time'});
        if (caly < 0 || calm < 0 || cald < 0 || calt < 0) || ... 
                (caly == 0 && calm == 0 && cald == 0 && calt == 0)
            error(message('MATLAB:datetime:discretize:InvalidDur'));
        end
        edges = generateBinEdgesFromCalendarDuration(binspec,xmin,xmax,false,maxnbins);
    elseif ischar(binspec) && isrow(binspec)
        binspec = validatestring(binspec, {'century', 'decade', 'year', 'quarter', ...
            'month', 'week', 'day', 'hour', 'minute', 'second'}, funcname, ...
            'DUR', 2);
        [edges,twoedgesformat,fmt] = generateBinEdgesFromBinMethod(binspec,xmin,xmax,false,maxnbins);
    else
        error(message('MATLAB:datetime:discretize:InvalidSecondInput'));
    end
    xdata = x.data;
    edgesdata = edges.data;
end

nbins = length(edgesdata)-1;
    
persistent p p2;
    
if nin > 2 && isrow(varargin{1}) && ~iscell(varargin{1}) ...
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
        right = strcmp(validatestring(...
            p.Results.IncludedEdge,{'left','right'}),'right');
        if right && ischar(binspec) && xmax.data==edgesdata(end-1)
            edges.data(end) = [];
            nbins = nbins - 1;
        end
        catnames = p.Results.categorynames;
        catnames_provided = iscell(catnames);
        if catnames_provided 
            if length(catnames) ~= nbins
                error(message('MATLAB:datetime:discretize:CategoryNamesInvalidSize',nbins));
            end
        elseif ischar(catnames)  % fmt provided
            fmt = catnames;   
        end
    else
        catnames_provided = false;
        right = false;
    end
    
    if ~catnames_provided
        catnames = gencatnames(edges,right,twoedgesformat,fmt);
    end
    
    bins = matlab.internal.datetime.datetimeDiscretize(xdata, edgesdata, right);
    
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
        right = strcmp(validatestring(...
            p2.Results.IncludedEdge,{'left','right'}),'right');
        if right && ischar(binspec) && xmax.data==edgesdata(end-1)
            edges.data(end) = [];
            nbins = nbins - 1;
        end
        values = p2.Results.values;
        values_provided = ~isempty(values);
        if values_provided && length(values) ~= nbins
            error(message('MATLAB:datetime:discretize:ValuesInvalidSize',nbins));
        end
    else
        values_provided = false;
        right = false;
    end
    
    bins = matlab.internal.datetime.datetimeDiscretize(xdata, edgesdata, right);
    if values_provided
        nanbins = isnan(bins);
        if isa(values, 'datetime')
            binindices = bins;
            if any(nanbins(:))
                values.data(end+1) = NaN;               
                binindices(nanbins) = length(values);
            end
            bins = values;  % bins need to be datetime
            % reshape needed when x and values are vectors of different orientation
            bins.data = reshape(values.data(binindices),size(x));           
        else
            if any(nanbins(:))
                try
                    values(end+1) = NaN;
                catch
                    error(message('MATLAB:datetime:discretize:ValuesClassNoNaN',class(values)));
                end
                bins(nanbins) = length(values);
            end
            % reshape needed when x and values are vectors of different orientation
            bins = reshape(values(bins),size(x));
        end
        
    end
    
end

end

function names = gencatnames(edges,includeright,twoedgesformat,fmt)

if ~twoedgesformat
    names = cellstr(edges,fmt);
    names = names(1:end-1);
else
    fullprecision = ~all(timeofday(edges) == seconds(0));
    if ~fullprecision
        if isempty(fmt)
            fmt = getDatetimeSettings('defaultdateformat');
        end
        % Without full precision (i.e. no time component in datetime), always
        % use [A,B) regardless of closedRight. For example, if A and B are at
        % day boundaries, (23-Sep-2016,24-Sep-2016] is confusing when the ] only
        % means including the exact midnight of 24-Sep-2016, rather than the
        % entire day of 24-Sep-2016.
        leftedge = '[';
        rightedge = ')';
    else
        if isempty(fmt)
            fmt = getDatetimeSettings('defaultformat');
        end
        if includeright
            leftedge = '(';
            rightedge = ']';
        else
            leftedge = '[';
            rightedge = ')';
        end
    end

    nbins = length(edges)-1;
    names = cell(1,nbins);
  
    charedges = cellstr(edges,fmt);
    for i = 1:nbins
        names{i} = sprintf('%s%s, %s%s',leftedge,charedges{i},...
            charedges{i+1},rightedge);
    end
    
    if fullprecision
        if includeright
            names{1}(1) = '[';
        else
            names{end}(end) = ']';
        end
    end
    
end

if length(unique(names)) < length(names)
    error(message(['MATLAB:datetime:discretize:DefaultCategoryNamesNotUnique']));
end

end

