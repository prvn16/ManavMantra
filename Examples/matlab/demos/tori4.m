%% Four Linked Tori
% This example shows how to generate four linked unknotted tori by rotating
% four off-center circles.
%
% Thanks to C. Henry Edwards, Dept. of Mathematics, University of
% Georgia.

% Copyright 1984-2014 The MathWorks, Inc.

ab = [0 2*pi];
rtr = [6 1 1];
pq = [10 50];
box = [-6.6 6.6 -6.6 6.6 -3 3];
vue = [200 70];

clf
tube('xylink1a',ab,rtr,pq,box,vue)
colormap(jet);
hold on

tube('xylink1b',ab,rtr,pq,box,vue)
tube('xylink1c',ab,rtr,pq,box,vue)
tube('xylink1d',ab,rtr,pq,box,vue)
hold off;
ax = gca;
ax.Clipping = 'off';
