function edges = binpickerbl(xmin,xmax,minlimit,maxlimit,binwidth)
% BINPICKERBL Choose histogram bins with bin limits.

%   Copyright 1984-2015 The MathWorks, Inc.

xscale = max(abs([xmin,xmax]));
xrange = xmax - xmin;
% Make sure the bin width is not effectively zero.
binwidth = max(binwidth, eps(xscale));
% check for empty and constant data
if ~isempty(xmin) && xrange > max(sqrt(eps(xscale)), realmin(class(xscale)))
    nbins = max(ceil((maxlimit-minlimit)/binwidth),1);
    edges = linspace(minlimit,maxlimit,nbins+1);
else
    % if data is empty or constant, just use one bin
    edges = [minlimit maxlimit];
end