%% Quiver
% This example shows how to superimpose QUIVER on top of a PCOLOR plot with
% interpolated shading. The function shown is the PEAKS function.
    
% Copyright 1984-2014 The MathWorks, Inc.

x = -3:.2:3;
y = -3:.2:3;
clf
[xx,yy] = meshgrid(x,y);
zz = peaks(xx,yy);
hold on
pcolor(x,y,zz);
axis([-3 3 -3 3]);
colormap((jet+white)/2);
shading interp
[px,py] = gradient(zz,.2,.2);
quiver(x,y,px,py,2,'k');
axis off
hold off
