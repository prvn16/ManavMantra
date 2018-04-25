function hh = fmesh(varargin)
%FMESH   Plot 3-D mesh
%   FMESH(FUN) creates a mesh plot of FUN(X,Y). FUN is plotted over
%   the axes range, with a default interval -5 < X < 5 and -5 < Y < 5.
% 
%   FMESH(FUN,INTERVAL) plots FUN over the specified INTERVAL instead of the
%   default interval. INTERVAL can be the vector [XMIN XMAX YMIN YMAX] or the
%   vector [A B] (to plot over A < X < B and A < Y < B).
%
%   FMESH(FUNX,FUNY,FUNZ) plots the parametric surface FUNX(U,V),
%   FUNY(U,V), and FUNZ(U,V) over the interval -5 < U < 5 and
%   -5 < V < 5.
%
%   FMESH(FUNX,FUNY,FUNZ,[UMIN UMAX VMIN VMAX]) or
%   FMESH(FUNX,FUNY,FUNZ,[A B]) uses the specified interval.
%
%   FMESH(AX,...) plots into the axes AX instead of the current axes.
%
%   H = FMESH(...) returns a handle to the plotted object in H.
%
%   Examples:
%      fmesh(@(x,y) x.*exp(-x.^2-y.^2))
%      fmesh(@(x,y) sinc(x.^2+y.^2),[-2,2])
%      fmesh(@peaks)
%
%   If your function has additional parameters, for example k in myfun:
%      %-----------------------%
%      function z = myfun(x,y,k)
%      z = - x.^k - y.^k;
%      %-----------------------%
%   then you may use an anonymous function to specify that parameter:
%      fmesh(@(x,y)myfun(x,y,2))
%
%   See also FSURF, FPLOT, FIMPLICIT3, MESH, FUNCTION_HANDLE.

%   Copyright 2015-2016 The MathWorks, Inc.

h = fsurf(varargin{:}, 'CalledForMesh');

if nargout > 0
    hh = h;
end
