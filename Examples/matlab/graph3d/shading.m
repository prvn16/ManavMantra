function shading(arg1, arg2)
%SHADING Color shading mode.
%   SHADING controls the Color shading of SURFACE and PATCH objects.
%   SURFACE and PATCH objects are created by the functions SURF, MESH,
%   PColor, FILL, and FILL3.
%
%   SHADING FLAT sets the shading of the current graph to flat.
%   SHADING INTERP sets the shading to interpolated.
%   SHADING FACETED sets the shading to faceted, which is the default.
%
%   Flat shading is piecewise constant; each mesh line segment or
%   surface patch has a constant Color determined by the Color value
%   at the end point of the segment or the corner of the patch which
%   has the smallest index or indices.
%
%   Interpolated shading, which is also known as Gouraud shading, is
%   piecewise bilinear; the Color in each segment or patch varies linearly
%   and interpolates the end or corner values.
%
%   Faceted shading is flat shading with superimposed black mesh lines.
%   This is often the most effective and is the default.
%
%   SHADING(AX,...) uses axes AX instead of the current axes.
%
%   SHADING is a MATLAB file that sets the EdgeColor and FaceColor properties
%   of all SURFACE objects in the current axes. It sets them to the
%   correct values that depend upon whether the SURFACE objects are
%   representing meshes or surfaces.
%
%   See also HIDDEN, SURF, MESH, PColor, FILL, FILL3, SURFACE, PATCH.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin > 0
    arg1 = convertStringsToChars(arg1);
end

if nargin > 1
    arg2 = convertStringsToChars(arg2);
end

narginchk(1,2);
if ischar(arg1)
    % string input (check for valid option later)
    if nargin == 2
        error(message('MATLAB:shading:FirstInputMustBeHandle'))
    end
    ax = gca;
    type = lower(arg1);
    if isa(ax,'matlab.graphics.chart.Chart')
        error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'shading', ax.Type));
    end
else
    % make sure non string is a scalar handle
    if length(arg1) > 1
        error(message('MATLAB:shading:HandleMustBeScalar'));
    end
    if isa(arg1,'matlab.graphics.chart.Chart')
        error(message('MATLAB:Chart:UnsupportedConvenienceFunction', 'shading', arg1.Type));
    end
    % handle must be a handle and axes handle
    if ~any(ishghandle(arg1,'axes'))
        error(message('MATLAB:shading:NeedAxesHandle'));
    end
    ax = arg1;

    % check for string option
    if nargin == 2
        if ischar(arg2)
            type = lower(arg2);
        else
            type = arg2;
        end
    else
        error(message('MATLAB:shading:ExpectedStringInput'));
    end
end



fc = get(ax,'Color');
if strcmpi(fc,'none')
    fc = get(gcf,'Color');
end
matlab.graphics.internal.markFigure(ax);
kids = [findobj(ax,'type','surface'); findobj(ax,'type','patch')];
imesh = [];
isurf = [];
itext = [];
for i = 1:length(kids)
    face = get(kids(i),'FaceColor');
    if strcmp(face,'none')
        if ~isa(handle(get(kids(i),'Parent')),'specgraph.contourgroup')
            imesh = [imesh ; kids(i)];
        end
    elseif strcmp(face,'texturemap')
        itext = [itext; kids(i)];
    elseif ~ischar(face)
        if (all(face == fc))
            imesh = [imesh ; kids(i)];
        else
            isurf = [isurf; kids(i)];
        end
    else
        isurf = [isurf; kids(i)];
    end
end

if (strcmp(type, 'flat'))
    if ~isempty(isurf), set(isurf,'FaceColor','flat','EdgeColor','none'); end
    if ~isempty(imesh), set(imesh,'EdgeColor','flat'); end
    if ~isempty(itext), set(itext,'EdgeColor','none'); end
elseif (strcmp(type, 'interp'))
    if ~isempty(isurf), set(isurf,'FaceColor','interp','EdgeColor','none'); end
    if ~isempty(imesh), set(imesh,'EdgeColor','interp'); end
    if ~isempty(itext), set(itext,'EdgeColor','interp'); end
elseif (strcmp(type,'faceted'))
    if ~isempty(isurf), set(isurf,'FaceColor','flat','EdgeColor','black'); end
    if ~isempty(imesh), set(imesh,'EdgeColor','flat'); end
    if ~isempty(itext), set(itext,'EdgeColor','black'); end
else
    error(message('MATLAB:shading:InvalidShadingMethod'));
end
