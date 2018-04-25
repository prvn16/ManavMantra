function updateBarThreshColor(ntx)
% Update color of histogram bars
% Bars less than underflow threshold are orange;
% Bars greater than overflow threshold are red;
% all other bars are blue.

%   Copyright 2010 The MathWorks, Inc.

% Find hist bin centers < underflow threshold
x = ntx.BinEdges;
N = numel(x);

% Compare size of stored BinCenters data with XData/YData in bar plot.
% If it doesn't match, we shouldn't update cdata or we'll get warnings.
%
% When won't it match?  When decimating, there are times when we've updated
% the BinCenters vector, but haven't updated the bar plot itself.

xdata = get(ntx.hBar,'XData');
if size(xdata,2) ~= N
    return % EARLY RETURN
end

% Use cursor values for thresholds
% LastUnder is the lower edge of the interval. Bin edges are the upper end.
under = ntx.LastUnder+1; 
over = ntx.LastOver;

% Set new colors
cdata = zeros(1,N,3); % get(hb,'cdata');
for i = 1:N
    if x(i) < under
        color = ntx.ColorUnderflowBar;
    elseif x(i) > over
         color = ntx.ColorOverflowBar;
    else
        color = ntx.ColorNormalBar;
    end
    cdata(1,i,:) = color;
end
set(ntx.hBar,'CData',cdata);

% Do this regardless of DTX
overlayPosBarsIfSigned(ntx);
overlayNegBarsIfUnsigned(ntx);


