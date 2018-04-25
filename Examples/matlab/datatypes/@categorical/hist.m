function [no,xo] = hist(ax,y,x)
%HIST Histogram of a categorical array.
%   HIST(Y) with no output arguments produces a histogram bar plot of the
%   counts for each category in the categorical vector Y.  If Y is an M-by-N
%   categorical matrix, HIST computes counts for each column of Y, and plots
%   a group of N bars for each category.
%
%   HIST(Y,X) plots bars only for the categories specified by X.  X is a
%   categorical vector or a cell array of character vectors.
%
%   HIST(AX,...) plots into AX instead of GCA.
%
%   N = HIST(...) returns the counts for each category.  If Y is a matrix, HIST
%   works down the columns of Y and returns a matrix of counts with one column
%   for each column of Y and one row for each category.
%
%   [N,X] = HIST(...) also returns the categories corresponding to each count in
%   N, or corresponding to each column of N if Y is a matrix.
%
%   See also COUNTCATS, CATEGORIES.

%   Copyright 2009-2016 The MathWorks, Inc.

% Shift inputs if necessary.
if ishandle(ax) % hist(ax,y) or hist(ax,y,x)
    if nargin < 3
        x = [];
    end
elseif isa(ax,'categorical') % hist(y) or hist(y,x)
    narginchk(0,2);
    if nargin > 1
        x = y;
    else
        x = [];
    end
    y = ax;
    ax = [];
else
    error(message('MATLAB:categorical:hist:InvalidInput'));
end

% If N-D, force to a matrix to be consistent with hist function.
if ~ismatrix(y), y = y(:,:); end

% Figure out what categories to use for the bars.
useAllCategories = isempty(x);
if useAllCategories
    xnames = categories(y);
elseif ~isa(x,'categorical')
    if ~matlab.internal.datatypes.isCharStrings(x)
        error(message('MATLAB:categorical:hist:InvalidCategories'));
    end
    xnames = x(:); % a column
    if isordinal(y) && ~isempty(setdiff(xnames,y.categoryNames))
        error(message('MATLAB:categorical:hist:UnrecognizedCategories'));
    end
elseif x.isOrdinal == y.isOrdinal %% isa(x,'categorical')
    % If x is categorical, its ordinalness has to match y, and if they are
    % ordinal, their categories have to match.
    if isordinal(y) && ~isequal(y.categoryNames,x.categoryNames)
        error(message('MATLAB:categorical:OrdinalCategoriesMismatch'));
    end
    % The histogram bars will be based on x's values, not its categories
    xnames = cellstr(x(:)); % a column
else
    error(message('MATLAB:categorical:hist:OrdinalMismatch'));
end

ctrs = 1:length(xnames);

% Convert y's internal codes into contiguous bin numbers for hist (we may be
% plotting bars for an out of order subset of y's categories). Need to force
% hist to ignore undefined elements in y, and elements of y from categories not
% specified in x -- set those bin numbers to NaN.
[~,ix] = ismember(y.categoryNames,xnames);
ix(ix == 0) = NaN;
ix = [NaN; ix(:)]; % prepend a NaN for zero codes (undefined elements)
ycodes = ix(y.codes+1);

if nargout == 0
    if isempty(ax), ax = gca; end
    counts = hist(ycodes,ctrs);
    bar(ax,ctrs,counts,.95)
    set(ax,'XTick',ctrs,'XTickLabel',xnames,'Ylim',[0 max(1.1*max(counts(:)),1)]);
    
    % Disable linking and brushing
    ph = get(ax,'Children');
    for i = 1:length(ph) % multiple patches for grouped bars 
        set(hggetbehavior(ph(i),'linked'),'Enable',false);
        set(hggetbehavior(ph(i),'brush'),'Enable',false);
    end
else
    [no,ctrs] = hist(ycodes,ctrs);
    if nargout > 1
        xo = reshape(xnames,size(ctrs));
    end
end
