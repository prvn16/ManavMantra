function h = scatter(varargin)
%SCATTER Scatter plot.
%  Supported syntaxes for tall X, Y:
%   SCATTER(X,Y)  
%   SCATTER(X,Y,S) 
%   SCATTER(X,Y,S,C) 
%   SCATTER(...,M) 
%   SCATTER(...,'filled') 
%   SCATTER(AX,...) 
%
%  Notes and Limitations: 
%   1) S must be scalar or empty
%   2) C must be scalar or RGB triplet
%   3) Categorical inputs are not supported. 
%   4) With tall inputs, SCATTER plots in iterations, progressively 
%      adding to the plot as more data is read. During updating, a progress 
%      indicator shows the proportion of data that has been plotted. Zooming 
%      and panning is supported during updating before the plot is complete. 
%      To pause the update process, press the pause button in the progress 
%      indicator.
%
%  See also SCATTER, BINSCATTER, TALL, TALL/PLOT.

%  Copyright 2017 MathWorks, Inc. 

[cax,args] = matlab.bigdata.internal.util.axesCheck(varargin{:});
narginchk(2,inf);
x = args{1};
y = args{2};
args(1:2) = [];

% error checking in the first two inputs
tall.checkIsTall(mfilename, 1, x);
x  = tall.validateType(x,mfilename,{'numeric','logical','datetime','duration'},1);
x = lazyValidate(x, {@(x1)iscolumn(x1) && (~isnumeric(x1) || isreal(x1)), ...
    'MATLAB:scatter:InvalidTallData'});
tall.checkIsTall(mfilename, 2, y);
y  = tall.validateType(y,mfilename,{'numeric','logical','datetime','duration'},2);
y = lazyValidate(y, {@(y1)iscolumn(y1) && (~isnumeric(y1) || isreal(y1)), ...
    'MATLAB:scatter:InvalidTallData'});
[x, y] = validateSameTallSize(x,y);

% error checking for the rest of the inputs
[args, appendautofacecolor] = parseinput(args);

cax = newplot(cax);

xclass = tall.getClass(x);
yclass = tall.getClass(y);
switch xclass
    case 'datetime'   
        xtype = datetime;
    case 'duration'   
        xtype = duration;
    otherwise  % numeric, logical
        xtype = 1;
end
switch yclass
    case 'datetime'  
        ytype = datetime;
    case 'duration'   
        ytype = duration;
    otherwise  % numeric, logical
        ytype = 1;
end
matlab.graphics.internal.configureAxes(cax,xtype,ytype);

[~,autocolor] = specgraphhelper('nextstyle',cax,true,false,false);
args = [{'CData',autocolor} args];
if appendautofacecolor
    args = [args {'MarkerFaceColor','flat'}];
end

t = table(x, y);
markforreuse(t);
x = subsref(t, substruct('.','x'));
y = subsref(t, substruct('.','y'));
htemp = matlab.graphics.chart.primitive.tall.Scatter('XData', x, 'YData', y, ...
    args{:}, 'Parent', cax);
    
if nargout > 0 
    h = htemp;
end


function [outargs,appendautofacecolor] = parseinput(args)
tall.checkNotTall(mfilename, 2, args{:});
outargs = {};
customcolor = false;
nameoffset = 2;
ind = 1;  % parsing index
if ~isempty(args) && ~isNonTallScalarString(args{ind})
    % size input
    s = args{ind};
    if ~isempty(s)
        validateattributes(s, {'numeric'}, {'scalar', 'real', 'positive', 'finite'},...
            mfilename, 'Size');
        outargs = {'SizeData', s};
    end
    ind = ind + 1;
    % color input
    if ind <= length(args) 
        if isnumeric(args{ind})
            c = args{ind};
            validateattributes(c,{'numeric'},{'size',[1 3],'nonnegative',...
                'real', '<=', 1}, mfilename, 'Marker Color');
            customcolor = true;
        else
            [~,c,~,tmsg] = colstyle(args{ind});
            customcolor = isempty(tmsg) && ~isempty(c);
        end
        if customcolor
            outargs = [outargs {'MarkerEdgeColor',c}];
            ind = ind + 1;
        end
    end
end

% filled option and marker style
appendautofacecolor = false;
if ind <= length(args)
    % filled option
    filled = false;
    if strncmpi(args{ind}, 'filled', length(args{ind}))
        filled = true;
        ind = ind + 1;
    end
    
    % marker style
    if ind <= length(args)
        [~,~,m,tmsg] = colstyle(args{ind});
        if isempty(tmsg) && ~isempty(m)
            outargs = [outargs {'Marker',m}];
            ind = ind + 1;
        end
        
        
        % filled option again, such that marker style and filled are order
        % independent
        if ind <= length(args) && ~filled && strncmpi(args{ind}, 'filled', length(args{ind}))
            filled = true;
            ind = ind + 1;
        end
    end
    
    if filled
        if customcolor
            outargs = [outargs {'MarkerFaceColor',c}];
        else
            appendautofacecolor = true;
        end
    end
end

% remaining must be name-value pairs
if rem(length(args)-ind+1,2) ~= 0
    error(message('MATLAB:scatter:ArgNameValueMismatch'));
end

names = setdiff(properties('matlab.graphics.chart.primitive.tall.Scatter'),...
    {'Annotation', 'BeingDeleted', 'Children', 'Type'});
while ind <= length(args)
    % perform partial matching and completion
    paramname = validatestring(args{ind},names,nameoffset+ind);
    outargs = [outargs paramname args(ind+1)]; %#ok<AGROW>
    ind = ind + 2;
end
