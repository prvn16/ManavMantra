%LIGHT Create light object
%   LIGHT, by itself, creates a light object in the current axes. Lights
%   affect only patch and surface objects.
%
%   LIGHT(...,Name,Value) specifies light properties using one or more
%   Name,Value pair arguments.
%
%   LIGHT(container,...) creates the light in the axes, group, or transform
%   specified by container, instead of in the current axes.
%   
%   H = LIGHT(...) returns the light object created.
%   
%   LIGHT objects do not draw, but can affect the look of SURFACE and PATCH
%   objects. The effect of LIGHT objects can be controlled through the
%   LIGHT properties including Color, Style, Position, and Visible. The
%   light position is in data units.
%
%   The effect of LIGHT objects upon SURFACE and PATCH objects is also
%   affected by the AXES property AmbientLightColor, and the SURFACE and
%   PATCH properties of AmbientStrength, DiffuseStrength,
%   SpecularColorReflectance, SpecularExponent, SpecularStrength,
%   VertexNormals, EdgeLighting, and FaceLighting.
%
%   Execute GET(H), where H is a light object, to see a list of LIGHT
%   object properties and their current values.
%   Execute SET(H) to see a list of light object properties and legal
%   property values.
%
%   See also LIGHTING, MATERIAL, CAMLIGHT, LIGHTANGLE, SURF, PATCH.

%   Copyright 1984-2015 The MathWorks, Inc. 
%   Built-in function.
