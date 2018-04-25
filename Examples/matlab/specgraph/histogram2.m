function h = histogram2(varargin)
%HISTOGRAM2  Plots a bivariate histogram.
%   HISTOGRAM2(X,Y) plots a bivariate histogram of X and Y. X and Y can be 
%   arrays of any shape, but they must have the same size. HISTOGRAM2 
%   determines the bin edges using an automatic binning algorithm that 
%   returns uniform bins of an area chosen to cover the range of values in 
%   X and Y and reveal the shape of the underlying distribution. 
%
%   HISTOGRAM2(X,Y,NBINS), where NBINS is a scalar or 2-element vector, 
%   specifies the number of bins to use. A scalar specifies the same number 
%   of bins in each dimension, whereas the 2-element vector [nbinsx nbinsy] 
%   specifies a different number of bins for the X and Y dimensions.
%
%   HISTOGRAM2(X,Y,XEDGES,YEDGES), where XEDGES and YEDGES are vectors, 
%   specifies the edges of the bins.
%
%   The value [X(k),Y(k)] is in the (i,j)th bin if XEDGES(i) <= X(k) < 
%   XEDGES(i+1) and YEDGES(j) <= Y(k) < YEDGES(j+1). The last bins in the
%   X and Y dimensions will also include the upper edge. For example, 
%   [X(k),Y(k)] will fall into the i-th bin in the last row if 
%   XEDGES(end-1) <= X(k) <= XEDGES(end) && YEDGES(i) <= Y(k) < YEDGES(i+1).
%
%   HISTOGRAM2(...,'BinWidth',BW) where BW is a scalar or 2-element vector, 
%   uses bins of size BW. A scalar specifies the same bin width for each 
%   dimension, whereas the 2-element vector [bwx bwy] specifies different 
%   bin widths for the X and Y dimensions. To prevent from accidentally 
%   creating too many bins, a limit of 1024 bins can be created along each 
%   dimension when specifying 'BinWidth'. If BW is too small such that more 
%   than 1024 bins are needed in either dimension, HISTOGRAM2 uses larger 
%   bins instead.
%
%   HISTOGRAM2(...,'XBinLimits',[XBMIN,XBMAX]) plots a histogram 
%   with only elements between the bin limits inclusive along the X axis, 
%   X>=BMINX & X<=BMAXX.  Similarly, 
%   HISTOGRAM2(...,'YBinLimits',[YBMIN,YBMAX]) uses only elements between 
%   the bin limits inclusive along the Y axis, Y>=YBMIN & Y<=YBMAX.
%
%   HISTOGRAM2(...,'Normalization',NM) specifies the normalization scheme 
%   of the histogram values. The normalization scheme affects the scaling 
%   of the histogram along the Z axis. NM can be:
%                  'count'   The height of each bar is the number of 
%                            observations in each bin. The sum of the
%                            bar heights is generally equal to NUMEL(X) 
%                            and NUMEL(Y), but is less than if some 
%                            of the input data is not included in the bins..
%            'probability'   The height of each bar is the relative 
%                            number of observations (number of observations
%                            in bin / total number of observations), and
%                            the sum of the bar heights is less than or equal
%                            to 1.
%           'countdensity'   The height of each bar is, (the number of 
%                            observations in each bin) / (area of bin). The 
%                            volume (height * area) of each bar is the number
%                            of observations in the bin, and the sum of
%                            the bar volumes is less than or equal to NUMEL(X) 
%                            and NUMEL(Y).
%                    'pdf'   Probability density function estimate. The height 
%                            of each bar is, (number of observations in bin)
%                            / (total number of observations * area of bin).
%                            The volume of each bar is the relative number of
%                            observations, and the sum of the bar volumes 
%                            is less than or equal to 1.
%               'cumcount'   The height of each bar is the cumulative 
%                            number of observations in each bin and all
%                            previous bins in both the X and Y dimensions. 
%                            The height of the last bar is less than or equal 
%                            to NUMEL(X) and NUMEL(Y).
%                    'cdf'   Cumulative density function estimate. The height 
%                            of each bar is the cumulative relative number
%                            of observations in each bin and all previous 
%                            bins in both the X and Y dimensions. The height 
%                            of the last bar is less than or equal to 1.
%
%   HISTOGRAM2(...,'DisplayStyle',STYLE) specifies the display style of the 
%   histogram. STYLE can be:
%                   'bar3'   Display histogram using 3-D bars. This is the 
%                            default.
%                   'tile'   Display histogram as a rectangular array of 
%                            tiles with colors indicating the bin values.
%
%   HISTOGRAM2(...,'BinMethod',BM), uses the specified automatic binning 
%   algorithm to determine the number and width of the bins.  BM can be:
%                   'auto'   The default 'auto' algorithm chooses a bin 
%                            size to cover the data range and reveal the 
%                            shape of the underlying distribution.
%                  'scott'   Scott's rule is optimal if X and Y are close 
%                            to being jointly normally distributed, but 
%                            is also appropriate for most other 
%                            distributions. It uses a bin size of 
%                            [3.5*STD(X(:))*NUMEL(X)^(-1/4)
%                            3.5*STD(Y(:))*NUMEL(Y)^(-1/4)]
%                     'fd'   The Freedman-Diaconis rule is less sensitive to 
%                            outliers in the data, and may be more suitable 
%                            for data with heavy-tailed distributions. It 
%                            uses a bin size of [2*IQR(X(:))*NUMEL(X)^(-1/4) 
%                            2*IQR(Y(:))*NUMEL(Y)^(-1/4)] where IQR is the 
%                            interquartile range.
%               'integers'   The integer rule is useful with integer data, 
%                            as it creates a bin for each pair of integer 
%                            X and Y. It uses a bin width of 1 along each 
%                            dimension and places bin edges halfway 
%                            between integers. To prevent from accidentally 
%                            creating too many bins, a limit of 1024 bins 
%                            can be created along each dimension with this 
%                            rule. If the data range along either dimension 
%                            is greater than 1024, then larger bins are 
%                            used instead.
%
%   HISTOGRAM2(...,NAME,VALUE) set the property NAME to VALUE. 
%     
%   HISTOGRAM2('XBinEdges', XEDGES, 'YBinEdges', YEDGES, 'BinCounts', COUNTS) 
%   where COUNTS is a matrix of size [length(XEDGES)-1, length(YEDGES)-1],
%   manually specifies the bin counts. HISTOGRAM2 plots the counts and does 
%   not do any data binning.
%
%   HISTOGRAM2(AX,...) plots into AX instead of the current axes.
%       
%   H = HISTOGRAM2(...) also returns a Histogram2 object. Use this to 
%   inspect and adjust the properties of the histogram.
%
%   Class support for inputs X, Y, XEDGES, YEDGES:
%      float: double, single
%      integers: uint8, int8, uint16, int16, uint32, int32, uint64, int64
%      logical
%
%   See also HISTCOUNTS2, HISTCOUNTS, HISTOGRAM, DISCRETIZE,
%   matlab.graphics.chart.primitive.Histogram2

%   Copyright 1984-2017 The MathWorks, Inc.

import matlab.graphics.internal.*;
[cax,args] = axescheck(varargin{:});
% Check whether the first input is an axes input, which would have been
% stripped by the axescheck function
firstaxesinput = (rem(length(varargin) - length(args),2) == 1);
if length(args)>=2  && ~isCharOrString(args{1}) && ~isCharOrString(args{2})
    varxName = inputname(1+firstaxesinput);
    varyName = inputname(2+firstaxesinput);
else
    varxName = '';
    varyName = '';
end

[opts,args,vectorinput] = parseinput(args, firstaxesinput);

cax = newplot(cax);

[~,autocolor] = nextstyle(cax,true,false,false);
% lighten the autocolor
autocolor = hsv2rgb(min(rgb2hsv(autocolor).*[1 1 1.25],1));
optscell = binspec2cell(opts); 
hObj = matlab.graphics.chart.primitive.Histogram2('Parent', cax, ...
    'AutoColor', autocolor, optscell{:}, args{:});

% enable linking
hlink = hggetbehavior(hObj,'Linked');
hlink.DataSourceFcn = {@(hObj,data)set(hObj,'Data',[data{1}(:), data{2}(:)])};

hlink.UsesXDataSource = true;
hlink.UsesYDataSource = true;
% Only enable linking if the data is a vector and BinCounts not specified. 
% Brushing behavior is designed for vector data and does not work well 
% with matrix data
hasinputnames = ~isempty(varxName) && ~isempty(varyName); 
if hasinputnames && vectorinput && isempty(opts.BinCounts)
    hlink.XDataSource = varxName;
    hlink.YDataSource = varyName;
end
if isempty(get(hObj,'DisplayName')) && hasinputnames
    hObj.DisplayName = [varyName, ' vs. ' varxName];
end

% disable basic fit, and data statistics, but enable linked brushing
hlink.BrushFcn = {@localLinkedBrushFunc};
hlink.LinkBrushQueryFcn = {@(~,region,hObj)hObj.getBrushedElements(region);};
hlink.LinkBrushUpdateIFcn = {@(~,I,Iextend,~,extendMode,hObj)...
    hObj.updatePartiallyBrushedI(I,Iextend,extendMode);};
hlink.LinkBrushUpdateObjFcn = {@(~,region,lastregion,hObj)...
    hObj.updateBrushedGraphic(region,lastregion);};
hlink.Serialize = true;
hbrush = hggetbehavior(hObj,'brush');  
hbrush.Serialize = true;
hbrush.DrawFcn = {@localDrawFunc};
hdatadescriptor = hggetbehavior(hObj,'DataDescriptor');
hdatadescriptor.Enable = false;
hdatadescriptor.Serialize = true;

if ismember(cax.NextPlot, {'replace','replaceall'})
    cax.Box = 'on';
    grid(cax,'on');
    axis(cax,'tight');
end

if ~strcmp(hObj.DisplayStyle, 'tile') && ~strcmp(cax.NextPlot,'add')
    view(cax,3);
end

% If applying to a linked plot the linked plot graphics cache must
% be updated manually since there are not yet eventmanager listeners
% to do this automatically.
f = ancestor(hObj,'figure');
if ~isempty(f.findprop('LinkPlot')) && f.LinkPlot
    datamanager.updateLinkedGraphics(f);
end

if nargout > 0
    h = hObj;
end
end

function [opts,passthrough,isvectorinput] = parseinput(input, inputoffset)

import matlab.graphics.internal.*;
opts = struct('Data',[],'NumBins',[],'BinMethod','auto','BinWidth',[],...
    'XBinLimits',[],'YBinLimits',[],'XBinEdges',[],'YBinEdges',[],...
    'Normalization','','BinCounts',[]);
% mode properties variables for error checking
xbinlimitsmode = [];
ybinlimitsmode = [];
bincountsmode = [];
funcname = mfilename;
passthrough = {};
isvectorinput = false;

% Parse first and second inputs
if ~isempty(input)
    x = input{1};
    if ~isCharOrString(x)
        if isscalar(input)
            error(message('MATLAB:histogram2:MissingYInput'));
        end
        y = input{2};
        input(1:2) = [];
        validateattributes(x,{'numeric','logical'},{'real'}, funcname, ...
            'x', inputoffset+1)
        validateattributes(y,{'numeric','logical'},{'real','size',size(x)}, ...
            funcname, 'y', inputoffset+2)
        opts.Data = [x(:) y(:)];
        isvectorinput = isvector(x);
        inputoffset = inputoffset + 2;
    end

    % Parse third and fourth inputs in the function call
    if ~isempty(input)
        in = input{1};
        if ~isCharOrString(in)
            inputlen = length(input);
            if inputlen == 1 || ~(isnumeric(input{2}) || islogical(input{2}))
                if isscalar(in)
                    in = [in in];
                end
                validateattributes(in,{'numeric','logical'},{'integer', 'positive', ...
                    'numel', 2, 'vector'}, funcname, 'm', inputoffset+1)
                opts.NumBins = in;
                input(1) = [];
                inputoffset = inputoffset + 1;
            else
                in2 = input{2};
                validateattributes(in,{'numeric','logical'},{'vector', ...
                    'real', 'nondecreasing'}, funcname, 'xedges', inputoffset+1)
                if length(in) < 2
                    error(message('MATLAB:histogram2:EmptyOrScalarXBinEdges'));
                end
                validateattributes(in2,{'numeric','logical'},{'vector','nonempty', ...
                    'real', 'nondecreasing'}, funcname, 'yedges', inputoffset+2)
                if length(in2) < 2
                    error(message('MATLAB:histogram2:EmptyOrScalarYBinEdges'));
                end
                opts.XBinEdges = in;
                opts.YBinEdges = in2;
                input(1:2) = [];
                inputoffset = inputoffset + 2;
            end
            opts.BinMethod = [];
        end
        
        % All the rest are name-value pairs
        inputlen = length(input);
        if rem(inputlen,2) ~= 0
            error(message('MATLAB:histogram2:ArgNameValueMismatch'))
        end
        
        % compile the list of all settable property names, filtering out the
        % read-only properties
        names = setdiff(properties('matlab.graphics.chart.primitive.Histogram2'),...
            {'Children','Values','Type','Annotation','BeingDeleted'});
        
        for i = 1:2:inputlen
            name = validatestring(input{i},names);
            
            value = input{i+1};
            switch name
                case 'Data'
                    validateattributes(value,{'numeric','logical'},...
                        {'real','ncols',2}, funcname, 'Data', i+1+inputoffset)
                    opts.Data = value;
                case 'NumBins'
                    if isscalar(value)
                        value = [value value]; %#ok
                    end
                    validateattributes(value,{'numeric','logical'},{'integer',...
                        'positive','numel',2,'vector'}, funcname, 'NumBins', i+1+inputoffset)
                    opts.NumBins = value;
                    if ~isempty(opts.XBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedXBinInputs'))
                    elseif ~isempty(opts.YBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedYBinInputs'))
                    end
                    opts.BinMethod = [];
                    opts.BinWidth = [];
                case 'XBinEdges'
                    validateattributes(value,{'numeric','logical'},{'vector', ...
                        'real', 'nondecreasing'}, funcname, 'XBinEdges', i+1+inputoffset);
                    if length(value) < 2
                        error(message('MATLAB:histogram2:EmptyOrScalarXBinEdges'));
                    end
                    opts.XBinEdges = value;
                    % Only set NumBins field to empty if both XBinEdges and
                    % YBinEdges are set, to enable BinEdges override of one
                    % dimension
                    if ~isempty(opts.YBinEdges)
                        opts.NumBins = [];
                        opts.BinMethod = [];
                        opts.BinWidth = [];
                    end
                    opts.XBinLimits = [];
                case 'YBinEdges'
                    validateattributes(value,{'numeric','logical'},{'vector', ...
                        'real', 'nondecreasing'}, funcname, 'YBinEdges', i+1+inputoffset);
                    if length(value) < 2
                        error(message('MATLAB:histogram2:EmptyOrScalarYBinEdges'));
                    end
                    opts.YBinEdges = value;
                    % Only set NumBins field to empty if both XBinEdges and
                    % YBinEdges are set, to enable BinEdges override of one
                    % dimension
                    if ~isempty(opts.XBinEdges)
                        opts.BinMethod = [];
                        opts.BinWidth = [];
                        opts.NumBins = [];
                    end
                    opts.YBinLimits = [];
                case 'BinWidth'
                    if isscalar(value)
                        value = [value value]; %#ok
                    end
                    validateattributes(value, {'numeric','logical'}, {'real',...
                        'positive', 'finite','numel',2, 'vector'}, funcname, ...
                        'BinWidth', i+1+inputoffset);
                    opts.BinWidth = value;
                    if ~isempty(opts.XBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedXBinInputs'))
                    elseif ~isempty(opts.YBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedYBinInputs'))
                    end
                    opts.BinMethod = [];
                    opts.NumBins = [];
                case 'XBinLimits'
                    validateattributes(value, {'numeric','logical'}, {'numel', 2, 'vector', ...
                        'real', 'finite','nondecreasing'}, funcname, 'XBinLimits', ...
                        i+1+inputoffset)
                    opts.XBinLimits = value;
                    if ~isempty(opts.XBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedXBinInputs'))
                    end
                case 'YBinLimits'
                    validateattributes(value, {'numeric','logical'}, {'numel', 2, 'vector',...
                        'real', 'finite','nondecreasing'}, funcname, 'YBinLimits', ...
                        i+1+inputoffset)
                    opts.YBinLimits = value;
                    if ~isempty(opts.YBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedYBinInputs'))
                    end
                case 'BinMethod'
                    opts.BinMethod = validatestring(value, {'auto','scott', 'fd', ...
                        'integers'}, funcname, 'BinMethod', i+1+inputoffset);
                    if ~isempty(opts.XBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedXBinInputs'))
                    elseif ~isempty(opts.YBinEdges)
                        error(message('MATLAB:histogram2:InvalidMixedYBinInputs'))
                    end
                    opts.BinWidth = [];
                    opts.NumBins = [];
                case 'Normalization'
                    opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                        'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+1+inputoffset);
                case 'BinCounts'
                    validateattributes(value,{'numeric','logical'},{'real', ...
                        '2d','nonnegative','finite'}, funcname, 'BinCounts', i+1+inputoffset)
                    opts.BinCounts = value;
                case 'XBinLimitsMode'
                    xbinlimitsmode = validatestring(value, {'auto', 'manual'});
                case 'YBinLimitsMode'
                    ybinlimitsmode = validatestring(value, {'auto', 'manual'});
                case 'BinCountsMode'
                    bincountsmode = validatestring(value, {'auto', 'manual'});
                otherwise
                    % all other options are passed directly to the object
                    % constructor, making sure we pass in the full property names
                    passthrough = [passthrough {name} input(i+1)]; %#ok<AGROW>
            end
        end
        % error checking about consistency between properties
        if ~isempty(xbinlimitsmode)
            if strcmp(xbinlimitsmode, 'auto')
                if ~isempty(opts.XBinEdges) || ~isempty(opts.XBinLimits)
                    error(message('MATLAB:histogram2:NonEmptyXBinLimitsAutoMode'));
                end
            else  % manual
                if isempty(opts.XBinEdges) && isempty(opts.XBinLimits)
                    error(message('MATLAB:histogram2:EmptyXBinLimitsManualMode'));
                end
            end
            passthrough = [passthrough {'XBinLimitsMode' xbinlimitsmode}];
        end
        if ~isempty(ybinlimitsmode)
            if strcmp(ybinlimitsmode, 'auto')
                if ~isempty(opts.YBinEdges) || ~isempty(opts.YBinLimits)
                    error(message('MATLAB:histogram2:NonEmptyYBinLimitsAutoMode'));
                end
            else  % manual
                if isempty(opts.YBinEdges) && isempty(opts.YBinLimits)
                    error(message('MATLAB:histogram2:EmptyYBinLimitsManualMode'));
                end
            end
            passthrough = [passthrough {'YBinLimitsMode' ybinlimitsmode}];
        end
        if ~isempty(bincountsmode)
            if strcmp(bincountsmode, 'auto')
                if ~isempty(opts.BinCounts)
                    error(message('MATLAB:histogram2:NonEmptyBinCountsAutoMode'));
                end
            else  % manual
                if isempty(opts.BinCounts)
                    error(message('MATLAB:histogram2:EmptyBinCountsManualMode'));
                end
            end
            passthrough = [passthrough {'BinCountsMode' bincountsmode}];            
        end
        if ~isempty(opts.BinCounts)
            if (length(opts.XBinEdges) ~= size(opts.BinCounts,1)+1 || ...
                length(opts.YBinEdges) ~= size(opts.BinCounts,2)+1)
                error(message('MATLAB:histogram2:BinCountsInvalidSize'))
            end
            if ~isempty(opts.Data)
                error(message('MATLAB:histogram2:MixedDataBinCounts'))
            end
        end
    end
end
end

function binargs = binspec2cell(binspec)
% Construct a cell array of name-value pairs given a binspec struct
binspecn = fieldnames(binspec);  % extract field names
empties = structfun(@isempty,binspec);
binspec = rmfield(binspec,binspecn(empties));  % remove empty fields
binspecn = binspecn(~empties);
binspecv = struct2cell(binspec);
binargs = [binspecn binspecv]';
end

function brushStruct = localLinkedBrushFunc(I, hObj)

% Linked behavior object BrushFcn

% Converts variable brushing arrays (arrays of uint8 the same size as a 
% linked variable which define which subset of that variable is brushed and
% in which color) into generalized brushing data (the generalized form of 
% the BrushData property used by the brush behavior object). For histograms, 
% generalized brushing data is a struct with a field I representing the 
% height of each brushed bin and an index ColorIndex into the figure  
% BrushStyleMap representing the brushing color.

xbinedges = hObj.XBinEdges;
ybinedges = hObj.YBinEdges;
if ~isvector(I) && ~isempty(I) 
    I = I(:,1);
end
Iout = histcounts2(hObj.Data(logical(I),1), hObj.Data(logical(I),2), xbinedges, ybinedges);
if hObj.Brushed && any(strcmp(hObj.Normalization, {'cumcount', 'cdf'}))
    % Special code for brushing cumulative histograms, highlight the entire
    % bar
    Iout = hObj.Values .* sign(Iout);
else
    switch hObj.Normalization
        case 'countdensity'
            binarea = bsxfun(@times,double(diff(xbinedges.')),...
                double(diff(ybinedges)));
            Iout = Iout./binarea;
        case 'cumcount'
            Iout = cumsum(cumsum(Iout,1),2);
        case 'probability'
            total = sum(all(bsxfun(@ge, hObj.Data, ...
                [hObj.XBinLimits(1) hObj.YBinLimits(1)]),2) & ...
                all(bsxfun(@le, hObj.Data, [hObj.XBinLimits(2) hObj.YBinLimits(2)]),2));
            Iout = Iout/total;
        case 'pdf'
            total = sum(all(bsxfun(@ge, hObj.Data, ...
                [hObj.XBinLimits(1) hObj.YBinLimits(1)]),2) & ...
                all(bsxfun(@le, hObj.Data, [hObj.XBinLimits(2) hObj.YBinLimits(2)]),2));
            binarea = bsxfun(@times,double(diff(xbinedges.')),...
                double(diff(ybinedges)));
            Iout = Iout/total./binarea;
        case 'cdf'
            total = sum(all(bsxfun(@ge, hObj.Data, ...
                [hObj.XBinLimits(1) hObj.YBinLimits(1)]),2) & ...
                all(bsxfun(@le, hObj.Data ,[hObj.XBinLimits(2) hObj.YBinLimits(2)]),2));
            Iout = cumsum(cumsum(Iout/total,1),2);
    end
end
[~,~,brushStyleMapInd] = find(I,1); 
brushStruct = struct('I',Iout,'ColorIndex',brushStyleMapInd);
end

function localDrawFunc(brushStruct,hObj)
% Uses a struct with fields I and ColorIndex to set the BrushColor and BrushValues
% properties of the histogram object
if ~isempty(brushStruct)
    if hObj.Brushed && any(strcmp(hObj.Normalization, {'cumcount', 'cdf'}))
        % only write to non-zero bins, to avoid overwriting brushed empty
        % cumulative bins
        nonzeroI = brushStruct.I > 0;
        hObj.BrushValues(nonzeroI) = brushStruct.I(nonzeroI);
    else
        hObj.BrushValues = brushStruct.I;
    end
    if isfield(brushStruct, 'ColorIndex') && ~isempty(brushStruct.ColorIndex)
        fig = ancestor(hObj,'figure');
        brushStyleMap = get(fig,'BrushStyleMap');
        hObj.BrushColor = brushStyleMap(rem(brushStruct.ColorIndex-1,...
            size(brushStyleMap,1))+1,:);
    end
end
end
