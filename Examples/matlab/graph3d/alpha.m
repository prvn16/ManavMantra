function alpha(obj, param)
%ALPHA - Get or set alpha properties for objects in the current Axis
%
% ALPHA(VALUE)    - On all children of GCA, set an alpha property to VALUE.
% ALPHA(OBJECT, VALUE) - Set the alpha on OBJECT to VALUE
%
% Use a single alpha value for the object
%
% ALPHA(scalar)   - Set the face alpha to be the value of scalar
% ALPHA('flat')   - Set the face alpha to be flat.
% ALPHA('interp') - Set the face alpha to be interp. (if applicable.)
% ALPHA('texture')- Set the face alpha to be texture. (if applicable.)
% ALPHA('opaque') - Set the face alpha to be 1.
% ALPHA('clear')  - Set the face alpha to be 0.
%
% Specify an alpha value for each element in the object's data.
%
% ALPHA(MATRIX)   - Set the alphadata to be MATRIX.
% ALPHA('x')      - Set the alphadata to be the same as the x data.
% ALPHA('y')      - Set the alphadata to be the same as the y data.
% ALPHA('z')      - Set the alphadata to be the same as the z data.
% ALPHA('color')  - Set the alphadata to be the same as the color data.
% ALPHA('rand')   - Set the alphadata to be random values.
%
% ALPHA('scaled') - Set the alphadatamapping to scaled.
% ALPHA('direct') - Set the alphadatamapping to direct.
% ALPHA('none')   - Set the alphadatamapping to none.
%
% See also ALIM, ALPHAMAP

% Copyright 1984-2017 The MathWorks, Inc.

import matlab.graphics.internal.*;
narginchk(1,2);

% List of recognized objects
% alpha has been written to work with each of these specific objects,
% and will automatically find them when alpha is called without a handle.
% If alpha is called with an object not in this list, it will try to work
% with it as if it were a surface.
recognizedObjs = {
    'surface'
    'patch'
    'image'
    'area'
    'bar'
    'histogram'
    'histogram2'
    'categoricalhistogram'
    'scatter'
    'functionsurface'
    'parameterizedfunctionsurface'
    'implicitfunctionsurface'
    'polygon'
}';

if nargin == 2
    % Two input arguments should be object handle and parameter, so make
    % sure the first input argument is really a handle or vector of
    % handles.
    if all(ishghandle(obj))
        obj = handle(obj);
        haveobj = true;
    elseif isa(obj,'matlab.graphics.Graphics')
        % Error if any of the objects are deleted graphics objects
        error(message('MATLAB:alpha:DeletedObject'));
    else
        error(message('MATLAB:alpha:InvalidHandleArguments'));
    end
else
    % One input argument means just a parameter, so use the first input
    % argument as the parameter.
    param = obj;
    haveobj = false;
end

if haveobj
    % Check if the specified object is a scalar axes.
    if isscalar(obj) && ishghandle(obj,'axes')
        % Use the specified axes instead of gca.
        ax = obj;
        haveobj = false;
    end
else
    % No object specified, so search gca for recognized objects.
    ax = gca;
end

if ~haveobj
    % Find objects to work with based on the list of recognized objects.
    % Build a list of arguments to pass into findobj. The syntax is:
    % findobj(gca,'Type','surface','-or','Type','patch','-or',...)
    typeStr = repmat({'Type';'-or'},size(recognizedObjs));
    findobjInputs = [typeStr(1,:); recognizedObjs; typeStr(2,:)];
    obj = findobj(ax,findobjInputs{1:end-1});
end

% Convert numerical strings into numbers.
if isCharOrString(param)
    p = str2double(param);
    
    if ~isnan(p)
        param = p;
    end
end

% Loop through each object and attempt to apply the setting to that object.
success = false(size(obj));
for o = 1:numel(obj)
    switch lower(obj(o).Type)
        case 'image'
            success(o) = alpha_Image(obj(o), param);
        case 'patch'
            success(o) = alpha_Patch(obj(o), param);
        case 'surface'
            success(o) = alpha_Surface(obj(o), param);
        case {'area','bar','scatter','histogram','histogram2','categoricalhistogram',...
            'functionsurface','parameterizedfunctionsurface','polygon'}
            success(o) = alpha_ScalarOnly(obj(o), param);
        otherwise
            % alpha_Surface is the most general of the helpers, so if an
            % object handle was passed into alpha, and it is not one of the
            % known types, default to using the 'Surface' version.
            success(o) = alpha_Surface(obj(o), param);
    end
end

% Warn the user if nothing happened.
if ~isempty(success) && ~any(success)
    % Determine the object type name to include in the warning.
    objtype = get(obj,'Type');
    recognized = ismember(objtype,recognizedObjs);
    if iscell(objtype)
        if all(strcmp(objtype{1},objtype))
            objtype = objtype{1};
        else
            objtype = '';
        end
    end
    
    % Determine the parameter name to include in the warning.
    if isCharOrString(param)
        param = [param ' '];
    elseif isnumeric(param) && isscalar(param)
        param = [num2str(param) ' '];
    else
        param = '';
    end
    
    if any(recognized)
        if isempty(objtype)
            warning(message('MATLAB:alpha:ParameterIgnoredObjects', param))
        else
            warning(message('MATLAB:alpha:ParameterIgnored', param, objtype))
        end
    else
        warning(message('MATLAB:alpha:UnrecognizedObject'))
    end
end

end

function success = alpha_Image(obj, param)
% Image has an 'AlphaData' and 'AlphaDataMapping' property.
% 'AlphaData': scalar | array the same size as CData
% 'AlphaDataMapping': 'none' | 'scaled' | 'direct'

import matlab.graphics.internal.*;
adm = '';
if isnumeric(param)
    proptype = 'AlphaData';
    data = param;
elseif isCharOrString(param)
    switch lower(param)
        % Parameters affecting 'AlphaData'
        case 'opaque'
            proptype = 'AlphaData';
            adm = 'none';
            data = 1;
        case 'clear'
            proptype = 'AlphaData';
            adm = 'none';
            data = 0;
        case 'color'
            proptype = 'AlphaData';
            data = obj.CData;
            
            % Convert from RGB values into indexes into the AlphaMap.
            if size(data,3) == 3
                cmap = colormap(ancestor(obj,{'Axes','Figure'}));
                data = rgb2ind(data,cmap);
            end
        case 'rand'
            proptype = 'AlphaData';
            data = rand(size(obj.CData,1),size(obj.CData,2));
            
        % Parameters directly affecting 'AlphaDataMapping'
        case {'scaled','direct','none'}
            proptype = 'AlphaDataMapping';
            data = param;
            
        % Parameters that do not apply to images
        case {'flat','interp','texture','x','y','z'}
            proptype = 'Ignore';
            
        % Unrecognized parameters
        otherwise
            error(message('MATLAB:alpha:UnknownAlphaValue'));
    end
else
    error(message('MATLAB:alpha:UnknownAlphaValue'));
end

if ~strcmpi(proptype,'Ignore')
    set(obj,proptype,data);
    success = true;
else
    success = false;
end

if success && ~isempty(adm)
    obj.AlphaDataMapping = adm;
end

end

function success = alpha_Patch(obj, param)
% Patch has 'FaceAlpha', 'FaceVertexAlphaData', and 'AlphaDataMapping'
% 'FaceAlpha': scalar in range [0,1] | 'flat' | 'interp'
% 'FaceVertexAlphaData': single transparency value | column vector of transparency values
% 'AlphaDataMapping': 'none' | 'scaled' | 'direct'

import matlab.graphics.internal.*;
if isfloat(param) && isscalar(param)
    proptype = 'FaceAlpha';
    data = param;
elseif isnumeric(param)
    proptype = 'FaceVertexAlphaData';
    data = param;
elseif isCharOrString(param)
    switch lower(param)
        % Parameters affecting 'FaceAlpha'
        case 'opaque'
            proptype = 'FaceAlpha';
            data = 1;
        case 'clear'
            proptype = 'FaceAlpha';
            data = 0;
        case {'flat','interp'}
            proptype = 'FaceAlpha';
            data = param;
            
        % Parameters affecting 'FaceVertexAlphaData'
        case {'x','y','z'}
            proptype = 'FaceVertexAlphaData';
            ind = param - 'w'; % Convert x = 1, y = 2, z = 3;
            data = obj.Vertices;
            data = data(:,ind);
        case 'color'
            proptype = 'FaceVertexAlphaData';
            data = obj.FaceVertexCData;
            
            % If the 'FaceVertexCData' is empty, then 'FaceColor' must be
            % set to either an RGB value or 'none'.
            if isempty(data)
                if isCharOrString(obj.FaceColor)
                    % This should be 'none', in which case the transparency
                    % doesn't matter, so don't change anything.
                    data = obj.FaceVertexAlphaData;
                else
                    % Otherwise, we have an RGB value for FaceColor, so
                    % lets use that like we would have if FaceVertexCData
                    % was an RGB value.
                    data = obj.FaceColor;
                end
            end
            
            % Convert from RGB values into indexes into the AlphaMap.
            if size(data,2) == 3
                cmap = colormap(ancestor(obj,{'Axes','Figure'}));
                data = rgb2ind(reshape(data,[],1,3),cmap);
            end
        case 'rand'
            proptype = 'FaceVertexAlphaData';
            data = rand(size(obj.Vertices,1), 1);
            
        % Parameters directly affecting 'AlphaDataMapping'
        case {'scaled','direct','none'}
            proptype = 'AlphaDataMapping';
            data = param;
            
        % Parameters that do not apply to patches
        case 'texture'
            proptype = 'Ignore';
            
        % Unrecognized parameters
        otherwise
            error(message('MATLAB:alpha:UnknownAlphaValue'));
    end
else
    error(message('MATLAB:alpha:UnknownAlphaValue'));
end

if ~strcmpi(proptype,'Ignore')
    set(obj,proptype,data);
    success = true;
else
    success = false;
end

% 'FaceAlpha': scalar in range [0,1] | 'flat' | 'interp'
% If 'FaceVertexAlphaData' is not empty and 'FaceAlpha' is a double, then
% change 'FaceAlpha' to 'flat' so that 'FaceVertexAlphaData' is not ignored.
if success && strcmpi(proptype,'FaceVertexAlphaData') && ...
        isa(obj.FaceAlpha,'double') && ~isempty(data)
    obj.FaceAlpha = 'flat';
end

end

function success = alpha_Surface(obj, param)
% Surface has 'FaceAlpha', 'FaceVertexAlphaData', and 'AlphaDataMapping'
% 'FaceAlpha': scalar in range [0,1] | 'flat' | 'interp'
% 'AlphaData': scalar | m-by-n array
% 'AlphaDataMapping': 'none' | 'scaled' | 'direct'

import matlab.graphics.internal.*;
if isfloat(param) && isscalar(param)
    proptype = 'FaceAlpha';
    data = param;
elseif isnumeric(param)
    proptype = 'AlphaData';
    data = param;
elseif isCharOrString(param)
    switch lower(param)
        % Parameters affecting 'FaceAlpha'
        case 'opaque'
            proptype = 'FaceAlpha';
            data = 1;
        case 'clear'
            proptype = 'FaceAlpha';
            data = 0;
        case {'flat','interp','texture'}
            proptype = 'FaceAlpha';
            data = param;
            
        % Parameters affecting 'AlphaData'
        case 'x'
            if isprop(obj,'XData') && isprop(obj,'ZData')
                proptype = 'AlphaData';
                data = obj.XData;
                z = obj.ZData;
                if ~isequal(size(data), size(z))
                    data = repmat(data, [size(z,1) 1]);
                end
            else
                proptype = 'Ignore';
            end
        case 'y'
            if isprop(obj,'XData') && isprop(obj,'ZData')
                proptype = 'AlphaData';
                data = obj.YData;
                z = obj.ZData;
                if ~isequal(size(data), size(z))
                    data = repmat(data, [1 size(z,2)]);
                end
            else
                proptype = 'Ignore';
            end
        case 'z'
            if isprop(obj,'ZData')
                proptype = 'AlphaData';
                data = obj.ZData;
            else
                proptype = 'Ignore';
            end
        case 'color'
            if isprop(obj,'CData')
                proptype = 'AlphaData';
                data = obj.CData;

                % Convert from RGB values into indexes into the AlphaMap.
                if size(data,3) == 3
                    cmap = colormap(ancestor(obj,{'Axes','Figure'}));
                    data = rgb2ind(data,cmap);
                end
            else
                proptype = 'Ignore';
            end
        case 'rand'
            if isprop(obj,'CData') && isprop(obj,'AlphaData')
                proptype = 'AlphaData';
                data = rand(size(obj.CData,1),size(obj.CData,2));
            else
                proptype = 'FaceAlpha';
                data = rand;
            end
            
        % Parameters directly affecting 'AlphaDataMapping'
        case {'scaled','direct','none'}
            proptype = 'AlphaDataMapping';
            data = param;
            
        % Unrecognized parameters
        otherwise
            error(message('MATLAB:alpha:UnknownAlphaValue'));
    end
else
    error(message('MATLAB:alpha:UnknownAlphaValue'));
end

if ~strcmpi(proptype,'Ignore') && isprop(obj,proptype)
    set(obj,proptype,data);
    success = true;
else
    success = false;
end

% 'FaceAlpha': scalar in range [0,1] | 'flat' | 'interp'
% If 'FaceAlpha' is a double, then change it to 'flat' so that
% 'AlphaData' is not ignored.
if success && isprop(obj,'FaceAlpha') && strcmpi(proptype,'AlphaData') && isa(obj.FaceAlpha,'double')
    obj.FaceAlpha = 'flat';
end

end

function success = alpha_ScalarOnly(obj, param)
% Area/Bar/Histogram/FunctionSurface have just 'FaceAlpha'
% 'FaceAlpha': scalar in range [0,1]
% Scatter has just 'MarkerFaceAlpha'
% 'MarkerFaceAlpha': scalar in range [0,1]

import matlab.graphics.internal.*;
proptype = 'FaceAlpha';
if isnumeric(param)
    if isscalar(param)
        data = param;
    else
        proptype = 'Ignore';
    end
elseif isCharOrString(param)
    switch lower(param)
        case 'opaque'
            data = 1;
        case 'clear'
            data = 0;
        case 'rand'
            data = rand;
            
        % Parameters that do not apply to Area/Bar/Scatter/FunctionSurface
        case {'flat','interp','texture','x','y','z','color','scaled','direct','none'}
            proptype = 'Ignore';
            
        % Unrecognized parameters
        otherwise
            error(message('MATLAB:alpha:UnknownAlphaValue'));
    end
else
    error(message('MATLAB:alpha:UnknownAlphaValue'));
end

if ~strcmpi(proptype,'Ignore')
    % Scatter objects have "MarkerFaceAlpha" instead of "FaceAlpha".
    if isprop(obj,['Marker' proptype])
        set(obj,['Marker' proptype],data);
        success = true;
    else
        set(obj,proptype,data);
        success = true;
    end
else
    success = false;
end

end
