function [yint,ypint] = ntrp23tb(tint,t,y,tnew,ynew,t2,y2,idxNonNegative)
%NTRP23TB  Interpolation helper function for ODE23TB.
%   YINT = NTRP23TB(TINT,T,Y,TNEW,YNEW,T2,Y2) uses data computed in ODE23TB
%   to approximate the solution at TINT. TINT may be a scalar or a row vector.        
%   [YINT,YPINT] = NTRP23TB(TINT,T,Y,TNEW,YNEW,T2,Y2) returns also the
%   derivative of the polynomial approximating the solution.   
%
%   IDX has indices of solution components that must be non-negative. Negative 
%   YINT(IDX) are replaced with zeros and the derivative YPINT(IDX) is set
%   to zero.
%   
%   See also ODE23TB, DEVAL.

%   Mark W. Reichelt, Lawrence F. Shampine, and Yanyuan Ma, 7-1-97
%   Copyright 1984-2005 The MathWorks, Inc.

a1 = (((tint - tnew) .* (tint - t2)) ./ ((t - tnew) .* (t - t2)));
a2 = (((tint - t) .* (tint - tnew)) ./ ((t2 - t) .* (t2 - tnew)));
a3 = (((tint - t) .* (tint - t2)) ./ ((tnew - t) .* (tnew - t2)));
yint = y*a1 + y2*a2 + ynew*a3;

ypint = [];
if nargout > 1
  ap1 = (((tint - tnew) + (tint - t2)) ./ ((t - tnew) .* (t - t2)));
  ap2 = (((tint - t) + (tint - tnew)) ./ ((t2 - t) .* (t2 - tnew)));
  ap3 = (((tint - t) + (tint - t2)) ./ ((tnew - t) .* (tnew - t2)));
  ypint = y*ap1 + y2*ap2 + ynew*ap3;
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

