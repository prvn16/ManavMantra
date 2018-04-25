function h = surf(varargin)
%SURF   3-D colored surface.
%   SURF(X,Y,Z,C) plots the colored parametric surface defined by
%   four matrix arguments.  The view point is specified by VIEW.
%   The axis labels are determined by the range of X, Y and Z,
%   or by the current setting of AXIS.  The color scaling is determined
%   by the range of C, or by the current setting of CAXIS.  The scaled
%   color values are used as indices into the current COLORMAP.
%   The shading model is set by SHADING.
%
%   SURF(X,Y,Z) uses C = Z, so color is proportional to surface height.
%
%   SURF(x,y,Z) and SURF(x,y,Z,C), with two vector arguments replacing
%   the first two matrix arguments, must have length(x) = n and
%   length(y) = m where [m,n] = size(Z).  In this case, the vertices
%   of the surface patches are the triples (x(j), y(i), Z(i,j)).
%   Note that x corresponds to the columns of Z and y corresponds to
%   the rows.
%
%   SURF(Z) and SURF(Z,C) use x = 1:n and y = 1:m.  In this case,
%   the height, Z, is a single-valued function, defined over a
%   geometrically rectangular grid.
%
%   SURF(...,'PropertyName',PropertyValue,...) sets the value of the
%   specified surface property.  Multiple property values can be set
%   with a single statement.
%
%   SURF(AX,...) plots into AX instead of GCA.
%
%   SURF returns a handle to a surface plot object.
%
%   AXIS, CAXIS, COLORMAP, HOLD, SHADING and VIEW set figure, axes, and
%   surface properties which affect the display of the surface.
%
%   See also SURFC, SURFL, MESH, SHADING.

%-------------------------------
%   Additional details:
%
%   If the NextPlot axis property is REPLACE (HOLD is off), SURF resets
%   all axis properties, except Position, to their default values
%   and deletes all axis children (line, patch, surf, image, and
%   text objects).

%   Copyright 1984-2017 The MathWorks, Inc.

%   J.N. Little 1-5-92

narginchk(1,inf)

[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
nargs = length(args);
args = matlab.graphics.internal.convertStringToCharArgs(args);
hadParentAsPVPair = false;
if nargs > 1
    % try to fetch axes handle from input args,
    % and allow it to override the possible input "cax"
    for i = 1:length(args)
        isValid = ~isempty(args{i}) && matlab.graphics.internal.isCharOrString(args{i});
        hasParentArg = strncmpi(args{i}, 'parent', length(args{i}));
        if isValid && hasParentArg && nargs > i
            cax = args{i+1};
            hadParentAsPVPair = true;
            break;
        end
    end
end

% do input checking
dataargs = parseparams(args);
error(surfchk(dataargs{:}));

% use nextplot unless user specified an axes handle in pv pairs
% required for backwards compatibility
if isempty(cax) || ~hadParentAsPVPair
    if ~isempty(cax) && ~ishghandle(cax,'Axes')
        parax = cax;
        cax = ancestor(cax,'Axes');
        nextPlot = 'add';
    else
        cax = newplot(cax);
        parax = cax;
        nextPlot = cax.NextPlot;
    end
else
    cax = newplot(cax);
    parax = cax;
    nextPlot = cax.NextPlot;
end
% We need to separate out convenience arguments from P/V pairs:
% First, determine the number of numeric data arguments:
len = length(args);
n = 1;
while n<=len && isplottable(args{n})
    n = n+1;
end
n = n-1;
% Determine the appropriate syntax:
params = {};
switch(n)
    case 1
        % SURF(Z,...)
        z = args{1};
        matlab.graphics.internal.configureAxes(cax,[],[],z);
        [~,~,z] = matlab.graphics.internal.makeNumeric(cax,[],[],z);
        params = {'ZData',z};
        args = args(2:end);
    case 2
        % SURF(Z,C,...)
        z = args{1};
        matlab.graphics.internal.configureAxes(cax,[],[],z);
        [~,~,z] = matlab.graphics.internal.makeNumeric(cax,[],[],z);
        params = {'ZData',z,'CData',args{2}};
        args = args(3:end);
    case 3
        % SURF(X,Y,Z,...)
        x = args{1};
        y = args{2};
        z = args{3};
        matlab.graphics.internal.configureAxes(cax,x,y,z);
        [x,y,z] = matlab.graphics.internal.makeNumeric(cax,x,y,z);
        params = {'XData',x,'YData',y,'ZData',z};
        args = args(4:end);
    case 4
        % SURF(X,Y,Z,C,...)
        x = args{1};
        y = args{2};
        z = args{3};
        matlab.graphics.internal.configureAxes(cax,x,y,z);
        [x,y,z] = matlab.graphics.internal.makeNumeric(cax,x,y,z);
        params = {'XData',x,'YData',y,'ZData',z,'CData',args{4}};
        args = args(5:end);
end

%Place parenting arguments first so that parent-sensitive properties 
%eg. UIContextMenu are set after surface is parented.
allargs = [params, {'Parent',parax}, args]; 

hh = matlab.graphics.chart.primitive.Surface(allargs{:});

switch nextPlot
    case {'replaceall','replace'}
        view(cax,3);
        grid(cax,'on');
    case {'replacechildren'}
        view(cax,3);
end

if nargout == 1
    h = hh;
end

% function out=id(str)
% out = ['MATLAB:surf:' str];

function out = isplottable(x)
out = isnumeric(x) || isa(x,'datetime') || isa(x,'duration') || isa(x,'categorical');
