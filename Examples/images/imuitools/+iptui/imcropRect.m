classdef imcropRect < imrect
    % This undocumented class may be removed in a future release.

    %   Copyright 2007-2014 The MathWorks, Inc.
    
    properties
       
        XData
        YData
        scale_s2p
        
    end
    
    methods
        
        function obj = imcropRect(parent,position,hIm)

            % initialize crop rect to the "identity" cropping rectangle
            x_data = get(hIm,'xdata');
            y_data = get(hIm,'ydata');
            
            % generate transformation from spatial to pixel space
            im_height = size(get(hIm,'CData'),1);
            im_width  = size(get(hIm,'CData'),2);
            
            x_scale_s2p = (im_width  -1) / (x_data(2)-x_data(1));
            y_scale_s2p = (im_height -1) / (y_data(2)-y_data(1));
            scale_s2p = [x_scale_s2p y_scale_s2p];
            
            snapToPixelsFcn = makeSnapToPixelsCallback(hIm,scale_s2p);
            
            obj = obj@imrect(parent,position,'positionConstraintFcn',snapToPixelsFcn);
            if (~isempty(obj))
                obj.Deletable = false;
            end
                                         
            % Setup cropping rect if interactive placement was completed
            % successfully. Set properties of object if placement
            % completed.
            if ~isempty(obj)
                obj.XData = x_data;
                obj.YData = y_data;
                obj.scale_s2p = scale_s2p;
                obj.setupContextMenu();
            end

        end
        
        function completeCrop(obj)
            
            % completeCrop allows both imcropRect and subclasses of
            % imcropRect to define what action will be taken from the
            % context menu "Crop Image". Cropping is handled differently in
            % imtool.
            obj.resume();
            
        end
        
        function setupContextMenu(obj)

            % setup 'Crop Image' context menu item
            rect_cmenu = obj.api.getContextMenu();
            uimenu(rect_cmenu, ...
                   'Label', getString(message('images:roiContextMenuUIString:cropImageContextMenuLabel')), ...
                   'Tag', 'crop image cmenu item',...
                   'Callback', @(varargin) obj.completeCrop());

            % setup 'Delete' context menu item and 'ESC' key callback
            uimenu(rect_cmenu, ...
                   'Label', getString(message('images:roiContextMenuUIString:cancelContextMenuLabel')), ...
                   'Tag', 'cancel cmenu item',...
                   'Callback', @(varargin) obj.delete());

        end
        
        function clipRect = calculateClipRect(obj)
     
            % calculateClipRect is used by imcrop to determine the cropping
            % rectangle. calculateClipRect returns a slightly perturbed
            % version of getPosition that guarantees that the correct
            % pixels are contained in the cropping rectangle.
           
            % Note: calculateClipRect duplicates the image transformation
            % found in snapPositionToPixels. The issue is that this
            % transformation code can't be abstracted into methods of
            % imcropRect because makeSnapToPixelsCallback needs to be
            % called prior to creation of the imcropRect object.
            
            spatial_pos = obj.getPosition();
            
            p1_spatial_pos = spatial_pos(1:2) - [obj.XData(1) obj.YData(1)];
            p2_spatial_pos = p1_spatial_pos + spatial_pos(3:4);
            
            % scale to image units
            p1_pixel_pos = p1_spatial_pos .* obj.scale_s2p;
            p2_pixel_pos = p2_spatial_pos .* obj.scale_s2p;
            
            % add small buffer to ensure round issues don't grab extra pixels
            p1_pixel_pos = p1_pixel_pos + 0.01;
            p2_pixel_pos = p2_pixel_pos - 0.01;
            
            p1_spatial_pos = p1_pixel_pos ./ obj.scale_s2p;
            p2_spatial_pos = p2_pixel_pos ./ obj.scale_s2p;
            
            % translate back to spatial origin
            p1_spatial_pos = p1_spatial_pos + [obj.XData(1) obj.YData(1)];
            p2_spatial_pos = p2_spatial_pos + [obj.XData(1) obj.YData(1)];
            
            % find new rect
            spatial_pos = p1_spatial_pos;
            spatial_size = [p2_spatial_pos(1) - p1_spatial_pos(1) ...
                p2_spatial_pos(2) - p1_spatial_pos(2)];
            
            clipRect = [spatial_pos spatial_size];
            
        end
                
    end

end


function fcn = makeSnapToPixelsCallback(hIm,scale_s2p)

XData = get(hIm,'xdata');
YData = get(hIm,'ydata');

x_scale_s2p = scale_s2p(1);
y_scale_s2p = scale_s2p(2);

% get image extent for boundary constraints
[x_extent y_extent] = iptui.getImageExtent(hIm);

% setup boundary constraint functions
boundary_constraint_fcn = makeConstrainToRectFcn('imrect',...
    x_extent,y_extent);

% if our image is one pixel wide or tall, do not impose snap2pixel
% constraint
if isnan(x_scale_s2p) || isnan(y_scale_s2p)
    fcn = boundary_constraint_fcn;
else
    fcn = @snapPositionToPixels;
end

%-------------------------------------------------------
    function final_pos = snapPositionToPixels(candidate_pos)

        % constrain to the image boundary
        candidate_pos = boundary_constraint_fcn(candidate_pos);

        % get corner points in pixel coordinates
        p1_spatial_pos = candidate_pos(1:2) - [XData(1) YData(1)];
        p2_spatial_pos = p1_spatial_pos + candidate_pos(3:4);
        
        % scale to image units
        p1_pixel_pos = p1_spatial_pos .* scale_s2p;
        p2_pixel_pos = p2_spatial_pos .* scale_s2p;
                        
        p1_pixel_pos = round(p1_pixel_pos + 0.5) - 0.5;
        p2_pixel_pos = round(p2_pixel_pos + 0.5) - 0.5;
                
        % scale back to spatial units
        p1_spatial_pos = p1_pixel_pos ./ scale_s2p;
        p2_spatial_pos = p2_pixel_pos ./ scale_s2p;

        % translate back to spatial origin
        p1_spatial_pos = p1_spatial_pos + [XData(1) YData(1)];
        p2_spatial_pos = p2_spatial_pos + [XData(1) YData(1)];

        % find new rect
        spatial_pos = p1_spatial_pos;
        spatial_size = [p2_spatial_pos(1) - p1_spatial_pos(1) ...
            p2_spatial_pos(2) - p1_spatial_pos(2)];
        
        % refresh cached constrained position.  this is a workaround for an
        % issue where multiple constraint functions are acting on an ROI.
        % the cached position in the boundary constraint function's
        % workspace needs to be kept up to date with what the other
        % constraint functions have done.
        final_pos = boundary_constraint_fcn([spatial_pos spatial_size]);

    end %snapPositionToPixels


end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imrect
