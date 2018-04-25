function yi = interp1q(x,y,xi)
%INTERP1Q Quick 1-D linear interpolation.
%
%   INTERP1Q is not recommended. Use INTERP1 instead. 
%
%   YI = INTERP1Q(X,Y,XI) returns the value of the 1-D function Y at the points
%   in the column vector XI using linear interpolation. Length(YI) = length(XI).
%   The vector X specifies the coordinates of the underlying interval.
%   
%   If Y is a matrix, then the interpolation is performed for each column
%   of Y, in which case YI is length(XI)-by-size(Y,2).
%
%   NaN's are returned for values of XI outside the coordinates in X.
%
%   INTERP1Q is quicker than INTERP1 on non-uniformly spaced data because
%   it does no input checking. For INTERP1Q to work properly:
%      X must be a monotonically increasing column vector.
%      Y must be a column vector or matrix with length(X) rows.
%      XI must be a column vector.
%
%   Class support for inputs x, y, xi:
%      float: double, single
%
%   See also INTERP1.

%   Copyright 1984-2015 The MathWorks, Inc.

if numel(x) <= 1
    yi = NaN(length(xi),size(y,2),superiorfloat(x,y,xi));
    yi(xi == x & ~isempty(y),:) = repmat(y,sum(xi == x & ~isempty(y)),1);
    return;
end
if ~isscalar(xi)
    % Find the location of each xi in the grid x
    [xxi, k] = sort(xi);
    [~, j] = sort([x;xxi]);
    r(j) = 1:length(j);
    r = r(length(x)+1:end) - (1:length(xi));
    r(k) = r(:);
    r(xi == x(end)) = length(x)-1;
    ind = find((r > 0) & (r < length(x))); % interpolation indices for xi
    rind = r(ind);                         % interpolation indices for x and y
    % Interpolate
    if length(xi) == length(ind)
        yi = linformula(x(rind), x(rind+1), y(rind,:), y(rind+1,:), xi);
    else
        yi = NaN(length(xi),size(y,2),superiorfloat(x,y,xi));
        yi(ind,:) = linformula(x(rind), x(rind+1), y(rind,:), y(rind+1,:), xi(ind));
    end
else
    rind = find(x <= xi,1,'last');
    rind(xi == x(end)) = length(x)-1;
    if isempty(rind) || rind >= length(x)
        yi = NaN(1,size(y,2),superiorfloat(x,y,xi));
    else
        yi = linformula(x(rind), x(rind+1), y(rind,:), y(rind+1,:), xi);
    end
end

function yi = linformula(x1, x2, y1, y2, xi)
% Apply the linear interpolation formula
u = (xi-x1)./(x2-x1);
yi = (y1 .*(1-u)) + (y2 .*u);
idx = (y1 == y2);
yi(idx) = y1(idx);
idxnan = isnan(yi);
if any(idxnan)
    indx1 = idxnan & (xi == x1);
    indx2 = idxnan & (xi == x2(end));
    yi(indx1) = y1(indx1);
    yi(indx2) = y2(indx2);
end