function [latitudeLimits, longitudeLimits] = geolimits(varargin)
%GEOLIMITS Set or query geographic limits
%
%   GEOLIMITS(latlim,lonlim) adjusts the geographic limits of the current
%   geographic bubble chart to include latitudes ranging from latlim(1) to
%   latlim(2) and longitudes ranging from lonlim(1) to lonlim(2).
%
%   [latitudeLimits,longitudeLimits] = GEOLIMITS returns the current
%   geographic limits.
%
%   GEOLIMITS('auto') lets the chart choose its geographic limits based on
%   its data locations.
%
%   GEOLIMITS('manual') requests that the chart preserve its current limits
%   as closely as possible when it is resized or when its data locations
%   change.
%
%   ___ = GEOLIMITS(___) returns the new geographic limits.
%
%   ___ = GEOLIMITS(gb,___) operates on the geographic bubble chart
%   specified by gb.
%
%   Example
%   -------
%   tsunamis = readtable('tsunamis.xlsx');
%   lat = tsunamis.Latitude;
%   lon = tsunamis.Longitude;
%   sizedata = tsunamis.MaxHeight;
%   figure
%   geobubble(lat,lon,sizedata,'SizeLegendTitle','Maximum Height')
%   [latlim, lonlim] = geolimits
%   geolimits([50 65],[-175 -130])
%   title 'Tsunamis in Alaska'
%   [latlim, lonlim] = geolimits
%
%   Remark
%   ------
%   Typically, the limits set by GEOLIMITS are greater in extent than the
%   input limit values, in one dimension or the other, in order to maintain
%   a correct north-south/east-west aspect on the map.
%
%   See also GEOBUBBLE

% Copyright 2017 The MathWorks, Inc.

    cx = getCurrentAxes;
    supportedTypes = ["geobubble", "geoaxes", "geochart"];
    if ~isempty(cx) && any(cx.Type == supportedTypes)
        try
            if nargin == 1
                % Forward to the geolimits method of GeographicBubbleChart
                mode = varargin{1};
                [latlimActual, lonlimActual] = geolimits(cx, mode);
            else
                narginchk(0,2)
                [latlimActual, lonlimActual] = geolimits(cx, varargin{:});
            end
        catch e
            throw(e)
        end
        
        if (nargout > 0) || (nargin == 0)
            latitudeLimits = latlimActual;
            longitudeLimits = lonlimActual;
        end
    else
        error(message('MATLAB:graphics:maps:NotGeographic',mfilename))
    end
end


function cx = getCurrentAxes
% Returns the current axes, if there is one. Returns empty if:
%    (a) there's no CurrentFigure, or
%    (b) there's a current figure, but it has no CurrentAxes.

    cf = get(groot,'CurrentFigure');
    if isempty(cf)
        cx = gobjects(0);
    else
        cx = cf.CurrentAxes;
    end
end
