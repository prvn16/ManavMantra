function [bins, edges] = discretize(x, edges, varargin)
% discretize  Group numeric data into bins or categories.
%    BINS = discretize(X,EDGES) returns the indices of the bins that the 
%    elements of X fall into.  EDGES is a numeric vector that contains bin 
%    edges in monotonically increasing order. An element X(i) falls into 
%    the j-th bin if EDGES(j) <= X(i) < EDGES(j+1), for 1 <= j < N where 
%    N is the number of bins and length(EDGES) = N+1. The last bin includes 
%    the right edge such that it contains EDGES(N) <= X(i) <= EDGES(N+1). For 
%    out-of-range values where X(i) < EDGES(1) or X(i) > EDGES(N+1) or 
%    isnan(X(i)), BINS(i) returns NaN.
%     
%     
%    [BINS, EDGES] = discretize(X,N) where N is a scalar integer, divides the
%    range of X into N uniform bins, and also returns the bin edges.
%
%    [BINS, EDGES] = discretize(...,VALUES) returns the corresponding 
%    element in VALUES, rather than the bin number. For example, if X(1) 
%    falls into bin 5 then BINS(1) would be VALUES(5) rather than 5. VALUES 
%    must be a vector with length equal to the number of bins. Out-of-range 
%    inputs return NaN. 
%     
%    [C, EDGES] = discretize(...,'categorical') creates a categorical array from 
%    the binned result of X. C will have the same number of categories 
%    as the number of bins. The category names will be in the form of 
%    "[A,B)", or "[A,B]" for the last bin, where A and B are consecutive 
%    values from EDGES. Out-of-range values will be undefined in C.
%     
%    [C, EDGES] = discretize(...,'categorical',CATEGORYNAMES) additionally 
%    specifies names for the categories in C using CATEGORYNAMES.  
%    CATEGORYNAMES is a cell array of character vectors and has
%    length equal to the number of bins.  
% 
%    [...] = discretize(...,'IncludedEdge',SIDE) specifies which bin edge is 
%    included in the bins. SIDE can be:
%        'left'    Each bin includes the left bin edge, except for the last bin
%                  which includes both bin edges. This is the default.
%        'right'   Each bin includes the right bin edge, except for the first 
%                  bin which includes both bin edges.
%    If SIDE is 'right', an element X(i) falls into the j-th bin if
%    EDGES(j) < X(i) <= EDGES(j+1), for 1 < j <= N where N is the number
%    of bins. The first bin includes the left edge such that it contains 
%    EDGES(1) <= X(i) <= EDGES(2).
%    
%    Class support for inputs X, EDGES:
%       float: double, single
%       integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%       logical
% 
%    Example:
%       x = rand(10,1);
%       bins = discretize(x,0:0.25:1);  % group into 4 bins 
%
%    See also HISTCOUNTS, HISTOGRAM, CATEGORICAL

%   Copyright 1984-2016 The MathWorks, Inc.

nin = nargin;

funcname = mfilename();
validateattributes(x, {'numeric','logical'}, {'real'}, funcname, 'x', 1)
validateattributes(edges, {'numeric','logical'},{'vector', 'real', ...
    'nondecreasing'}, funcname, 'edges', 2)
if isscalar(edges)
    numbins = double(edges);
    if floor(numbins) ~= numbins || numbins < 1 || ~isfinite(numbins) 
        error(message('MATLAB:discretize:InvalidN'));
    end
    xfinite = x(isfinite(x));
    xmin = min(xfinite);
    xmax = max(xfinite);
    xrange = xmax - xmin;
    edges = matlab.internal.math.binpicker(xmin,xmax,numbins,...
        xrange/numbins);
elseif isempty(edges)
    error(message('MATLAB:discretize:EmptyOrScalarEdges'));
end

% make sure edges are non-sparse, handle subclass of builtin class
if isobject(x)
    x = matlab.internal.language.castToBuiltinSuperclass(x);
end
if isobject(edges)
    edges = matlab.internal.language.castToBuiltinSuperclass(edges);
end
edges = full(edges);
nbins = length(edges)-1;
    
persistent p p2;
    
if nin > 2 && partialMatchName("categorical", varargin{1})
    % create categorical output
    if nin > 3
        if isempty(p)
            p = inputParser;
            addOptional(p, 'categorynames', NaN, @(x) (iscellstr(x) || isstring(x)) && isvector(x))
            addParameter(p, 'IncludedEdge', 'left', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}))
        end
        parse(p,varargin{2:end})
        catnames = p.Results.categorynames;
        if isstring(catnames)
            catnames = cellstr(catnames);
        end
        catnames_provided = iscell(catnames);
        if catnames_provided && length(catnames) ~= nbins
            error(message('MATLAB:discretize:CategoryNamesInvalidSize',nbins));
        end
        
        right = strcmp(validatestring(...
            p.Results.IncludedEdge,{'left','right'}),'right');
    else
        catnames_provided = false;
        right = false;
    end
    
    if ~catnames_provided
        catnames = matlab.internal.datatypes.numericBinEdgesToCategoryNames(edges,right);
    end
    
    bins = discretizemex(x, edges, right);
    
    bins = categorical(bins, 1:nbins, catnames, 'Ordinal', true);
else
    % create numerical output
    if nin > 2
        if isempty(p2)
            p2 = inputParser;
            addOptional(p2, 'values', [], @(x) isvector(x) && ~isempty(x) ...
                && ~ischar(x) && ~(isstring(x) && isscalar(x)) ...
                && ~isa(x,'function_handle'))
            addParameter(p2, 'IncludedEdge', 'left', ...
                @(x) validateattributes(x,{'char','string'},{'scalartext'}))
        end
        parse(p2,varargin{:})
        values = p2.Results.values;
        values_provided = ~isempty(values);
        if values_provided && length(values) ~= nbins
            error(message('MATLAB:discretize:ValuesInvalidSize',nbins));
        end
        right = strcmp(validatestring(...
            p2.Results.IncludedEdge,{'left','right'}),'right');
    else
        values_provided = false;
        right = false;
    end
    
    bins = discretizemex(x, edges, right);
    if values_provided
        nanbins = isnan(bins);
        if any(nanbins(:))
            try
                values(end+1) = NaN;
            catch
                error(message('MATLAB:discretize:ValuesClassNoNaN',class(values)));
            end
            bins(nanbins) = length(values);
        end
        % reshape needed when x and values are vectors of different orientation
        bins = reshape(values(bins),size(x));
    end
    
end

end

function tf = partialMatchName(nameStr, arg)
    if ((isstring(arg) && isscalar(arg)) || (ischar(arg) && isrow(arg))) && (strlength(arg) > 0)
        tf = strncmpi(arg, nameStr, strlength(arg));
    else
        tf = false(size(nameStr));
    end
end