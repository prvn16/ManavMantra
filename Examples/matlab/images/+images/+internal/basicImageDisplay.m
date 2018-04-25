function hh = basicImageDisplay(fig_handle,ax_handle,...
                                cdata, cdatamapping, clim, map, ...
                                xdata, ydata, varargin)
%basicImageDisplay Display image for IMSHOW.
%
% basicImageDisplay(hFig,hAx,cdata,cdatamapping,clim,map,xdata,ydata)
% displays an image for use in imtool/imshow contexts.
%
% basicImageDisplay(hFig,hAx,cdata,cdatamapping,clim,map,xdata,ydata,isSpatiallyReferenced)
% displays an image for use in imtool/imshow contexts. When the optional
% input argument isSpatiallyReferenced is true, the axes limits are
% displayed regardless of the ImshowAxesVisible property state.

%   Copyright 1993-2016 The MathWorks, Inc.

if isempty(varargin)
    isSpatiallyReferenced = false;
else
    isSpatiallyReferenced = varargin{1};
end

% Use default XData, YData whenever possible to keep as many modes automatic.
if isempty(xdata) && isempty(ydata)
    hh = image(cdata, ...
           'BusyAction', 'cancel', ...
           'Parent', ax_handle, ...
           'CDataMapping', cdatamapping, ...
           'Interruptible', 'off');
else
    if isempty(xdata)
        xdata = [1 size(cdata,2)];
    end
    
    if isempty(ydata)
        ydata = [1 size(cdata,1)];
    end
    
    hh = image(xdata,ydata,cdata, ...
           'BusyAction', 'cancel', ...
           'Parent', ax_handle, ...
           'CDataMapping', cdatamapping, ...
           'Interruptible', 'off');
end
% Set axes and figure properties if necessary to display the 
% image object correctly.

% If spatially referenced syntax is provided, we ignore axes visibility
% preference and show the axes limits.
if isSpatiallyReferenced
    show_axes = 'on';
else
    s = settings;
    if(s.matlab.imshow.ShowAxes.ActiveValue)
        show_axes = 'on';
    else
        show_axes = 'off';
    end
    
end

set(ax_handle, ...
    'YDir','reverse',...
    'TickDir', 'out', ...
    'XGrid', 'off', ...
    'YGrid', 'off', ...
    'DataAspectRatio', [1 1 1], ...
    'PlotBoxAspectRatioMode', 'auto', ...
    'Visible', show_axes);

if ~isempty(map)
    % Here we assume ax_handle is a scalar graphics object with a property
    % named either Colormap or ColorSpace, which contains a property named
    % Colormap
    if isprop(ax_handle,'Colormap')
        % matlab.ui.control.UIAxes
        ax_handle.Colormap = map;
    else
        % matlab.graphics.axis.Axes
        ax_handle.ColorSpace.Colormap = map;
    end
end

if ~isempty(clim)
    set(ax_handle, 'CLim', clim);
end

isIndexedUint16Image = strcmpi(get(hh,'CDataMapping'),'direct') && size(map,1) > 256;

% This is to workaround the problem of indexed image showing up black on
% windows.  G208494
if isIndexedUint16Image && ispc
  set(fig_handle,'Renderer','Zbuffer');
end
