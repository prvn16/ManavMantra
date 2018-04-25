function [yinterp,ypinterp] = ntrp15i(tinterp,~,~,tnew,ynew,mesh,meshsol)
%NTRP15I  Interpolation helper function for ODE15I.
%   YINTERP = NTRP15I(TINTERP,T,Y,TNEW,YNEW,MESH,MESHSOL) uses data computed 
%   in ODE15I to approximate the solution at time TINTERP.  
%   TINTREP may be a scalar or a row vector. 
%   The arguments T and Y do not affect the computations. They are required
%   for consistency of syntax with other interpolation functions. Any values
%   entered for T and Y are ignored.
%    
%   [YINTERP,YPINTERP] = NTRP15I(TINTERP,T,Y,TNEW,YNEW,MESH,MESHSOL) returns
%   also the derivative of the polynomial approximating the solution.  
%   
%   See also ODE15I, DEVAL.

%   Jacek Kierzenka and Lawrence F. Shampine
%   Copyright 1984-2009 The MathWorks, Inc.

mesh = [tnew mesh];
meshsol = [ynew meshsol];

m = size(meshsol,2);  
N = length(tinterp);    

% Calculate Lagrangian interpolation and derivative coefficients for all
% the output points at the same time.
L = ones(m,N);
dL = zeros(m,N);
for j=1:m
  for i=1:m
    if i ~= j
      T = (tinterp - mesh(i))/(mesh(j) - mesh(i));
      dL(j,:) = dL(j,:) .* T + L(j,:) ./ (mesh(j) - mesh(i));
      L(j,:) = L(j,:) .* T;
    end
  end
end  
yinterp = meshsol * L;
ypinterp = meshsol * dL;
  
