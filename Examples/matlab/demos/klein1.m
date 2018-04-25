%% Klein Bottle
% This example shows how to generate a Klein bottle by revolving the
% figure-eight curve defined by XYKLEIN.
%
% A Klein bottle is a nonorientable surface in four-dimensional space. It
% is formed by attaching two Mobius strips along their common boundary.
%
% Thanks to C. Henry Edwards, Dept. of Mathematics, University of
% Georgia, 6/20/93.

% Copyright 1984-2014 The MathWorks, Inc.

ab = [0 2*pi];
rtr = [2 0.5 1];
pq = [40 40];
box = [-3 3 -3 3 -2 2];
vue = [55 60];

clf
tube('xyklein',ab,rtr,pq,box,vue);
shading interp
colormap(pink);
ax = gca;
ax.Clipping = 'off';
