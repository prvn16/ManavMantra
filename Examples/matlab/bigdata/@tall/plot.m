function h = plot(varargin)
%PLOT Linear plot.
%  Supported syntaxes for tall X, Y:
%   PLOT(X,Y)
%   PLOT(Y) 
%   PLOT(...,S) 
%   PLOT(AX,...)
%
%  Notes and Limitation: 
%   1) X must be in monotonically increasing order. 
%   2) Categorical inputs are not supported. 
%   3) With tall inputs, the PLOT command plots in iterations, progressively 
%      adding to the plot as more data is read. During updating, a progress 
%      indicator shows the proportion of data that has been plotted. Zooming 
%      and panning is supported during updating before the plot is complete. 
%      To stop the update process, press the pause button in the progress 
%      indicator.
%
%  See also PLOT, TALL, TALL/SCATTER.

%  Copyright 2017 The MathWorks, Inc. 

[cax,args] = matlab.bigdata.internal.util.axesCheck(varargin{:});
x = args{1};
tall.checkIsTall(mfilename, 1, x);
x  = tall.validateType(x,mfilename,{'numeric','logical','datetime','duration'},1);
x = lazyValidate(x, {@(x1)iscolumn(x1) && (~isnumeric(x1) || isreal(x1)), ...
    'MATLAB:plot:InvalidTallData'});
if isscalar(args) || ~istall(args{2})
    % one input case
    y = x;
    x = [];
    args(1) = [];
    offset = 1;
else
    y = args{2};
    y  = tall.validateType(y,mfilename,{'numeric','logical','datetime','duration'},2);
    y = lazyValidate(y, {@(y1)iscolumn(y1) && (~isnumeric(y1) || isreal(y1)), ...
        'MATLAB:plot:InvalidTallData'});
    x = lazyValidate(x, {@matlab.graphics.chart.primitive.tall.internal.isMonotonicIncreasing, 'MATLAB:plot:XNotMonotonicIncreasing'});
    [x, y] = validateSameTallSize(x,y);
    args(1:2) = [];
    offset = 2;
end
args = parseinput(args, offset);
cax = newplot(cax);

% set up axes if datetime or duration
if istall(x)
    xclass = tall.getClass(x);
    switch xclass
        case 'datetime'
            xtype = datetime;
        case 'duration'
            xtype = duration;
        otherwise
            xtype = 1;
    end
else
    xtype = 1;
end
yclass = tall.getClass(y);
switch yclass
    case 'datetime'
        ytype = datetime;
    case 'duration'
        ytype = duration;
    otherwise
        ytype = 1;
end
matlab.graphics.internal.configureAxes(cax,xtype,ytype);

[autolinestyle,autocolor] = specgraphhelper('nextstyle',cax,true,true,false);
args = [{'Color',autocolor,'LineStyle',autolinestyle} args];

if ~istall(x) && isempty(x)
    markforreuse(y);
    
    htemp = matlab.graphics.chart.primitive.tall.Line('YData', y, ...
        args{:}, 'Parent', cax);
else
    t = table(x, y);
    markforreuse(t);
    x = subsref(t, substruct('.','x'));
    y = subsref(t, substruct('.','y'));
    
    htemp = matlab.graphics.chart.primitive.tall.Line('XData', x, 'YData', y, ...
        args{:}, 'Parent', cax);
end
if nargout > 0 
    h = htemp;
end

function outargs = parseinput(args, offset)
tall.checkNotTall(mfilename, offset, args{:});
outargs = {};

ind = 1;  % parsing index
% parse the linespec
if ~isempty(args) 
    [l,c,m,tmsg] = colstyle(args{ind},'plot');
    if isempty(tmsg)
        if ~isempty(l)
            outargs = [outargs {'LineStyle',l}];
        end
        if ~isempty(c)
            outargs = [outargs {'Color',c}];
        end
        if ~isempty(m)
            outargs = [outargs {'Marker',m}];
        end
        ind = ind + 1;
    end
end

% remaining must be name-value pairs
if rem(length(args)-ind+1,2) ~= 0
    error(message('MATLAB:plot:ArgNameValueMismatch'));
end

names = setdiff(properties('matlab.graphics.chart.primitive.tall.Line'),...
    {'Annotation', 'BeingDeleted', 'Children', 'Type'});
while ind <= length(args)
    % perform partial matching and completion
    paramname = validatestring(args{ind},names,offset+ind);
    outargs = [outargs paramname args(ind+1)]; %#ok<AGROW>
    ind = ind + 2;
end
