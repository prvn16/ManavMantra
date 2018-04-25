function hh = quiver3(varargin)
%QUIVER3 3-D quiver plot.
%   QUIVER3(X,Y,Z,U,V,W) plots velocity vectors as arrows with components
%   (u,v,w) at the points (x,y,z).  The matrices X,Y,Z,U,V,W must all be
%   the same size and contain the corresponding position and velocity
%   components.  QUIVER3 automatically scales the arrows to fit.
%
%   QUIVER3(Z,U,V,W) plots velocity vectors at the equally spaced
%   surface points specified by the matrix Z.
%
%   QUIVER3(Z,U,V,W,S) or QUIVER3(X,Y,Z,U,V,W,S) automatically
%   scales the arrows to fit and then stretches them by S.
%   Use S=0 to plot the arrows without the automatic scaling.
%
%   QUIVER3(...,LINESPEC) uses the plot linestyle specified for
%   the velocity vectors.  Any marker in LINESPEC is drawn at the base
%   instead of an arrow on the tip.  Use a marker of '.' to specify
%   no marker at all.  See PLOT for other possibilities.
%
%   QUIVER3(...,'filled') fills any markers specified.
%
%   QUIVER3(AX,...) plots into AX instead of GCA.
%
%   H = QUIVER3(...) returns a quiver object.
%
%   Example:
%       [x,y] = meshgrid(-2:.2:2,-1:.15:1);
%       z = x .* exp(-x.^2 - y.^2);
%       [u,v,w] = surfnorm(x,y,z);
%       quiver3(x,y,z,u,v,w); hold on, surf(x,y,z), hold off
%
%   See also QUIVER, PLOT, PLOT3, SCATTER.

%   Clay M. Thompson 3-3-94
%   Copyright 1984-2017 The MathWorks, Inc.

[~, cax, args] = parseplotapi(varargin{:},'-mfilename',mfilename);
narginchk(4,inf);

% Parse remaining args
try
    pvpairs = quiver3parseargs(args);
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
    nextPlot = cax.NextPlot;
else
    parax = cax;
    cax = ancestor(cax,'Axes');
    nextPlot = 'add';
end
[ls,c] = nextstyle(cax);

h = matlab.graphics.chart.primitive.Quiver;
set(h,'Parent',parax,'Color_I',c,'LineStyle_I',ls,pvpairs{:});

switch nextPlot
    case {'replaceall','replace'}
        view(cax,3);
        grid(cax,'on');
    case {'replacechildren'}
        view(cax,3);
end

% call CreateFcn explicitly immediately following object
% creation from the M point of view.
% this was the last line of @Quiver/Quiver.m
% There is no obvious place to have the CreateFcn 
% automatically executed on the MCOS side, so we call it here
h.CreateFcn;

if nargout>0, hh = h; end
