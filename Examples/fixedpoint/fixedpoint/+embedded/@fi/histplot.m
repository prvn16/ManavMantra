function [nn, hh] = histplot(this)
%HISTPLOT  Create histogram plot of fi object

% Copyright 2004-2012 The MathWorks, Inc.

y = double(this);
y = log2(abs(y(:)));
n = hist(y);
h = gca;
set(h,'xdir','reverse');
if nargout>0
  nn = n;
  hh = h;
end

% LocalWords:  xdir
