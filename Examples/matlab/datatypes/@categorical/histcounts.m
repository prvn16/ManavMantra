function [n,catnames] = histcounts(x, varargin)
%HISTCOUNTS  Histogram bin counts of a categorical array.
%   N = HISTCOUNTS(X) for a categorical array X, returns a vector N 
%   containing the number of elements in X whose value is equal to each of 
%   X's categories. N has one element for each category in X. X can be a 
%   vector, matrix, or multidimensional array. If X is not a vector, then 
%   HISTCOUNTS treats it as a single column vector, X(:).
%
%   N = HISTCOUNTS(X,CATEGORIES), counts only the categories specified by 
%   CATEGORIES.  CATEGORIES is a categorical vector with unique elements 
%   or a cell array of unique character vectors.
%
%   N = HISTCOUNTS(...,'Normalization',NM) specifies the
%   normalization scheme of the histogram values returned in N. NM can be:
%                  'count'   Each N value is the number of elements in 
%                            each category, and SUM(N) is equal to NUMEL(X)
%                            or SUM(ISMEMBER(X(:),CATEGORIES)). This is the 
%                            default.
%           'countdensity'   Returns the same result as 'count' for categorical 
%                            histograms.
%            'probability'   Each N value is the relative number of 
%                            observations (number of elements in category/ 
%                            total number of elements), and SUM(N) <= 1.
%                    'pdf'   Probability density function estimate. Returns 
%                            the same result as 'probability' for categorical 
%                            histograms.
%               'cumcount'   Each N value is the cumulative number of 
%                            elements in each categories and all previous 
%                            categories. N(end) <= NUMEL(X).
%                    'cdf'   Cumulative density function estimate. Each N 
%                            value is the cumulative relative number of 
%                            observations in each category and all previous 
%                            categories. N(end) <= 1.
%
%   [N,CATEGORIES] = HISTCOUNTS(...) also returns the categories corresponding 
%   to each count in N.
%
%   See also CATEGORICAL/HISTOGRAM

%   Copyright 1984-2016 The MathWorks, Inc.

if ~iscategorical(x)
    error(message('MATLAB:categorical:histcounts:NonCategoricalX'));
end

persistent p;
if nargin > 1
    if isempty(p)
        p = inputParser;
        addOptional(p, 'categories', NaN, @(x) (iscellstr(x) || ...
            iscategorical(x)) && (isvector(x) || isempty(x)) ...
            && length(x)==length(unique(x)))
        addParameter(p, 'Normalization', NaN, ...
            @(x) validateattributes(x,{'char'},{}))
    end
    parse(p,varargin{:})
    cats = p.Results.categories;
    if ~ischar(p.Results.Normalization)  % Normalization not specified
        normalization = 'count';
    else
        normalization = validatestring(p.Results.Normalization, {'count',...
            'probability', 'countdensity', 'pdf', 'cumcount', 'cdf'});
    end
else
    cats = NaN;
    normalization = 'count';
end

% Figure out what categories to count
if isnumeric(cats)  % Categories not specified, use categories in X
    catnames = x.categoryNames;
elseif ~isa(cats,'categorical')
    catnames = cats(:); % a column
    % ordinal is stricter, cannot include categories not in the
    % categorical, and order of categories must be the same
    if isordinal(x) 
        if ~all(ismember(catnames,x.categoryNames))
            error(message('MATLAB:categorical:histcounts:UnrecognizedCategories'));
        end
    end
elseif x.isOrdinal == cats.isOrdinal %% isa(categories,'categorical')
    % If CATEGORIES is categorical, its ordinalness has to match x, and if they are
    % ordinal, their categories have to match.
    if isordinal(x) && ~isequal(x.categoryNames,cats.categoryNames)
        error(message('MATLAB:categorical:histcounts:OrdinalCategoriesMismatch'));
    end
    % Use CATEGORIES' values, not its categories
    % Filter out undefined categories before extracting category names
    cats.codes(cats.codes==0) = [];
    catnames = cellstr(cats(:)); % a column
else
    error(message('MATLAB:categorical:histcounts:OrdinalMismatch'));
end

% Convert CATEGORIES' internal codes into contiguous bin numbers (we may be
% counting an out of order subset of x's categories). Make sure to
% ignore undefined elements in x, and elements of x from categories not
% specified in CATEGORIES -- set those bin numbers to NaN.
[~,ix] = ismember(x.categoryNames,catnames);
ix(ix == 0) = NaN;
ix = [NaN; ix(:)]; % prepend a NaN for zero codes (undefined elements)
xcodes = ix(x.codes+1);

if ~isempty(catnames)
    n = histcounts(xcodes,0.5:length(catnames)+0.5);
else
    n = zeros(1,0);
end
catnames = reshape(catnames, 1, []);

switch normalization
    case 'cumcount'
        n = cumsum(n);
    case {'probability','pdf'}
        n = n / numel(x);
    case 'cdf'
        n = cumsum(n / numel(x));
end
    
end

