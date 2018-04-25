classdef pixelRegionRect < imrect
    % This undocumented class may be removed in a future release.

    %   Copyright 2007-2014 The MathWorks, Inc.
    
   methods
      
       function obj = pixelRegionRect(h_ax,vis_image_rect,h_im)
          
          obj = obj@imrect(h_ax,vis_image_rect);
          obj.Deletable = false;
          
          % get image extent for boundary constraint
          [x_extent, y_extent] = iptui.getImageExtent(h_im);

          % create boundary constraint function
          boundary_constraint_fcn = makeConstrainToRectFcn('imrect',...
              x_extent,y_extent);
          
          obj.setPositionConstraintFcn(boundary_constraint_fcn);
          obj.setFixedAspectRatioMode(true);
           
       end
       
        %---------------------------------
        function addCallback(obj,varargin)
            %   addCallback
            %
            %       Adds the function handle FCN to the list of callbacks specified by
            %       callback_type.
            %
            %           id = addCallback(fcn,callback_type)
            %
            %       The return value, id, is used only with
            %       removeCallback.
            %
            %       The string callback_type determines when a callback function is
            %       triggered.  Valid strings for callback_type are:
            %
            %       'newPosition'   - Triggered when position is changed by setPosition,
            %                         setConstrainedPosition or by a mouse drag.
            %
            %       'translateDrag' - Triggered when ROI is translated by a mouse drag.
            %
            %       'resizeDrag'    - Triggered when ROI is resized by a mouse drag.

            obj.api.addCallback(varargin{:});

        end

        %------------------------------------
        function removeCallback(obj,varargin)
            %   removeCallback
            %
            %       Removes the corresponding function from the callback list.
            %
            %           removeCallback(id)
            %
            %       where id is the identifier returned by
            %       api.addCallback.

            obj.api.removeCallback(varargin{:});

        end
       
   end
    
end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imrect