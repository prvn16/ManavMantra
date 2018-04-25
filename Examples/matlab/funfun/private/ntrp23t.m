function [yint,ypint] = ntrp23t(tint,t,y,~,ynew,h,z,znew,idxNonNegative)
%NTRP23T  Interpolation helper function for ODE23T.
%   YINT = NTRP23T(TINT,T,Y,TNEW,YNEW,H,Z,ZNEW,IDX) uses data computed in ODE23T
%   to approximate the solution at time TINT. TINT may be a scalar or a row vector.     
%   The argument TNEW does not affect the computations. It is required for 
%   consistency of syntax with other interpolation functions. Any values entered 
%   for TNEW are ignored.
%        
%   [YINT,YPINT] = NTRP23T(TINT,T,Y,TNEW,YNEW,H,Z,ZNEW,IDX) returns also the 
%   derivative of the polynomial approximating the solution.   
%   
%   IDX has indices of solution components that must be non-negative. Negative 
%   YINT(IDX) are replaced with zeros and the derivative YPINT(IDX) is set
%   to zero.
%   
%   See also ODE23T, DEVAL.

%   Mark W. Reichelt, Lawrence F. Shampine, and Yanyuan Ma, 7-1-97
%   Copyright 1984-2009 The MathWorks, Inc.

s = (tint - t)/h;
s2 = s .* s;
s3 = s .* s2;
v1 = ynew - y - z;
v2 = znew - z;
yint = y(:,ones(size(tint))) + z*s + (3*v1 - v2)*s2 + (v2 - 2*v1)*s3;

ypint = [];
if nargout > 1
  zh = z/h;
  ypint = zh(:,ones(size(tint))) + 2/h*(3*v1 - v2)*s + 3/h*(v2 - 2*v1)*s2;
end  

% Non-negative solution
if ~isempty(idxNonNegative)
  idx = find(yint(idxNonNegative,:)<0); % vectorized
  if ~isempty(idx)
    w = yint(idxNonNegative,:);
    w(idx) = 0;
    yint(idxNonNegative,:) = w;
    if nargout > 1   % the derivative
      w = ypint(idxNonNegative,:);
      w(idx) = 0;
      ypint(idxNonNegative,:) = w;
    end      
  end
end  
