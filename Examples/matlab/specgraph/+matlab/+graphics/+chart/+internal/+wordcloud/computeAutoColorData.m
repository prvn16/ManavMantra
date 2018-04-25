function cdata = computeAutoColorData(weights, color, highlight, rampSize)
% This internal helper function may be removed in a future release.

%   cdata = computeAutoColorData(weights, color, highlight) computes the
%   preferred color data based on the highlight color and base color. Colors
%   fade to a lighter gray are constant. The point at which colors change from
%   linear to constant is rampSize.  The weights are assumed to be sorted in
%   descending order.

% Copyright 2016-2017 The MathWorks, Inc.

nwords = length(weights);
if strcmp(color,'none')
    cdata = nan(nwords,3);
else
    cdata = computeBaseColorData(nwords,color,rampSize);
end
isHighlight = isnumeric(highlight) || ~strcmp(highlight,'none');
if isHighlight && nwords > 0
    n = computeHighlightCount(weights);
    cdata(1:n,1) = highlight(1);
    cdata(1:n,2) = highlight(2);
    cdata(1:n,3) = highlight(3);
end

function cdata = computeBaseColorData(nwords,color,rampSize)
% set cdata to the Nx3 RGB array of colors. N = nwords.  The colors start from
% 'color' and interpolate to a lighter gray. The colors are linear until the
% rampSize-th word and then it is constant color for future words. This gives a
% fairly uniform color spread through most of the content until the words get so
% small they are "filler".

grayall = rgb2gray(color);
gray = grayall(1);
gray = max(0.5, gray);

r = ramp(color(1),gray,nwords,rampSize);
g = ramp(color(2),gray,nwords,rampSize);
b = ramp(color(3),gray,nwords,rampSize);
cdata = [r' g' b'];

function y = ramp(a, b, nwords, rampSize)
% y is linear from a to b for rampSize words then constant b
y = linspace(a, b, rampSize);
if nwords < rampSize
    y = y(1:nwords);
else
    y(end+1:nwords) = y(end);
end

function n = computeHighlightCount(weights)
% given weights compute number of words to highlight (max 5).
maxw = weights(1);
minw = weights(end);
midrange = mean([minw maxw]);
maxImportant = 5;
n = min(maxImportant,length(weights));
n2 = find(weights(1:n) <= midrange, 1);
if ~isempty(n2)
    n = max(1,n2 - 1);
else
    n = maxImportant;
end
