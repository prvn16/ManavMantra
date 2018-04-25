function [omap] = alphamap(param1, param2, param3)
%ALPHAMAP - Set a figure's AlphaMap property
%
% ALPHAMAP(MATRIX)     - Set the current figure's AlphaMap property to MATRIX.
% ALPHAMAP('default')  - Set the AlphaMap to it's default value.
% ALPHAMAP('rampup')   - Create a linear alphamap with increasing opacity.
% ALPHAMAP('rampdown') - Create a linear alphamap with decreasing opacity.
% ALPHAMAP('vup')      - Create an alphamap transparent in the center, and
%			 linearly increasing to the beginning and end.
% ALPHAMAP('vdown')    - Create an alphamap opaque in the center, and
%			 linearly decreasing to the beginning and end.
% ALPHAMAP('increase') - Modify the alphamap making it more opaque.
% ALPHAMAP('decrease') - Modify the alphamap making it more transparent.
% ALPHAMAP('spin')     - Rotate the current alphamap.
%
% ALPHAMAP(PARAM, LENGTH) - For Parameters which create new maps, create
%                        them with so they are LENGTH long.
% ALPHAMAP(CHANGE, DELTA) - For parameters which change the alphamap, use
%                        DELTA as a parameter.
%
% ALPHAMAP(FIGURE,PARAM) - Set FIGURE's AlphaMap to some PARAMeter.
% ALPHAMAP(FIGURE,PARAM,LENGTH)
% ALPHAMAP(FIGURE,CHANGE)
% ALPHAMAP(FIGURE,CHANGE,DELTA)
%
% ALPHAMAP(AXES,PARAM) - If per axis alphamap is supported, update axis AlphaMap to some PARAMeter,
% else set FIGURE that contains AXES AlphaMap.
% ALPHAMAP(AXES,PARAM,LENGTH)
% ALPHAMAP(AXES,CHANGE)
% ALPHAMAP(AXES,CHANGE,DELTA)
%
% AMAP=ALPHAMAP         - Fetch the current alphamap
% AMAP=ALPHAMAP(FIGURE) - Fetch the current alphamap from FIGURE.
% AMAP=ALPHAMAP(AXES) - If AXES alphamap is supported, fetch AXES alphamap else return alphamap of FIGURE
% containing AXES.
% AMAP=ALPHAMAP(PARAM)  - Return the alphamap based on PARAM
% 			  without setting the property.
%
% See also ALPHA, ALIM, COLORMAP.

% MAPSTRINGS=ALPHAMAP('strings') - Return a list of strings which generate
%                         alphamaps.

% Copyright 1984-2017 The MathWorks, Inc.

import matlab.graphics.internal.*;
set_alphamap = 0;
delta=0;

if nargin > 0

    hMapObject = getMapContainer(param1);
    if isempty(hMapObject)
        len = size(get(gcf,'AlphaMap'),2);
    else
        len = size(get(hMapObject,'AlphaMap'),2);
    end
    
    if isscalar(param1) && ~isempty(hMapObject)        
        if nargin > 1
            param1 = param2;
            set_alphamap = 1;
            if nargin > 2
                len = param3;
                delta = param3;
            end
        else
            omap = get(hMapObject,'AlphaMap');
        end
    else
        hMapObject = gcf;
        if nargin > 0
            set_alphamap = 1;
            if nargin > 1
                len = param2;
                delta = param2;
            end
        else
            omap = get(hMapObject,'AlphaMap');
        end
    end
else
    hMapObject = gcf;
    omap = get(hMapObject,'AlphaMap');
    return
end

if isCharOrString(len)
    len = eval(len);
end
if isCharOrString(delta)
    delta = eval(delta);
end

if set_alphamap
    if isCharOrString(param1)
        switch param1
            case 'strings'
                map = { 'rampup' 'rampdown' 'vup' 'vdown' };
                set_alphamap = 0;
            case 'rampup'
                map = linspace(0, 1, len);
            case 'rampdown'
                map = linspace(1, 0, len);
            case 'vup'
                map = [linspace(0, 1, ceil(len/2)) linspace(1, 0, floor(len/2))];
            case 'vdown'
                map = [linspace(1, 0, ceil(len/2)) linspace(0, 1, floor(len/2))];
            case 'increase'
                map = get(hMapObject,'AlphaMap');
                if delta == 0
                    delta = .1;
                end
                map = map + delta;
                map(map > 1) = 1;
            case 'decrease'
                map = get(hMapObject,'AlphaMap');
                if delta == 0
                    delta = .1;
                end
                map = map - delta;
                map(map < 0) = 0;
            case 'spin'
                map = get(hMapObject,'AlphaMap');
                if delta == 0
                    delta = 1;
                end
                if delta > 0
                    map = [ map(delta+1:end) map(1:delta) ];
                elseif delta < 0
                    delta = - delta;
                    map = [ map(end-delta:end) map(1:end-delta-1) ];
                end
            case 'default'
                hFig = ancestor(hMapObject,'figure');
                map = get(hFig,'defaultfigureAlphamap');
            otherwise
                error(message('MATLAB:alphamap:UnknownSpecifier'));
        end
    else
        map = param1;
    end
    
    if set_alphamap
        if nargout == 1
            omap = map;
        else
            set(hMapObject,'AlphaMap',map);
        end
    else
        omap = map;
    end
    
else
    omap = get(hMapObject,'AlphaMap');
end
end
