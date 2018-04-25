function m = tsnanmean(x, dim)
%
% tstool utility function

%   Copyright 2004-2006 The MathWorks, Inc.

% Finds mean after excluding NaNs
%% If x is a vector m must -> scalar
% if min(size(x))==1
%     x = x(:);
% end
% 
% m = NaN*ones([1 size(x,2)]);
% for k=1:size(x,2)
%     I = find(~isnan(x(:,k)));
%     if ~isempty(I)
%         m(k) = mean(x(I,k));
%     end
% end

    
% Find NaNs and set them to zero
nans = isnan(x);
x(nans) = 0;

if nargin == 1 % let sum deal with figuring out which dimension to use
    % Count up non-NaNs.
    n = sum(~nans);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x) ./ n;
else
    % Count up non-NaNs.
    n = sum(~nans,dim);
    n(n==0) = NaN; % prevent divideByZero warnings
    % Sum up non-NaNs, and divide by the number of non-NaNs.
    m = sum(x,dim) ./ n;
end

