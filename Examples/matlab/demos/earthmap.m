%% Earth's Topography
% This example shows several ways to represent the Earth's topography. The
% data in this example is available from the National Geophysical Data
% Center, NOAA US Department of Commerce under data announcement 88-MGG-02.

% Copyright 1984-2014 The MathWorks, Inc.

%% About the Data
% The data file, |topo.mat|, contains two variables. |topo| is the altitude
% data, and |topomap1| is the colormap for the altitude.

load topo topo topomap1
whos topo topomap1

%% Contour Plot
% Create a contour plot that shows the outline of the Earth's continents by
% plotting points that have zero altitude.

contour(0:359,-89:90,topo,[0 0],'b')
axis equal
box on
set(gca,'XLim',[0 360],'YLim',[-90 90], ...
   'XTick',[0 60 120 180 240 300 360], ...
   'Ytick',[-90 -60 -30 0 30 60 90]);

%%
% The first three arguments in |contour(0:359,-89:90,topo,[0 0],'b')|
% specify the X, Y, and Z values on the contour plot. The fourth argument,
% |[0 0]|, specifies a single contour of level |0|. The last input argument
% specifies the contour line color.

%% 2-D Image Plot
% Create a 2-D image plot using the elevation data.

hold on
image([0 360],[-90 90],topo,'CDataMapping', 'scaled');
colormap(topomap1);

%%
% The last pair of arguments in |image([0 360],[-90
% 90],topo,'CDataMapping','scaled')| specify to linearly scale the contour
% data values and return colormap indices.
%
% On the image, the shades of green show the altitude data, and the shades
% of blue represent depth below sea level.

%% 3-D Plot
% The globe!

% Clear the axis
cla reset

% Create the surface.
[x,y,z] = sphere(50);
props.AmbientStrength = 0.1;
props.DiffuseStrength = 1;
props.SpecularColorReflectance = .5;
props.SpecularExponent = 20;
props.SpecularStrength = 1;
props.FaceColor = 'texture';
props.EdgeColor = 'none';
props.FaceLighting = 'phong';
props.Cdata = topo;
surface(x,y,z,props);

% Add lights.
light('position',[-1 0 1]);
light('position',[-1.5 0.5 -0.5], 'color', [.6 .2 .2]);

% Set the view.
axis square off
view(3)


%%
% The |sphere| function returns x,y,z data that are points on the surface
% of a sphere (50 points in this case). Observe the altitude data in |topo|
% mapped onto the coordinates of the sphere contained in |x|, |y|, and |z|.
% Two light sources illuminate the globe.
