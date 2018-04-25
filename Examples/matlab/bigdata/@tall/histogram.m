function h = histogram(varargin)
%HISTOGRAM  Plots a Histogram.
%   Supported syntaxes for tall X:
%   HISTOGRAM(X)
%   HISTOGRAM(X,M)
%   HISTOGRAM(X,EDGES)
%   HISTOGRAM(...,'BinWidth',BW)
%   HISTOGRAM(...,'BinLimits',[BMIN,BMAX])
%   HISTOGRAM(...,'Normalization',NM)
%   HISTOGRAM(...,'DisplayStyle',STYLE)
%   HISTOGRAM(...,'BinMethod',BM) - BM can be 'auto' (default),
%               'scott', 'integers', 'sturges', 'sqrt'
%   HISTOGRAM(...,NAME,VALUE) set the property NAME to VALUE.
%   HISTOGRAM(AX,...) plots into AX instead of the current axes
%   H = HISTOGRAM(...) also returns a histogram object.
%   
%   Limitation: Properties and methods of the histogram output object that 
%   require recomputing the bins are not supported for tall arrays.  These
%   include the methods morebins and fewerbins and the properties BinWidth,
%   BinLimits, and NumDisplayBins.
%
%   Supported syntaxes for tall categorical C:
%   HISTOGRAM(C)
%   HISTOGRAM(C, CATEGORIES)
%   HISTOGRAM(...,'Normalization',NM)
%
%     See also HISTOGRAM, CATEGORICAL/HISTOGRAM


%   Copyright 2016-2017 The MathWorks, Inc.

[cax,args] = matlab.bigdata.internal.util.axesCheck(varargin{:});
narginchk(1,inf);
x = args{1};
args(1) = [];

x  = tall.validateType(x,mfilename,{'numeric','logical', 'categorical'},1);
tall.checkNotTall(upper(mfilename), 1, args{:});

isCat = isequal(x.Adaptor.Class, 'categorical');

opts = parseinput(args,isCat);
[countArgs, plotArgs] = iSplitCountAndPlotArgs(opts, isCat);

if isCat
    % For categoricals, the edges are categories.
    [N, cats] = histcounts(x, countArgs{:});
    [N, cats] = gather(N, cats);
    cax = newplot(cax);
    h1 = histogram(cax, 'Categories', cats, 'BinCounts', N, plotArgs{:});
else
    [N, edges] = histcounts(x, countArgs{:});
    [N, edges] = gather(N, edges);
    cax = newplot(cax);
    h1 = histogram(cax, 'BinEdges', edges, 'BinCounts', N, plotArgs{:});
end

if nargout > 0
    h = h1;
end

end

function [countArgs, plotArgs] = iSplitCountAndPlotArgs(opts, isCat)
if isCat
    countNames = {'Categories'};
    opts = rmfield(opts, 'BinMethod');
else
    countNames = {'NumBins', 'MaxNumBins', 'BinEdges','BinLimits',...
        'BinWidth','BinMethod'};
end

names = fieldnames(opts);
values = struct2cell(opts);

% remove null args
notEmpty = ~cellfun(@isempty, values);
names = names(notEmpty);
values = values(notEmpty);

% Extract the name value pairs for histcounts
isCountArg = ismember(names, countNames);
countNames = names(isCountArg);
countValues = values(isCountArg);
countArgs = iMergeNameValuePairs(countNames, countValues);

% The rest of the args must be plot visualization arguments
plotNames = names(~isCountArg);
plotValues = values(~isCountArg);
plotArgs = iMergeNameValuePairs(plotNames, plotValues);
end

function nameValuePairs = iMergeNameValuePairs(names, values)
nameValuePairs = [names values]';
nameValuePairs = nameValuePairs(:)';
end

function opts = parseinput(input, isCat)

opts = struct('Categories', [], 'NumBins',[],'BinEdges',[],'BinLimits',[],'BinWidth',[],...
    'Normalization','count','BinMethod','auto','DisplayStyle','bar',...
    'EdgeAlpha',1,'EdgeColor',[],'FaceAlpha',0.6,'FaceColor',[],...
    'LineStyle','-','LineWidth',0.5,'Orientation','vertical');
funcname = mfilename;

% Parse second input in the function call
if ~isempty(input)
    in = input{1};
    inputoffset = 0;
    if isnumeric(in) || islogical(in) || iscategorical(in)  || iscellstr(in)
        if iscategorical(in)  || iscellstr(in)
            opts.Categories = in;
        elseif isscalar(in)
            validateattributes(in,{'numeric','logical'},{'integer', 'positive'}, ...
                funcname, 'm', inputoffset+2)
            opts.NumBins = in;
            opts.BinMethod = [];
        else
            validateattributes(in,{'numeric','logical'},{'vector','nonempty', ...
                'real', 'nondecreasing'}, funcname, 'edges', inputoffset+2)
            opts.BinEdges = in;
            opts.BinMethod = [];
        end
        input(1) = [];
        inputoffset = 1;
    end
    
    % All the rest are name-value pairs
    inputlen = length(input);
    if rem(inputlen,2) ~= 0
        error(message('MATLAB:histcounts:ArgNameValueMismatch'))
    end
    
    for i = 1:2:inputlen
        name = validatestring(input{i}, {'Categories','NumBins','BinEdges','BinWidth',...
            'BinLimits','Normalization','DisplayStyle','BinMethod',...
            'EdgeAlpha','EdgeColor','FaceAlpha','FaceColor','LineStyle',...
            'LineWidth','Orientation'}, i+1+inputoffset);
        
        value = input{i+1};
        switch name
            case 'Categories'
                validateattributes(value,{'cell','categorical'},{}, ...
                    funcname, 'categories', i+2+inputoffset);
                opts.Categories = value;
            case 'NumBins'
                validateattributes(value,{'numeric','logical'},{'scalar', 'integer', ...
                    'positive'}, funcname, 'NumBins', i+2+inputoffset)
                opts.NumBins = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.BinWidth = [];
            case 'BinEdges'
                validateattributes(value,{'numeric','logical'},{'vector', ...
                    'real', 'nondecreasing'}, funcname, 'BinEdges', i+2+inputoffset);
                if length(value) < 2
                    error(message('MATLAB:histcounts:EmptyOrScalarBinEdges'));
                end
                opts.BinEdges = value;
                opts.BinMethod = [];
                opts.NumBins = [];
                opts.BinWidth = [];
                opts.BinLimits = [];
            case 'BinWidth'
                validateattributes(value, {'numeric','logical'}, {'scalar', 'real', ...
                    'positive', 'finite'}, funcname, 'BinWidth', i+2+inputoffset);
                opts.BinWidth = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinMethod = [];
                opts.NumBins = [];
            case 'BinLimits'
                validateattributes(value, {'numeric','logical'}, {'numel', 2, 'vector', 'real', ...
                    'nondecreasing', 'finite'}, funcname, 'BinLimits', i+2+inputoffset)
                opts.BinLimits = value;
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
            case 'Normalization'
                opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                    'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+2+inputoffset);
            case 'DisplayStyle'
                opts.DisplayStyle = validatestring(value, {'bar','stairs'},...
                    funcname, 'DisplayStyle', i+2+inputoffset);
            case 'BinMethod'
                opts.BinMethod = validatestring(value, {'auto','scott', ...
                    'integers', 'sturges', 'sqrt'}, funcname, 'BinMethod', i+2+inputoffset);
                if ~isempty(opts.BinEdges)
                    error(message('MATLAB:histcounts:InvalidMixedBinInputs'))
                end
                opts.BinWidth = [];
                opts.NumBins = [];
            case 'EdgeAlpha'
                validateattributes(value,{'numeric'},{'scalar','<=',1,'nonnegative'},...
                    funcname,'EdgeAlpha',i+2+inputoffset);
                opts.EdgeAlpha = value;
            case 'EdgeColor'
                try
                    opts.EdgeColor = hgcastvalue('matlab.graphics.datatype.RGBAutoNoneColor',value);
                catch
                    error(message('MATLAB:bigdata:array:BadEdgeColor'));
                end                
            case 'FaceAlpha'
                validateattributes(value,{'numeric'},{'scalar','<=',1,'nonnegative'},...
                    funcname,'FaceAlpha',i+2+inputoffset);
                opts.FaceAlpha = value;
            case 'FaceColor'
                try
                    opts.FaceColor = hgcastvalue('matlab.graphics.datatype.RGBAutoNoneColor',value);
                catch
                    error(message('MATLAB:bigdata:array:BadFaceColor'));
                end     
            case 'LineStyle'
                opts.LineStyle = validatestring(value, {'-','--',':','-.','none'},...
                    funcname, 'LineStyle', i+2+inputoffset);
            case 'LineWidth'
                validateattributes(value,{'numeric','logical'},{'scalar', ...
                    'positive'}, funcname, 'LineWidth', i+2+inputoffset);
                opts.LineWidth = value;
            case 'Orientation'
                opts.Orientation = validatestring(value, {'vertical','horizontal'},...
                    funcname, 'Orientation', i+2+inputoffset);
        end
    end
end

% Set some dependent options
if isempty(opts.FaceColor)
    if strcmpi(opts.DisplayStyle,'stairs')
        opts.FaceColor = 'none';
    else
        opts.FaceColor = 'auto';
    end
end
if isempty(opts.EdgeColor)
    if strcmpi(opts.DisplayStyle,'stairs')
        opts.EdgeColor = 'auto';
    else
        opts.EdgeColor = [0 0 0];
    end
end

if ~isCat && strcmpi(opts.BinMethod, 'auto') && isempty(opts.NumBins) &&...
        isempty(opts.BinWidth) && isempty(opts.BinEdges)
    % Force histcounts to use the bin method that uses the auto rule with a
    % maximum allowed number of bins.
    opts.MaxNumBins = 100;
    opts.BinMethod = '';
end
end

