function hh = errorbar(varargin)
%ERRORBAR Plot error bars along curve
%   ERRORBAR(Y,E) plots Y and draws a vertical error bar at each element of
%   Y. The error bar is a distance of E(i) above and below the curve so
%   that each bar is symmetric and 2*E(i) long.
%
%   ERRORBAR(X,Y,E) plots Y versus X with symmetric vertical error bars
%   2*E(i) long. X, Y, E must be the same size. When they are vectors, each
%   error bar is a distance of E(i) above and below the point defined by
%   (X(i),Y(i)). When they are matrices, each error bar is a distance of
%   E(i,j) above and below the point defined by (X(i,j),Y(i,j)).
%
%   ERRORBAR(X,Y,NEG,POS) plots X versus Y with vertical error bars
%   NEG(i)+POS(i) long specifying the lower and upper error bars. X and Y
%   must be the same size. NEG and POS must be the same size as Y or empty.
%   When they are vectors, each error bar is a distance of NEG(i) below and
%   POS(i) above the point defined by (X(i),Y(i)). When they are matrices,
%   each error bar is a distance of NEG(i,j) below and POS(i,j) above the
%   point defined by (X(i,j),Y(i,j)). When they are empty the error bar is
%   not drawn.
%
%   ERRORBAR( ___ ,Orientation) specifies the orientation of the error
%   bars. Orientation can be 'horizontal', 'vertical', or 'both'. When the
%   orientation is omitted the default is 'vertical'.
%
%   ERRORBAR(X,Y,YNEG,YPOS,XNEG,XPOS) plots X versus Y with vertical error
%   bars YNEG(i)+YPOS(i) long specifying the lower and upper error bars and
%   horizontal error bars XNEG(i)+XPOS(i) long specifying the left and
%   right error bars. X and Y must be the same size. YNEG, YPOS, XNEG, and
%   XPOS must be the same size as Y or empty. When they are empty the error
%   bar is not drawn.
%
%   ERRORBAR( ___ ,LineSpec) specifies the color, line style, and marker.
%   The color is applied to the data line and error bars. The line style
%   and marker are applied to the data line only.
%
%   ERRORBAR(AX, ___ ) plots into the axes specified by AX instead of the
%   current axes.
%
%   H = ERRORBAR( ___ ) returns handles to the errorbarseries objects
%   created. ERRORBAR creates one object for vector input arguments and one
%   object per column for matrix input arguments.
%
%   Example: Draws symmetric error bars of unit standard deviation.
%      x = 1:10;
%      y = sin(x);
%      e = std(y)*ones(size(x));
%      errorbar(x,y,e)

%   L. Shure 5-17-88, 10-1-91 B.A. Jones 4-5-93
%   Copyright 1984-2017 MathWorks, Inc.

% Look for a parent among the input arguments
[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);

% We require at least one input
narginchk(1, inf);

% Separate Name/Value pairs from data inputs, convert LineSpec to
% Name/Value pairs, and filter out the orientation flag.
[pvpairs,args,nargs,msg,orientation] = parseargs(args);
if ~isempty(msg), error(msg); end
pvpairs = matlab.graphics.internal.convertStringToCharArgs(pvpairs);
% Check that we have the correct number of data input arguments.
if nargs < 2
    error(message('MATLAB:narginchk:notEnoughInputs'));
elseif nargs > 4 && ~isempty(orientation)
    error(message('MATLAB:errorbar:InvalidUseOfOrientation'));
elseif nargs == 5
    error(message('MATLAB:errorbar:InvalidNumberDataInputs'));
elseif nargs > 6
    error(message('MATLAB:narginchk:tooManyInputs'));
end

% Make sure all the data input arguments are real numeric data.
args = getRealData(args);

% Grab the X data if present.
if nargs >= 3
    % errorbar(x,y,e,...)
    x = args{1};
    args = args(2:end);
else
    % errorbar(y,e)
    x = [];
end

% Grab the Y data
y = checkSingleInput(args{1}, [], 'YData');
sz = size(y);
n = sz(2);

% Now that we have the size of the YData, validate the size of the XData
x = checkSingleInput(x, sz, 'XData');

% Grab the first delta inputs.
neg = args{2};

% Grab the second delta inputs.
if numel(args) >= 3
    % errorbar(x,y,neg,pos,...)
    pos = args{3};
else
    % errorbar(y,e) or
    % errorbar(x,y,e)
    pos = neg;
end

% Grab the remaining delta inputs and validate all data inputs.
if numel(args) == 5
    % errorbar(x,y,yneg,ypos,xneg,xpos)
    yneg = checkSingleInput(neg, sz, 'YNegativeDelta');
    ypos = checkSingleInput(pos, sz, 'YPositiveDelta');
    xneg = checkSingleInput(args{4}, sz, 'XNegativeDelta');
    xpos = checkSingleInput(args{5}, sz, 'XPositiveDelta');
else
    switch orientation
        % errorbar(y,e,orientation) or
        % errorbar(x,y,e,orientation) or
        % errorbar(x,y,neg,pos,orientation)
        case 'horizontal'
            xneg = checkSingleInput(neg, sz, 'XNegativeDelta');
            xpos = checkSingleInput(pos, sz, 'XPositiveDelta');
            yneg = [];
            ypos = [];
        case 'both'
            xneg = checkSingleInput(neg, sz, 'XNegativeDelta');
            xpos = checkSingleInput(pos, sz, 'XPositiveDelta');
            yneg = xneg;
            ypos = xpos;
        otherwise
            % Default to vertical if orientation isn't specified.
            xneg = [];
            xpos = [];
            yneg = checkSingleInput(neg, sz, 'YNegativeDelta');
            ypos = checkSingleInput(pos, sz, 'YPositiveDelta');
    end
end

% Handle vectorized data sources and display names
extrapairs = cell(n,0);
if ~isempty(pvpairs) && (n > 1)
    [extrapairs, pvpairs] = vectorizepvpairs(pvpairs,n,...
        {'XDataSource','YDataSource',...
        'UDataSource','LDataSource',...
        'XNegativeDeltaSource','XPositiveDeltaSource',...
        'YNegativeDeltaSource','YPositiveDeltaSource',...
        'DisplayName'});
end

% Prepare the parent for plotting.
if isempty(cax) || ishghandle(cax,'axes')
    cax = newplot(cax);
    parax = cax;
    hold_state = any(strcmp(cax.NextPlot,{'replacechildren','add'}));
else
    parax = cax;
    cax = ancestor(cax,'axes');
    hold_state = true;
end

% Determine the Color and LineStyle property names
% If the Color/LineStyle is not specified use the _I property names so that
% the ColorMode or LineStyleMode properties are not toggled.
colorPropName = 'Color';
autoColor = ~any(strcmpi('color',pvpairs(1:2:end)));
if autoColor
    colorPropName = 'Color_I';
end
stylePropName = 'LineStyle';
autoStyle = ~any(strcmpi('linestyle',pvpairs(1:2:end)));
if autoStyle
    stylePropName = 'LineStyle_I';
end

% Create the ErrorBar objects
h = gobjects(1,n);
xdata = {};
for k = 1:n
    % extract data from vectorizing over columns
    if ~isempty(x)
        xdata = {'XData', getColumn(x,k)};
    end
    [ls,c,m] = nextstyle(cax,autoColor,autoStyle);
    
    h(k) = matlab.graphics.chart.primitive.ErrorBar(...
        'YData',getColumn(y,k),xdata{:},...
        'XNegativeDelta',getColumn(xneg,k),...
        'XPositiveDelta',getColumn(xpos,k),...
        'YNegativeDelta',getColumn(yneg,k),...
        'YPositiveDelta',getColumn(ypos,k),...
        colorPropName,c,stylePropName,ls,'Marker_I',m,...
        pvpairs{:},extrapairs{k,:},'Parent',parax);
end

if ~hold_state
    set(cax,'Box','on');
end

if nargout>0, hh = h; end

end

%-------------------------------------------------------------------------%
function [pvpairs,args,nargs,msg,orientation] = parseargs(args)
% separate pv-pairs from opening arguments
[args,pvpairs] = parseparams(args);

% Check for LineSpec or Orientation strings
% Allow the orientation flag to occur either before or after the LineSpec
% Allow LineSpec and Orientation to occur at most once each.
validOrientations = {'horizontal','vertical','both'};
orientation = '';
keepArg = true(1,numel(pvpairs));
extraPairs = {};
for a = 1:min(2,numel(pvpairs))
    if matlab.graphics.internal.isCharOrString(pvpairs{a})
        % Check for partial matching of the orientation flag using a
        % minimum of 3 characters.
        tf = strncmpi(pvpairs{a},validOrientations,max(3,numel(pvpairs{a})));
        if isempty(orientation) && any(tf)
            orientation = validOrientations{tf};
            keepArg(a) = false;
        else
            % Check for LineSpec string
            [l,c,m,tmsg]=colstyle(pvpairs{a},'plot');
            if isempty(tmsg) && isempty(extraPairs)
                keepArg(a) = false;
                if ~isempty(l)
                    extraPairs = {'LineStyle',l};
                end
                if ~isempty(c)
                    extraPairs = [{'Color',c},extraPairs]; %#ok<AGROW>
                end
                if ~isempty(m)
                    extraPairs = [{'Marker',m},extraPairs]; %#ok<AGROW>
                end
            else
                break;
            end
        end
    else
        % Not a string, so stop looking.
        break
    end
end

linestyleerror = numel(pvpairs)==1;
pvpairs = [extraPairs, pvpairs(keepArg)];
msg = checkpvpairs(pvpairs,linestyleerror);
nargs = numel(args);

end

%-------------------------------------------------------------------------%
function val = checkSingleInput(val, sz, propName)

if isvector(val)
    val = val(:);
end

if ~isempty(sz) && ~isempty(val) && ~isequal(sz, size(val))
    if strcmp(propName,'XData')
        error(message('MATLAB:errorbar:XDataSizeMismatch'));
    else
        error(message('MATLAB:errorbar:DeltaSizeMismatch', propName));
    end
end

end

%-------------------------------------------------------------------------%
function col = getColumn(val, k)
    if isempty(val)
        col = val;
    else
        col = datachk(val(:,k));
    end
end
