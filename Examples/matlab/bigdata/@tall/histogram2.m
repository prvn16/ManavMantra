function h = histogram2(varargin)
%HISTOGRAM2  Plots a bivariate histogram.
%
%   Supported syntaxes for tall X and tall Y:
%   HISTOGRAM2(X,Y)
%   HISTOGRAM2(X,Y,NBINS)
%   HISTOGRAM2(X,Y,XEDGES,YEDGES)
%   HISTOGRAM2(...,'BinWidth',BW)
%   HISTOGRAM2(...,'XBinLimits',[XBMIN,XBMAX])
%   HISTOGRAM2(...,'YBinLimits',[YBMIN,YBMAX])
%   HISTOGRAM2(...,'Normalization',NM)
%   HISTOGRAM2(...,'DisplayStyle',STYLE)
%   HISTOGRAM2(...,'BinMethod',BM) - BM can be 'auto' (default),
%               'scott','integers'
%   HISTOGRAM2(...,NAME,VALUE) set the property NAME to VALUE. NAME can be
%               'EdgeAlpha','EdgeColor','FaceAlpha','FaceColor',...
%               'FaceLighting','LineStyle','LineWidth','ShowEmptyBins'
%   HISTOGRAM2(AX,...) plots into AX instead of the current axes
%   H = HISTOGRAM2(...) also returns a Histogram2 object.
%
%     See also HISTOGRAM2

%   Copyright 2016 The MathWorks, Inc.

[cax,args] = matlab.bigdata.internal.util.axesCheck(varargin{:});
narginchk(2,inf);
x = args{1};
y = args{2};
args(1:2) = [];

validateattributes(x,{'tall'},{'real'});
validateattributes(y,{'tall'},{'real'}); % size(x) ?
x  = tall.validateType(x,mfilename,{'numeric','logical'},1);
y  = tall.validateType(y,mfilename,{'numeric','logical'},2);

idx = any(isfinite(x) & isfinite(y),2);
x = filterslices(idx,x);
y = filterslices(idx,y);

opts = parseinput(args);

if ~isempty(opts.XBinEdges) && ~isempty(opts.YBinEdges)
    xedges = opts.XBinEdges(:)';
    yedges = opts.YBinEdges(:)';
elseif isempty(opts.BinMethod)
    z = [x,y];
    minz = min(z,[],1,'omitnan');
    maxz = max(z,[],1,'omitnan');
    [minz,maxz] = gather(minz,maxz);
    if size(minz,2)~=2
        error(message('MATLAB:bigdata:array:BadHistogram2XY'));
    end
    histcount2Opts = {'NumBins',opts.NumBins,'XBinEdges',opts.XBinEdges,...
        'YBinEdges',opts.YBinEdges,'BinWidth',opts.BinWidth,...
        'XBinLimits',opts.XBinLimits,'YBinLimits',opts.YBinLimits,...
        'Normalization',opts.Normalization};
    idx = find(cellfun(@isempty,histcount2Opts));
    idx = [idx,idx-1];
    histcount2Opts(idx) = [];
    [~,xedges,yedges] = histcounts2([minz(1),maxz(1)],[minz(2),maxz(2)],histcount2Opts{:});
else
    X_PreferIntegersRule = lazyCheckAutoRulePreferIntegersRule(x);
    Y_PreferIntegersRule = lazyCheckAutoRulePreferIntegersRule(y);
    
    if ~isempty(opts.XBinLimits)
        if ~isfloat(opts.XBinLimits)
            % for integers, the edges are doubles
            minlimx = double(opts.XBinLimits(1));
            maxlimx = double(opts.XBinLimits(2));
        else
            minlimx = opts.XBinLimits(1);
            maxlimx = opts.XBinLimits(2);
        end
        inrangex = x>=minlimx & x<=maxlimx;
        if ~isempty(opts.YBinLimits)
            inrangex = inrangex & y>=opts.YBinLimits(1) & y<=opts.YBinLimits(2);
        end
        xc = filterslices(inrangex, x);
        xhardlimits = true;
    else
        xc = x;
        xhardlimits = false;
    end
    if ~isempty(opts.YBinLimits)
        if ~isfloat(opts.YBinLimits)
            minlimy = double(opts.YBinLimits(1));
            maxlimy = double(opts.YBinLimits(2));
        else
            minlimy = opts.YBinLimits(1);
            maxlimy = opts.YBinLimits(2);
        end
        inrangey = y>=minlimy & y<=maxlimy;
        if ~isempty(opts.XBinLimits)
            inrangey = inrangey & x>=opts.XBinLimits(1) & x<=opts.XBinLimits(2);
        end
        yc = filterslices(inrangey, y);
        yhardlimits = true;
    else
        yc = y;
        yhardlimits = false;
    end
    
    [minx,maxx,stdx,nx,rangex,xscale] = iVecStats(xc);
    [miny,maxy,stdy,ny,rangey,yscale] = iVecStats(yc);
    [minx,maxx,stdx,nx,rangex,xscale,miny,maxy,stdy,ny,rangey,yscale,X_PreferIntegersRule,Y_PreferIntegersRule] = ...
        gather(minx,maxx,stdx,nx,rangex,xscale,miny,maxy,stdy,ny,rangey,yscale,X_PreferIntegersRule,Y_PreferIntegersRule);
    if size(minx,2)~=1 ||  size(miny,2)~=1
        error(message('MATLAB:bigdata:array:BadHistogram2XY'));
    end
    
    if isempty(opts.XBinLimits)
        minlimx = minx;
        maxlimx = maxx;
    end
    if isempty(opts.YBinLimits)
        minlimy = miny;
        maxlimy = maxy;
    end
    
    if strcmpi(opts.BinMethod,'auto')
        if isempty(opts.XBinEdges)
            if ~isempty([minx, maxx]) && X_PreferIntegersRule...
                    && rangex <= 50 && maxx <= flintmax(class(maxx))/2 ...
                    && minx >= -flintmax(class(minx))/2
                xedges = integerrule(rangex,xscale,minlimx,maxlimx,xhardlimits,getmaxnumbins());
            else
                xedges = scottsrule(minx, maxx, minlimx, maxlimx, stdx, nx, xhardlimits);
            end
            if length(xedges) > 101
                numbins = 100;
                if ~xhardlimits
                    xedges = matlab.internal.math.binpicker(minlimx,maxlimx,numbins,rangex/numbins);
                else
                    xedges = matlab.internal.math.binpickerbl(minx,maxx,minlimx,maxlimx,rangex/numbins);
                end
            end
        else
            xedges = opts.XBinEdges(:)';
        end
        if isempty(opts.YBinEdges)  
            if ~isempty([miny, maxy]) && Y_PreferIntegersRule...
                    && rangey <= 50 && maxy <= flintmax(class(maxy))/2 ...
                    && miny >= -flintmax(class(miny))/2
                yedges = integerrule(rangey,yscale,minlimy,maxlimy,yhardlimits,getmaxnumbins());
            else
                yedges = scottsrule(miny, maxy, minlimy, maxlimy, stdy, ny, yhardlimits);
            end
            if length(yedges) > 101
                numbins = 100;
                if ~yhardlimits
                    yedges = matlab.internal.math.binpicker(minlimy,maxlimy,numbins,rangey/numbins);
                else
                    yedges = matlab.internal.math.binpickerbl(miny,maxy,minlimy,maxlimy,rangey/numbins);
                end
            end
        else
            yedges = opts.YBinEdges(:)';
        end
    elseif strcmpi(opts.BinMethod,'scott')
        xedges = scottsrule(minx, maxx, minlimx, maxlimx, stdx, nx, xhardlimits);
        yedges = scottsrule(miny, maxy, minlimy, maxlimy, stdy, ny, yhardlimits);
    else % 'integers'    
        xedges = integerrule(rangex,xscale,minlimx,maxlimx,xhardlimits,getmaxnumbins());
        yedges = integerrule(rangey,yscale,minlimy,maxlimy,yhardlimits,getmaxnumbins());
    end
end

xedges = full(xedges);
yedges = full(yedges);

goodIndex = any(~isnan(x)&~isnan(y),2);
x = filterslices(goodIndex,x);
y = filterslices(goodIndex,y);
aggfun = @(x,y) histogramMapper(x,y,xedges,yedges);
redfun = @(x) histogramReducer(x);
count = aggregatefun(aggfun,redfun,x,y);
count = gather(count);
count = reshape(count,length(xedges)-1,length(yedges)-1);

if isempty(opts.FaceColor)
    if strcmpi(opts.DisplayStyle,'tile')
        opts.FaceColor = 'flat';
    else
        opts.FaceColor = 'auto';
    end
end
if isempty(opts.FaceLighting)
    if strcmpi(opts.DisplayStyle,'tile')
        opts.FaceLighting = 'none';
    else
        opts.FaceLighting = 'lit';
    end
end
% Do not display edges if too many bins
if (numel(xedges)-1)*(numel(yedges)-1) > 2000
    opts.EdgeColor = 'none';
end

cax = newplot(cax);
h1 = histogram2(cax,'XBinEdges',xedges,'YBinEdges',yedges,'BinCounts',count,...
    'DisplayStyle',opts.DisplayStyle,'Normalization',opts.Normalization,...
    'EdgeAlpha',opts.EdgeAlpha,'EdgeColor',opts.EdgeColor,...
    'FaceAlpha',opts.FaceAlpha,'FaceColor',opts.FaceColor,...
    'FaceLighting',opts.FaceLighting,'LineStyle',opts.LineStyle,...
    'LineWidth',opts.LineWidth,'ShowEmptyBins',opts.ShowEmptyBins);

if nargout > 0
    h = h1;
end

end

function count = histogramMapper(x,y,xedges,yedges)
if size(x,2)~=1 || size(y,2)~=1
    error(message('MATLAB:bigdata:array:BadHistogram2XY'));
end
count = histcounts2(x,y,xedges,yedges);
count = count(:)';
end

function count = histogramReducer(count)
count = sum(count,1);
end

function opts = parseinput(input)

opts = struct('NumBins',[],'XBinEdges',[],'YBinEdges',[],'XBinLimits',[],...
    'YBinLimits',[],'BinWidth',[],'Normalization','count','BinMethod','auto',...
    'DisplayStyle','bar3','EdgeAlpha',1,'EdgeColor',[0.15 0.15 0.15],...
    'FaceAlpha',1,'FaceColor',[],'FaceLighting','','LineStyle','-',...
    'LineWidth',0.5,'ShowEmptyBins','off');
funcname = mfilename;

% Parse third and fourth input in the function call
inputlen = length(input);
if inputlen > 0
    in = input{1};
    inputoffset = 0;
    if isnumeric(in) || islogical(in)
        if inputlen == 1 || ~(isnumeric(input{2}) || islogical(input{2}))
            % Numbins
            if isscalar(in)
                in = [in in];
            end
            validateattributes(in,{'numeric','logical'},{'integer', 'positive', ...
                'numel', 2, 'vector'}, funcname, 'm', inputoffset+3)
            opts.NumBins = in;
            input(1) = [];
            inputoffset = inputoffset + 1;
        else
            % XBinEdges and YBinEdges
            in2 = input{2};
            validateattributes(in,{'numeric','logical'},{'vector', ...
                'real', 'nondecreasing'}, funcname, 'xedges', inputoffset+3)
            if length(in) < 2
                error(message('MATLAB:histcounts2:EmptyOrScalarXBinEdges'));
            end
            validateattributes(in2,{'numeric','logical'},{'vector', ...
                'real', 'nondecreasing'}, funcname, 'yedges', inputoffset+4)
            if length(in2) < 2
                error(message('MATLAB:histcounts2:EmptyOrScalarYBinEdges'));
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
        error(message('MATLAB:histcounts2:ArgNameValueMismatch'))
    end
    
    for i = 1:2:inputlen
        name = validatestring(input{i}, {'NumBins', 'XBinEdges', ...
            'YBinEdges','BinWidth', 'BinMethod', 'XBinLimits', ...
            'YBinLimits','Normalization','DisplayStyle','EdgeAlpha',...
            'EdgeColor','FaceAlpha','FaceColor','FaceLighting',...
            'LineStyle','LineWidth','ShowEmptyBins'}, i+2+inputoffset);
        
        value = input{i+1};
        switch name
            case 'NumBins'
                if isscalar(value)
                    value = [value value]; %#ok
                end
                validateattributes(value,{'numeric','logical'},{'integer', ...
                    'positive', 'numel', 2, 'vector'}, funcname, 'NumBins', i+3+inputoffset)
                opts.NumBins = value;
                if ~isempty(opts.XBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
                elseif ~isempty(opts.YBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
                end
                opts.BinMethod = [];
                opts.BinWidth = [];
            case 'XBinEdges'
                validateattributes(value,{'numeric','logical'},{'vector', ...
                    'real', 'nondecreasing'}, funcname, 'XBinEdges', i+3+inputoffset);
                if length(value) < 2
                    error(message('MATLAB:histcounts2:EmptyOrScalarXBinEdges'));
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
                    'real', 'nondecreasing'}, funcname, 'YBinEdges', i+3+inputoffset);
                if length(value) < 2
                    error(message('MATLAB:histcounts2:EmptyOrScalarYBinEdges'));
                end
                opts.YBinEdges = value;
                % Only set NumBins field to empty if both XBinEdges and
                % YBinEdges are set, to enable BinEdges override of one
                % dimension
                if ~isempty(opts.XBinEdges)
                    opts.BinMethod = [];
                    opts.NumBins = [];
                    %opts.BinLimits = [];
                    opts.BinWidth = [];
                end
                opts.YBinLimits = [];
            case 'BinWidth'
                if isscalar(value)
                    value = [value value]; %#ok
                end
                validateattributes(value, {'numeric','logical'}, {'real', 'positive',...
                    'finite','numel',2,'vector'}, funcname, ...
                    'BinWidth', i+3+inputoffset);
                opts.BinWidth = value;
                if ~isempty(opts.XBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
                elseif ~isempty(opts.YBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
                end
                opts.BinMethod = [];
                opts.NumBins = [];
            case 'BinMethod'
                opts.BinMethod = validatestring(value, {'auto','scott',...
                    'integers'}, funcname, 'BinMethod', i+3+inputoffset);
                if ~isempty(opts.XBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
                elseif ~isempty(opts.YBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
                end
                opts.BinWidth = [];
                opts.NumBins = [];
            case 'XBinLimits'
                validateattributes(value, {'numeric','logical'}, {'numel', 2, ...
                    'vector', 'real', 'finite','nondecreasing'}, funcname, ...
                    'XBinLimits', i+3+inputoffset)
                opts.XBinLimits = value;
                if ~isempty(opts.XBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedXBinInputs'))
                end
            case 'YBinLimits'
                validateattributes(value, {'numeric','logical'}, {'numel', 2, ...
                    'vector', 'real', 'finite','nondecreasing'}, funcname, ...
                    'YBinLimits', i+3+inputoffset)
                opts.YBinLimits = value;
                if ~isempty(opts.YBinEdges)
                    error(message('MATLAB:histcounts2:InvalidMixedYBinInputs'))
                end
            case 'Normalization'
                opts.Normalization = validatestring(value, {'count', 'countdensity', 'cumcount',...
                    'probability', 'pdf', 'cdf'}, funcname, 'Normalization', i+3+inputoffset);
            case 'DisplayStyle'
                opts.DisplayStyle = validatestring(value, {'bar3','tile'},...
                    funcname, 'DisplayStyle', i+3+inputoffset);
            case 'EdgeAlpha'
                validateattributes(value,{'numeric'},{'scalar','<=',1,'nonnegative'},...
                    funcname,'EdgeAlpha',i+3+inputoffset);
                opts.EdgeAlpha = value;
            case 'EdgeColor'
                try
                    opts.EdgeColor = hgcastvalue('matlab.graphics.datatype.RGBAutoNoneColor',value);
                catch
                    error(message('MATLAB:bigdata:array:BadEdgeColor'))
                end
            case 'FaceAlpha'
                validateattributes(value,{'numeric'},{'scalar','<=',1,'nonnegative'},...
                    funcname,'FaceAlpha',i+3+inputoffset);
                opts.FaceAlpha = value;
            case 'FaceColor'
                try
                    opts.FaceColor = hgcastvalue('matlab.graphics.datatype.RGBAutoNoneColor',value);
                catch
                    if strncmpi(value, 'flat', numel(value))
                        opts.FaceColor = 'flat';
                    else
                        error(message('MATLAB:bigdata:array:BadFaceColor'))
                    end
                end
            case 'FaceLighting'
                opts.FaceLighting = validatestring(value, {'lit','flat','none'},...
                    funcname, 'FaceLighting', i+3+inputoffset);
            case 'LineStyle'
                opts.LineStyle = validatestring(value, {'-','--',':','-.','none'},...
                    funcname, 'LineStyle', i+3+inputoffset);
            case 'LineWidth'
                validateattributes(value,{'numeric','logical'},{'scalar', ...
                    'positive'}, funcname, 'LineWidth', i+3+inputoffset);
                opts.LineWidth = value;
            case 'ShowEmptyBins'
                opts.ShowEmptyBins = validatestring(value, {'on','off'},...
                    funcname, 'ShowEmptyBins', i+3+inputoffset);
        end
    end
end
end

function mb = getmaxnumbins
mb = 1024;
end

function edges = scottsrule(minx, maxx, minlim, maxlim, stdx, n, hardlimits)
% Scott's normal reference rule
binwidth = 3.5*stdx/n^(1/4);
if ~hardlimits
    edges = matlab.internal.math.binpicker(minlim,maxlim,[],binwidth);
else
    edges = matlab.internal.math.binpickerbl(minx,maxx,minlim,maxlim,binwidth);
end
end

function edges = integerrule(rangex, xscale, minx, maxx, hardlimits, maximumbins)
if ~isempty(maxx) && (maxx > flintmax(class(maxx))/2 || ...
        minx < -flintmax(class(minx))/2)
    name = 'histcounts2';
    m = message(['MATLAB:' name ':InputOutOfIntRange']);
    throwAsCaller(MException(m.Identifier,'%s',getString(m)));
end
if ~isempty(xscale)
    assert(eps(xscale) <= 1, ...
        'Should never be able to call integerrule with eps(xscale)>1 (i.e. xscale>flintmax)')
    xrange = rangex;
    if xrange > maximumbins
        % If there'd be more than maximum bins, center them on an appropriate
        % power of 10 instead.
        binwidth = 10^ceil(log10(xrange/maximumbins));
    else
        % Otherwise bins are centered on integers.
        binwidth = 1;
    end
    if ~hardlimits
        minx = binwidth*round(minx/binwidth); % make the edges bin width multiples
        maxx = binwidth*round(maxx/binwidth);
        edges = (floor(minx)-.5*binwidth):binwidth:(ceil(maxx)+.5*binwidth);
    else
        minxi = binwidth*ceil(minx/binwidth)+0.5;
        maxxi = binwidth*floor(maxx/binwidth)-0.5;
        edges = [minx minxi:binwidth:maxxi maxx];
    end
else
    xrange = maxx-minx;
    if ~hardlimits
        edges = cast([-0.5 0.5], 'like', xrange);
    else
        minxi = ceil(minx)+0.5;
        maxxi = floor(maxx)-0.5;
        edges = [minx minxi:maxxi maxx];
    end
end
end

function [minx,maxx,stdx,nx,rangex,xscale] = iVecStats(x)
% Calculate basic statistics about a vector
if ~isfloat(x)
    x = double(x);
end
minx = min(x,[],1,'omitnan');
maxx = max(x,[],1,'omitnan');
stdx = std(x,0,1,'omitnan');
nx = sum(~isnan(x),1);
rangex = maxx - minx;
xscale = max(abs(x),[],1,'omitnan');
end

function preferIntRule = lazyCheckAutoRulePreferIntegersRule(tX)
classCheckFcn = @(cX) ~ismember(cX, {'single', 'double'});
hasCorrectClass = clientfun(classCheckFcn, classUnderlying(tX));
roundsToInt = aggregatefun(@(x) isequal(x, round(x)), @all, tX);
preferIntRule = clientfun(@(a,b) (a||b), hasCorrectClass, roundsToInt);
end
