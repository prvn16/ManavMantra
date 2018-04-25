function hh = quiver(varargin)
%QUIVER Quiver plot.
%   QUIVER(X,Y,U,V) plots velocity vectors as arrows with components (u,v)
%   at the points (x,y).  The matrices X,Y,U,V must all be the same size
%   and contain corresponding position and velocity components (X and Y
%   can also be vectors to specify a uniform grid).  QUIVER automatically
%   scales the arrows to fit within the grid.
%
%   QUIVER(U,V) plots velocity vectors at equally spaced points in
%   the x-y plane.
%
%   QUIVER(U,V,S) or QUIVER(X,Y,U,V,S) automatically scales the
%   arrows to fit within the grid and then stretches them by S.  Use
%   S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER(...,'filled') fills any markers specified.
%
%   QUIVER(AX,...) plots into AX instead of GCA.
%
%   H = QUIVER(...) returns a quivergroup handle.
%
%   Example:
%      [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%      z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%      contour(x,y,z), hold on
%      quiver(x,y,px,py), hold off, axis image
%
%   See also FEATHER, QUIVER3, PLOT.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2014 The MathWorks, Inc.

[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
narginchk(2,inf);
% Parse remaining args
try
    pvpairs = quiverparseargs(args);
catch ME
    throw(ME)
end

if isempty(cax) || ishghandle(cax,'axes')
    cax = newplot(cax);
    % just create a new axes for new
    % until newplot is working so that 
    % cla(ax, 'reset',hsave); doesn't wipe out the default
    % shaped arrays like ColorOrder and LineStyleOrder
    % cax = gca; cla(cax);
    
    parax = cax;
    NextPlotReplace = any(strcmpi(cax.NextPlot,{'replaceall','replace'}));
else
    parax = cax;
    cax = ancestor(cax,'Axes');
    NextPlotReplace = false;
end
[ls,c] = nextstyle(cax);

h = matlab.graphics.chart.primitive.Quiver;
set(h,'Parent',parax,'Color_I',c,'LineStyle_I',ls,pvpairs{:});

% call CreateFcn explicitly immediately following object
% creation from the M point of view.
% this was the last line of @Quiver/Quiver.m
% There is no obvious place to have the CreateFcn 
% automatically executed on the MCOS side, so we call it here
h.CreateFcn;

if NextPlotReplace
    box(cax,'on');
end

if nargout>0, hh = h; end
