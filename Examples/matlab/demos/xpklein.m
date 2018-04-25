%% Klein Bottle
% This example shows how to display a self-intersecting Klein bottle.
%
% A Klein bottle is a nonorientable surface in four-dimensional space. It
% is formed by attaching two Mobius strips along their common boundary.
%
% Klein bottles cannot be constructed without intersection in
% three-dimensional space.
%
% Thanks to Davide Cervone, University of Minnesota.

%   Copyright 1984-2014 The MathWorks, Inc.

%% Generate The Klein Bottle
% Define Klein bottle parameters

n = 12;
a = .2;                         % the diameter of the small tube
c = .6;                         % the diameter of the bulb
t1 = pi/4 : pi/n : 5*pi/4;      % parameter along the tube
t2 = 5*pi/4 : pi/n : 9*pi/4;    % angle around the tube
u  = pi/2 : pi/n : 5*pi/2;
[X,Z1] = meshgrid(t1,u);
[Y,Z2] = meshgrid(t2,u);

% The handle
len = sqrt(sin(X).^2 + cos(2*X).^2);
x1 = c*ones(size(X)).*(cos(X).*sin(X) ...
   - 0.5*ones(size(X))+a*sin(Z1).*sin(X)./len);
y1 = a*c*cos(Z1).*ones(size(X));
z1 = ones(size(X)).*cos(X) + a*c*sin(Z1).*cos(2*X)./len;
handleHndl = surf(x1,y1,z1,X);
set(handleHndl,'EdgeColor',[.5 .5 .5]);
hold on;

% The bulb
r = sin(Y) .* cos(Y) - (a + 1/2) * ones(size(Y));
x2 = c * sin(Z2) .* r;
y2 = - c * cos(Z2) .* r;
z2 = ones(size(Y)) .* cos(Y);
bulbHndl = surf(x2,y2,z2,Y);
set(bulbHndl,'EdgeColor',[.5 .5 .5])

colormap(hsv);
axis vis3d
view(-37,30);
axis off
light('Position',[2 -4 5])
light
hold off

%% Half of The Bottle

shading interp
c = X;
[row, col] = size(c);
c(1:floor(row/2),:) = NaN*ones(floor(row/2),col);
set(handleHndl,'CData',c);

c = Y;
[row, col] = size(c);
c(1:floor(row/2),:) = NaN*ones(floor(row/2),col);
set(bulbHndl,'CData',c);
set([handleHndl bulbHndl],'FaceAlpha',1);


%% Transparent Bottle

shading faceted;
set(handleHndl,'CData',X);
set(bulbHndl,'CData',Y);
set([handleHndl bulbHndl], ...
   'EdgeColor',[.5 .5 .5], ...
   'FaceAlpha',.5);
