function h = histogram(varargin)
%HISTOGRAM  Plots a histogram for a categorical array.
%   HISTOGRAM(X) plots a histogram of a categorical array X. A bar is
%   plotted for each category in X. X can be a vector, matrix, or 
%   multidimensional array. If X is not a vector, then HISTOGRAM treats it 
%   as a single column vector, X(:), and plots a single histogram.
%
%   HISTOGRAM(X,CATEGORIES), plots only the categories specified by 
%   CATEGORIES.  CATEGORIES is a categorical vector with unique elements 
%   or a cell array of unique character vectors.
%
%   HISTOGRAM(...,'DisplayOrder',ORDER) specifies the order of the categories in
%   the histogram. ORDER can be 'ascend', 'descend', or 'data'. With 'ascend' 
%   or 'descend', the histogram is displayed with increasing or decreasing 
%   bar heights. With 'data', the histogram uses the category order in the 
%   data, X. The default is 'data'. 
%
%   HISTOGRAM(...,'NumDisplayBins',M) plots only the first M categories. 
%
%   HISTOGRAM(...,'ShowOthers',ONOFF), when set to 'on', displays an 
%   additional bar with the name 'Others'. This extra bar counts all elements 
%   that do not belong to any categories displayed in the histogram. The
%   default value is 'off'.
%
%   HISTOGRAM(...,'Normalization',NM) specifies the normalization scheme 
%   of the histogram values. The normalization scheme affects the scaling 
%   of the histogram along the vertical axis (or horizontal axis if 
%   Orientation is 'horizontal'). NM can be:
%                  'count'   The height of each bar is the number of 
%                            elements in each category, and the sum of the
%                            bar heights is NUMEL(X) or 
%                            SUM(ISMEMBER(X(:),CATEGORIES)). This is the 
%                            default.
%           'countdensity'   Returns the same result as 'count' for categorical 
%                            histograms.
%            'probability'   The height of each bar is the relative 
%                            number of observations (number of elements in 
%                            category / total number of elements), 
%                            and the sum of the bar heights <= 1.
%                    'pdf'   Probability density function estimate. Returns 
%                            the same result as 'probability' for categorical 
%                            histograms.
%               'cumcount'   The height of each bar is the cumulative 
%                            number of elements in each category and all
%                            previous categories. The height of the last bar
%                            <= NUMEL(X).
%                    'cdf'   Cumulative density function estimate. The height 
%                            of each bar is the cumulative relative number
%                            of observations in each category and all 
%                            previous categories. The height of the last bar <= 1.
%
%   HISTOGRAM(...,'DisplayStyle',STYLE) specifies the display style of the 
%   histogram. STYLE can be:
%                    'bar'   Display a histogram bar plot. This is the default.
%                 'stairs'   Display a stairstep plot, which shows the 
%                            outlines of the histogram without filling the 
%                            interior. 
%
%   HISTOGRAM(...,'Orientation',ORIENTATION) specifies the orientation of 
%   the histogram. ORIENTATION can be:
%               'vertical'   Histogram bars are drawn vertically towards
%                            the positive Y axis direction. This is the 
%                            default.
%             'horizontal'   Histogram bars are drawn horizontally towards
%                            the positive X axis direction.
%
%   HISTOGRAM('Categories', CATEGORIES, 'BinCounts', COUNTS) where COUNTS 
%   is a vector of the same length as CATEGORIES, manually specifies
%   the bin counts. HISTOGRAM plots the counts and does not do any data binning.
%  
%   HISTOGRAM(...,NAME,VALUE) set the property NAME to VALUE. 
%     
%   HISTOGRAM(AX,...) plots into AX instead of the current axes.
%       
%   H = HISTOGRAM(...) also returns a histogram object. Use this to inspect 
%   and adjust the properties of the histogram.
%
%   See also CATEGORICAL/HISTCOUNTS, matlab.graphics.chart.primitive.categorical.Histogram

%   Copyright 1984-2017 The MathWorks, Inc.

[cax,args] = axescheck(varargin{:});
% Check whether the first input is an axes input, which would have been
% stripped by the axescheck function
firstaxesinput = (rem(length(varargin) - length(args),2) == 1);

[opts,passthrough] = parseinput(args,firstaxesinput);

cax = newplot(cax);
switch cax.NextPlot
    case {'replaceall','replace'}
        cax.Box = 'on';
        matlab.graphics.internal.setRulerLayerTop(cax);
    case 'replacechildren'
        matlab.graphics.internal.setRulerLayerTop(cax);
end
[~,autocolor] = specgraphhelper('nextstyle',cax,true,false,false);

optscell = binspec2cell(opts);
if isfield(opts,'Categories')
    ord = false;
    if ~isfield(opts, 'BinCounts') && isfield(opts, 'Data')
        ord = isordinal(opts.Data);
    end
    xaxis = categorical(opts.Categories,opts.Categories, 'Ordinal', ord);
else
    xaxis = opts.Data;
end
if (isfield(opts,'Orientation') && strcmp(opts.Orientation, 'horizontal')) || ...
        (~isfield(opts,'Orientation') && strcmp(get(cax, 'defaultCategoricalhistogramOrientation'), 'horizontal'))
    matlab.graphics.internal.configureAxes(cax,1,xaxis);
else
    matlab.graphics.internal.configureAxes(cax,xaxis,1);
end
hObj = matlab.graphics.chart.primitive.categorical.Histogram('Parent', cax, ...
    'AutoColor', autocolor, optscell{:}, passthrough{:});

% disable brushing, basic fit, and data statistics
hbrush = hggetbehavior(hObj,'brush');  
hbrush.Enable = false;
hbrush.Serialize = true;
hdatadescriptor = hggetbehavior(hObj,'DataDescriptor');
hdatadescriptor.Enable = false;
hdatadescriptor.Serialize = true;

if nargout > 0
    h = hObj;
end
end

function [opts,passthrough] = parseinput(input,inputoffset)

import matlab.internal.datatypes.isCharStrings

opts = struct;
bincountsmode = [];
funcname = mfilename;
passthrough = {};

% Parse first input
if ~isempty(input)
    x = input{1};
    if ~ischar(x)
        input(1) = [];
        if ~iscategorical(x)
            error(message('MATLAB:categorical:histogram:NonCategoricalX'));
        end
        opts.Data = x;
        inputoffset = inputoffset + 1;
    else
        x = categorical([]);
    end
    
    % Parse second input in the function call
    if ~isempty(input)
        in = input{1};
        if ~ischar(in)
            validateattributes(in,{'cell','categorical'},{}, ...
                funcname, 'categories', 2)
            if ~(isvector(in) || isempty(in))
                error(message('MATLAB:categorical:histogram:NonVectorCategories'));
            end
            if length(in)~=length(unique(in))
                error(message('MATLAB:categorical:histogram:RepeatedCategories'));
            end
            if ~isa(in,'categorical')
                if ~isCharStrings(in)
                    error(message('MATLAB:categorical:histogram:InvalidCategories'));
                end
                opts.Categories = reshape(in,1,[]); % a row
                if isordinal(x)
                    if ~all(ismember(in,x.categoryNames))
                        error(message('MATLAB:categorical:histogram:UnrecognizedCategories'));
                    end
                end
            else % isa(categories,'categorical')
                if isfield(opts, 'Data')
                    if x.isOrdinal == in.isOrdinal
                        % If categories is categorical, its ordinalness has to match x, and if they are
                        % ordinal, their categories have to match.
                        if isordinal(x) && ~isequal(x.categoryNames,in.categoryNames)
                            error(message('MATLAB:categorical:histogram:OrdinalCategoriesMismatch'));
                        end   
                    else
                        error(message('MATLAB:categorical:histogram:OrdinalMismatch'));
                    end
                end
                % The histogram bins will be based on categories' values, not its categories
                % Filter out undefined categories before extracting category names
                in.codes(in.codes==0) = [];
                opts.Categories = cellstr(reshape(in,1,[])); % a column
            end
            input(1) = [];
            inputoffset = inputoffset + 1;
        end
        
        % All the rest are name-value pairs
        if rem(length(input),2) ~= 0
            error(message('MATLAB:histogram:ArgNameValueMismatch'))
        end
        
        % compile the list of all settable property names, filtering out the
        % read-only properties
        names = setdiff(properties('matlab.graphics.chart.primitive.categorical.Histogram'),...
            {'Children','Values','Type','Annotation','BeingDeleted','OthersValue'});
        inputlen = length(input);
        for i=1:2:inputlen
            
            name = validatestring(input{i},names);
            
            value = input{i+1};
            switch name
                case 'Categories'
                    validateattributes(value,{'cell','categorical'},{'vector'}, ...
                        funcname, 'categories', i+1+inputoffset)
                    if length(value)~=length(unique(value))
                        error(message('MATLAB:categorical:histogram:RepeatedCategories'));
                    end
                    if ~isa(value,'categorical')
                        if ~isCharStrings(value)
                            error(message('MATLAB:categorical:histogram:InvalidCategories'));
                        end
                        opts.Categories = reshape(value,1,[]); % a row
                        if isordinal(x)
                            if ~all(ismember(value,x.categoryNames))
                                error(message('MATLAB:categorical:histogram:UnrecognizedCategories'));
                            end
                        end
                    else
                        if isfield(opts, 'Data')
                            if x.isOrdinal == value.isOrdinal %% isa(categories,'categorical')
                                % If categories is categorical, its ordinalness has to match x, and if they are
                                % ordinal, their categories have to match.
                                if isordinal(x) && ~isequal(x.categoryNames,value.categoryNames)
                                    error(message('MATLAB:categorical:histogram:OrdinalCategoriesMismatch'));
                                end
                                
                            else
                                error(message('MATLAB:categorical:histogram:OrdinalMismatch'));
                            end
                        end
                        % The histogram bins will be based on categories' values, not its categories
                        % Filter out undefined categories before extracting category names
                        value.codes(value.codes==0) = [];
                        opts.Categories = cellstr(reshape(value,1,[])); % a column
                    end
                case 'NumDisplayBins'
                    validateattributes(value,{'numeric','logical'},{'scalar', ...
                        'integer','nonnegative'}, funcname, 'NumDisplayBins', i+1+inputoffset)
                    opts.NumDisplayBins = value;
                case 'DisplayOrder'
                    opts.DisplayOrder = validatestring(value, {'ascend', 'descend', ...
                        'data'}, funcname, 'DisplayOrder', i+1+inputoffset);
                case 'Normalization'
                    opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                        'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+1+inputoffset);
                case 'BinCounts'
                    validateattributes(value,{'numeric','logical'},{'real', ...
                        'vector','nonnegative','finite'}, funcname, 'BinCounts', i+1+inputoffset)
                    opts.BinCounts = reshape(value,1,[]);   % ensure row
                case 'BinCountsMode'
                    bincountsmode = validatestring(value, {'auto', 'manual'}, ...
                        funcname, 'BinCountsMode', i+1+inputoffset);
                case 'Orientation'
                    opts.Orientation = validatestring(value, {'vertical', 'horizontal'}, ...
                        funcname, 'Orientation', i+1+inputoffset);
                case 'ShowOthers'
                    opts.ShowOthers = validatestring(value, {'on', 'off'}, ...
                        funcname, 'ShowOthers', i+1+inputoffset);
                otherwise
                    % all other options are passed directly to the object
                    % constructor, making sure we pass in the full property names
                    passthrough = [passthrough {name} input(i+1)]; %#ok<AGROW>
            end
        end
        
        % error checking about consistency between properties
        if ~isempty(bincountsmode)
            if strcmp(bincountsmode, 'auto')
                if isfield(opts, 'BinCounts')
                    error(message('MATLAB:categorical:histogram:NonEmptyBinCountsAutoMode'));
                end
            else  % manual
                if ~isfield(opts,'BinCounts')
                    error(message('MATLAB:categorical:histogram:EmptyBinCountsManualMode'));
                end
            end
            passthrough = [passthrough {'BinCountsMode' bincountsmode}];
        end
        
        if isfield(opts,'BinCounts')
            % ShowOthers is not supported with manual bin counts
            if isfield(opts, 'ShowOthers') && strcmp(opts.ShowOthers,'on')
                error(message('MATLAB:categorical:histogram:ShowOthersManualMode'));
            elseif isfield(opts, 'NumDisplayBins')
                error(message('MATLAB:categorical:histogram:NumDisplayBinsManualMode'));
            end
            % check consistency between Categories and BinCounts
            if isfield(opts,'Categories')
                numcats = length(opts.Categories);
            else
                numcats = length(x.categoryNames);
            end
            if numcats ~= length(opts.BinCounts)
                error(message('MATLAB:categorical:histogram:BinCountsInvalidSize'))
            end
            if ~isempty(x)
                error(message('MATLAB:categorical:histogram:MixedDataBinCounts'))
            end
        end
        
        if isfield(opts,'NumDisplayBins')
            % NumDisplayBins cannot be specified along with Categories
            if isfield(opts, 'Categories')
                error(message('MATLAB:categorical:histogram:MixedCategoriesNumDisplayBins'));
            elseif opts.NumDisplayBins > length(x.categoryNames)
                error(message('MATLAB:categorical:histogram:NumDisplayBinsExceedsNumCategories'));
            end
        end
        
        % naming clash regarding 'Others'
        others = getString(message('MATLAB:categorical:histogram:Others'));
        if (isfield(opts, 'ShowOthers') && strcmp(opts.ShowOthers,'on')) && ...
                (any(strcmpi(others, x.categoryNames)) || ...
                (isfield(opts, 'Categories') && any(strcmpi(others, opts.Categories))))
            otherscati = find(strcmpi(others, x.categoryNames),1);
            if ~isempty(otherscati)
                otherscat = x.categoryNames{otherscati};
            else
                otherscati = find(strcmpi(others, opts.Categories),1);
                otherscat = opts.Categories{otherscati};
            end
            error(message('MATLAB:categorical:histogram:AmbiguousOthers',otherscat));
        end
    end
end
end

function binargs = binspec2cell(binspec)
% Construct a cell array of name-value pairs given a binspec struct
binspecn = fieldnames(binspec);  % extract field names
binspecv = struct2cell(binspec);
binargs = [binspecn binspecv]';
end

