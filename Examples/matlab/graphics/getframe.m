function [x, m] = getframe(h, offsetRect)
%GETFRAME Get movie frame.
%   GETFRAME returns a movie frame. The frame is a snapshot
%   of the current axes. GETFRAME is usually used in a FOR loop
%   to assemble an array of movie frames for playback using MOVIE.
%   For example:
%
%      for j=1:n
%         plot_command
%         M(j) = getframe;
%      end
%      movie(M)
%
%   GETFRAME(H) gets a frame from object H, where H is a handle
%   to a figure or an axis.
%   GETFRAME(H,RECT) specifies the rectangle to copy the bitmap
%   from, in pixels, relative to the lower-left corner of object H.
%
%   F = GETFRAME(...) returns a movie frame which is a structure
%   having the fields "cdata" and "colormap" which contain the
%   the image data in a uint8 matrix and the colormap in a double
%   matrix. F.cdata will be Height-by-Width-by-3 and F.colormap
%   will be empty on systems that use TrueColor graphics.
%   For example:
%
%      f = getframe(gcf);
%      colormap(f.colormap);
%      image(f.cdata);
%
%   See also MOVIE, IMAGE, IM2FRAME, FRAME2IM.

%   Copyright 1984-2017 The MathWorks, Inc.

if nargin<1
    h = gca;
end
if nargin < 2
    offsetRect = [];
    scaledOffsetRect = offsetRect; 
end

% Do not support printing uiaxes
if isa(h,'matlab.ui.control.UIAxes')
    error(message('MATLAB:ui:uiaxes:general'));
end

% Do not support printing uifigure
matlab.ui.internal.UnsupportedInUifigure(h);

% Only support using a figure or axes as the component handle
if ~(isgraphics(h, 'figure') || isgraphics(h, 'axes') || isgraphics(h,'polaraxes'))
    error(message('MATLAB:capturescreen:BadObject'));
end

% Give any pending updates a chance to occur.  A second drawnow is required
% to ensure axes consistently render into their reported plot box.
drawnow;
drawnow;

parentFig = ancestor(h, 'figure');

% Rounding operation to be applied after conversion to device pixels.
roundOp = @localBasicRounding;

if isgraphics(h, 'axes') || isgraphics(h,'polaraxes')
    % Get the plot box of the axes and make it zero-based to match the
    % format of offsetRect
    li = GetLayoutInformation(h);
    pbRect = li.PlotBox;
    pbRect(1:2) = pbRect(1:2) - 1;
    
    restrictPlotBox = false;
    if isempty(offsetRect)
        % restrict plot box to be w/in figure bounds
        restrictPlotBox = true;
        % Use the plot box directly
        offsetRect = pbRect;
        roundOp = @localPlotBoxRounding;
    else
        % The provided offset is relative to the plot box
        offsetRect(1:2) = pbRect(1:2) + offsetRect(1:2);
    end
    
    if h.Parent~=parentFig
        % We are inside one or more containers/panels.  The offsetRect needs to
        % be translated into figure coordinates.
        panelDelta = getpixelposition(h, true) - getpixelposition(h);
        offsetRect(1:2) = offsetRect(1:2) + panelDelta(1:2);
    end
    
    if restrictPlotBox
        % caller didn't specify an offset rectangle, so we want to make sure
        % that what we only try to capture what is w/in the figure bounds
        figpos = getpixelposition(parentFig);
        figpos(1:2) = [0 0]; 
        intRect = localRestrictPlotBox(offsetRect,figpos);
        if ~isempty(intRect)
            offsetRect = intRect;
        end
    end
    
end

includeDecorations = false;
if ~isempty(offsetRect)
    if any(offsetRect(3:4) < 1)
        error(message('MATLAB:capturescreen:WidthAndHeightMustBeAtLeast1'));
    end
    
    % Test that the rectangle we will grab is entirely within the parent figure's
    % outer position, and detect whether it includes part of the window
    % that are outside the client area.
    [offsetRect, withinOuterRect, withinClientRect] = localCheckInsideFigure(offsetRect, parentFig);
    
    % Error if the specified rectangle is outside the figure
    if ~withinOuterRect
        error(message('MATLAB:getframe:RequestedRectangleExceedsFigureBounds'));
    end
    
    includeDecorations = ~withinClientRect;
    
    % Convert to one-based coordinates
    offsetRect(1:2) = offsetRect(1:2) + 1;
    % remember original scaled (non-device pixels) value
    scaledOffsetRect = offsetRect;
    % Convert to  device pixels 
    offsetRect = matlab.ui.internal.PositionUtils.getPixelRectangleInDevicePixels(offsetRect, parentFig);
    
    % Apply rounding pixel function
    offsetRect = roundOp(offsetRect);
end

x = alternateGetframe(parentFig, offsetRect, scaledOffsetRect, includeDecorations);

if (nargout == 2)
    m = x.colormap;
    x = x.cdata;
end


function [offsetRect, withinOuterRect, withinClientRect] = localCheckInsideFigure(offsetRect, parentFig)
% Test whether the capture rectangle is either inside the client HG figure
% area, inside the outer window frame, or outside the frame.  If the
% rectangle is outside the inner frame but inside the outer frame it will
% be translated so that the values are relative to the outer frame

figPos = parentFig.Position;
figUnits = parentFig.Units;
if ~strcmp(figUnits, 'pixels')
    % Use groot as the reference frame to convert the figure's
    % position. (g1475912)    
    figPos = hgconvertunits(parentFig, figPos, figUnits, 'pixels', groot);
end

withinClientRect = localIsInside(offsetRect, [0 0 figPos(3:4)]);

if ~withinClientRect
    % Test whether the position is inside the extended outer position
    figOuterPos = parentFig.OuterPosition;
    if ~strcmp(figUnits, 'pixels')
        % Use groot as the reference frame to convert the figure's
        % outer position. (g1475912)    
        figOuterPos = hgconvertunits(parentFig, figOuterPos, figUnits, 'pixels', groot);
    end
    figOuterPosRel = figOuterPos;
    figOuterPosRel(1:2) = figOuterPos(1:2) - figPos(1:2);
    
    withinOuterRect = localIsInside(offsetRect, figOuterPosRel);
    
    if withinOuterRect
        % Translate the rectangle so that it is relative to the outer
        % position
        offsetRect(1:2) = offsetRect(1:2) - figOuterPosRel(1:2);
    end
else
    withinOuterRect = true;
end

function withinR2 = localIsInside(R1, R2)
% Test whether R1 is entirely within R2
withinR2 = R1(1) >= R2(1) ...
    && R1(2) >= R2(2) ...
    && (R1(1)+R1(3)) <= R2(1)+R2(3) ...
    && (R1(2)+R1(4)) <= R2(2)+R2(4);

function rect = localBasicRounding(rect)
% Apply a rounding that guarantees a consistent size result
rect = [floor(rect(1:2)) ceil(rect(3:4))];

function rect = localPlotBoxRounding(rect)
% We want the entire content. But in case the start/end pixel has
% rounding issue, make sure to include the pixels of the first/last
% lines if the plotbox spans through the pixels. g1296680
bottomLeft = rect(1:2);
topRight = bottomLeft + rect(3:4);
rect = [floor(bottomLeft) ceil(topRight)-floor(bottomLeft)];

function restrictedBox = localRestrictPlotBox(rectA, rectB)
% for rects of form [x, y, width, height] ... find overlapping 
% rectangle ([x, y, width, height]) of the 2 rectangles. 
% Returns empty vector if there is no overlap

% determine x origin of intersection
if (rectA(1) <= rectB(1))
    restrictedBox(1) = rectB(1);
else
    restrictedBox(1) = rectA(1);
end

% determine y origin of intersection
if (rectA(2) <= rectB(2))
    restrictedBox(2) = rectB(2);
else
    restrictedBox(2) = rectA(2);
end

% determine width & height of intersection 
restrictedBox(3) = min(rectA(1) + rectA(3), rectB(1) + rectB(3)) - restrictedBox(1);
restrictedBox(4) = min(rectA(2) + rectA(4), rectB(2) + rectB(4)) - restrictedBox(2);


if any(restrictedBox(3:4) <= 0)
    restrictedBox = [];
end
% LocalWords:  capturescreen outerposition recalc yoffset IM
