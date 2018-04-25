function hh = bar(varargin)
%BAR Bar graph.
%   BAR(X,Y) draws the columns of the M-by-N matrix Y as M groups of N
%   vertical bars.  The vector X must not have duplicate values.
%
%   BAR(Y) uses the default value of X=1:M.  For vector inputs, BAR(X,Y)
%   or BAR(Y) draws LENGTH(Y) bars.  The colors are set by the colormap.
%
%   BAR(X,Y,WIDTH) or BAR(Y,WIDTH) specifies the width of the bars. Values
%   of WIDTH > 1, produce overlapped bars.  The default value is WIDTH=0.8
%
%   BAR(...,'grouped') produces the default vertical grouped bar chart.
%
%   BAR(...,'stacked') produces a vertical stacked bar chart.
%
%   BAR(...,COLOR) uses the line color specified.  Specify the color as one of
%   these values: 'r', 'g', 'b', 'y', 'm', 'c', 'k', or 'w'.
%
%   BAR(AX,...) plots into AX instead of GCA.
%
%   H = BAR(...) returns a vector of handles to barseries objects.
%
%   Examples: subplot(3,1,1), bar(rand(10,5),'stacked'), colormap(cool)
%             subplot(3,1,2), bar(0:.25:1,rand(5),1)
%             subplot(3,1,3), bar(rand(2,3),.75,'grouped')
%
%   See also HISTOGRAM, PLOT, BARH, BAR3, BAR3H.

%   C.B Moler 2-06-86
%   Copyright 1984-2017 The MathWorks, Inc.

[~, hPar, args] = parseplotapi(varargin{:},'-mfilename',mfilename);


% First, we need to extract the P/V pairs
reservedWords = {'grouped','stacked','hist','histc'};
[numArgs, pvPairs] = extractPVPairs(args,reservedWords);

% We can only have up to five non-P/V arguments - x,y,width,style,color
if numArgs < 1
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif numArgs > 5
    error(message('MATLAB:narginchk:tooManyInputs'));
end
args = args(1:numArgs);
pvPairs = matlab.graphics.internal.convertStringToCharArgs(pvPairs);

% Peel off Horizontal property to be used in the constructor if given.  If
% not given, we'll use the default value.  ishorizontal is set to false
% initially in case we need to go through the hist or histc options and the
% horizontal pv pair isn't given.
ishorizontal = false; 
useDefaultHorizontal = true;
i = 1;
while i < numel(pvPairs)
    if numel(pvPairs{i}) > 1 && startsWith('Horizontal_I',pvPairs{i})
        if strcmpi(pvPairs{i+1},'on')
            horizontal_val = 'on';
            ishorizontal = true;
            useDefaultHorizontal = false;
        elseif strcmpi(pvPairs{i+1},'off')
            horizontal_val = 'off';
            ishorizontal = false;
            useDefaultHorizontal = false;
        else % let Bar constructor error
            useDefaultHorizontal = false;
        end
        % Strip horizontal pv pair from pvPairs
        pvPairs = {pvPairs{1:i-1} pvPairs{i+2:end}};
    else
        i = i+2;
    end
end

% Working backwards, take care of string arguments:
while matlab.graphics.internal.isCharOrString(args{numArgs}) && (numArgs > 1)
    args{numArgs} = char(args{numArgs});
    if any(strcmpi(args{numArgs}(1:min(4,length(args{numArgs}))),{'grou','stac'}))
        %grouped or stacked property specified
        pvPairs(end+1:end+2) = {'BarLayout',args{numArgs}};
    elseif any(strcmpi(args{numArgs},{'hist','histc'}))
        % We are going through the hist command
        if ishorizontal
            h = barhV6(hPar,args{:});
        else
            h = barV6(hPar,args{:});
        end
        if nargout>0, hh = h; end       
        return;
    else % We have a linespec
        [l,c,m,msg] = colstyle(args{numArgs},'plot');
        if ~isempty(l) || ~isempty(m) || ~isempty(msg)
            error(message('MATLAB:bar:UnrecognizedOption',args{numArgs}));
        end
        if ~isempty(c)
            pvPairs(end+1:end+2) = {'FaceColor',c}; %Note FaceColor, not Color
        end
    end
    numArgs = numArgs-1;
    args(end) = [];
end

% Check to see if we have a width input argument:
if numArgs == 3
    if isscalar(args{3})
        pvPairs(end+1:end+2) = {'BarWidth',args{3}};
        numArgs = numArgs-1;
        args(end) = [];
    else
        error(message('MATLAB:narginchk:tooManyInputs'));
    end
elseif numArgs == 2
    if isnumeric(args{2}) && isscalar(args{2}) && ~isscalar(args{1})
        % We have a width argument
        pvPairs(end+1:end+2) = {'BarWidth',args{2}};
        numArgs = numArgs-1;
        args(end) = [];
    end
elseif numArgs > 3
    error(message('MATLAB:narginchk:tooManyInputs'));
end

isXDataModeAuto = false;

% get the real component if data is complex
allowNonNumeric = true;
args = getRealData(args,allowNonNumeric);

if numArgs == 1 % bar(y)
    % We have a matrix as input. In this case, each column will be a distinct
    % Bar object.
    y = args{1};
    % Make sure y is full
    if isnumeric(y)
        y = full(y);
    end
    if ~ismatrix(y)
        error(message('MATLAB:xychk:non2DInput'));
    end
    isXDataModeAuto = true;
    if isvector(y)
        y = y(:);
    end
else % bar(x,y)
    x = args{1};
    y = args{2};
    % Make sure x and y are full
    if isnumeric(x)
        x = full(x);
    end
    if isnumeric(y)
        y = full(y);
    end
    if ~ismatrix(x) || ~ismatrix(y)
        error(message('MATLAB:xychk:non2DInput'));
    end
    isVectorY = isvector(y);
    isVectorX = isvector(x);
    if isVectorY
        y = y(:);
    end
    if isVectorX
        x = x(:);
    end
    if isVectorX 
        if ~isVectorY
            if numel(x) ~= size(y,1)
                error(message('MATLAB:xychk:lengthXDoesNotMatchNumRowsY'));
            end
        else
            if numel(x) ~= numel(y)
                error(message('MATLAB:xychk:XAndYLengthMismatch'));
            end
        end
        % Expand x to be the same size as y
        x = repmat(x,1,size(y,2));
    else
        if ~isequal(size(x),size(y))
            error(message('MATLAB:xychk:XAndYSizeMismatch'));
        end
    end
end
if isa(y,'datetime') || isa(y,'categorical')
    error(message('MATLAB:specgraph:private:specgraph:DatetimeDependent'));
end

if ~isXDataModeAuto
    if length(x)>1
        sortedx = sort(x);
        if any(any(sortedx(2:end,:) == sortedx(1:end-1,:)))
            error(message('MATLAB:bar:DuplicateXValue'));
        end
    end
end

[~, numSeries] = size(y);

if ~isempty(hPar) && ~ishghandle(hPar,'axes')
    hAx = ancestor(hPar,'axes');
    if isequal(hPar,hAx)
        hPar = newplot(hPar);
    end
else
    hPar = newplot(hPar);
    hAx = hPar;
end

if isXDataModeAuto
    x = [];
end

if ishorizontal
    matlab.graphics.internal.configureAxes(hAx,y,x);
    [y,x] = matlab.graphics.internal.makeNumeric(hAx,y,x);
else
    matlab.graphics.internal.configureAxes(hAx,x,y);
    [x,y] = matlab.graphics.internal.makeNumeric(hAx,x,y);
end

autoColor = true;
colorProp = 'FaceColor_I';
for i = 1:2:numel(pvPairs)
    if startsWith('FaceColor',pvPairs{i}) && ~strcmp(pvPairs{i+1},'flat')
        autoColor = false;
        colorProp = 'FaceColor';
    end
end

% Create the bars - note that the offsets are set after the bars are created:
h = repmat(matlab.graphics.GraphicsPlaceholder(),1,numSeries);
for i=1:numSeries
    xDataPV = {};
    if ~isXDataModeAuto
        xDataPV = {'XData',x(:,i)};
    end
    [~,c] = nextstyle(hAx,autoColor,false);
    
    % If we did not get a Horizontal value, don't set it (and use the
    % DefaultBarHorizontal value).  If we did get a Horizontal value, it
    % must be set before BaseValue because BaseValue needs to know which of
    % X/YBaseline to set it on. In either case Axes must be set before the
    % BaseValue for similar reasons.  
    if useDefaultHorizontal
        h(i) = matlab.graphics.chart.primitive.Bar('Parent',hPar,...
          'YData',y(:,i),xDataPV{:},colorProp,c,...
          'NumPeers',numSeries,...
          pvPairs{:});        
    else
        h(i) = matlab.graphics.chart.primitive.Bar('Parent',hPar,...
          'ExchangeXY',horizontal_val,...
          'Horizontal_I',horizontal_val,...
          'YData',y(:,i),xDataPV{:},colorProp,c,...
          'NumPeers',numSeries,...
          pvPairs{:});
    end
    
    % If we didn't just set the cdata, set it to the facecolor value (or
    % the colororder value if FaceColor is 'none' or 'flat') 
    if strcmp(h(i).CDataMode,'auto')
        numelements = size(y,1);
        if ~ischar(h(i).FaceColor) && (numel(h(i).FaceColor) == 3)
            cdata = repmat(h(i).FaceColor,numelements,1);
        else
            cdata = repmat(c,numelements,1);
        end
        h(i).CData_I = cdata;            
    end
end

BarPeerID = matlab.graphics.chart.primitive.utilities.incrementPeerID();
for i=1:numSeries
    h(i).doPostSetup(BarPeerID);
end

if ~isempty(h)
    matlab.graphics.chart.primitive.bar.internal.tickCallback(hAx, h(1).XData, h(1).Horizontal);
end

% Turn off edges when they start to overwhelm the colors
% The threshold is 150 adjacent bars
if strcmp(h(1).BarLayout,'grouped')
    numAdjacentBars = numel(y);
else
    numAdjacentBars = size(y,1);
end
if numAdjacentBars > 150 && ~any(strcmpi('EdgeColor',pvPairs(1:2:end)))
    for i=1:numSeries
        h(i).EdgeColor = 'none';
    end
end

switch hAx.NextPlot
    case {'replaceall','replace'}
        view(hAx,2);
        hAx.Box = 'on';
        hAx.Layer = 'bottom';
        matlab.graphics.internal.setRulerLayerTop(hAx);
    case 'replacechildren'
        hAx.Layer = 'bottom';
        matlab.graphics.internal.setRulerLayerTop(hAx);
end

% Make sure to call "getcolumn" for properties that require it:
if ~isempty(h)
    if numSeries > 1
        localCallGetColumn(h,numSeries,'DisplayName');
        localCallGetColumn(h,numSeries,'XDataSource');
        localCallGetColumn(h,numSeries,'YDataSource');
    end
end

if nargout>0, hh = h; end

%-------------------------------------------------------------------------%
function localCallGetColumn(h,numSeries,propName)

propVal = get(h(1),propName);
if isempty(propVal)
    return;
end

newVals = getcolumn(propVal,1:numSeries,'expression');
for i=1:numSeries
    set(h(i),propName,newVals{i});
end


