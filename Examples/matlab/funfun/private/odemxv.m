function out = odemxv(Mfun,t,y,v,varargin)
%ODEMXV  Helper function -- evaluates Mfun(t,y)*v
%   Used to get d(M(t,y)*v)/dy when the property MStateDependence is 'strong'  
%
%   See also DAEIC3, ODE15S, ODE23T, ODE23TB.

%   Jacek Kierzenka, Lawrence Shampine
%   Copyright 1984-2002 The MathWorks, Inc. 

out = feval(Mfun,t,y,varargin{:})*v;
