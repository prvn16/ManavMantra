classdef imroi < handle
    %Region of interest (ROI) base class.
    %
    %   Because the imroi class is abstract, creating an instance of the imroi
    %   class is not allowed.
    %
    %   Methods
    %   -------
    %   Type "methods imroi" to see a list of the methods that are common
    %   to all ROI tools.
    %
    %   See also makeConstrainToRectFcn.
    
    %   Copyright 2007-2014 The MathWorks, Inc.
        
    properties (SetAccess = 'private', GetAccess = 'protected', Transient)
       
        % We do not want the following items that contain listeners to be
        % serialized. g1149658.
        api
        h_group
        draw_api
        graphicsDeletedListener
        
    end
    
    
    properties
        Deletable = true;
    end
    
    properties (Access = 'protected')
        hDeleteContextItem;
    end
    
    methods (Access = 'protected')
        
        function obj = imroi(h_group,draw_api)
            
            if ~isempty(h_group)
                obj.api = iptgetapi(h_group);
                obj.h_group = h_group;
                obj.draw_api = draw_api;
                
                % Cache handle to hobject in hg hierarchy so that if user
                % loses handle to h_obj, object still lives in HG
                % hierarchy. This makes rois behave more like HG objects.
                setappdata(h_group,'roiObjectReference',obj);
                
                % When the hggroup that is part of the HG tree is
                % destroyed, the object is no longer valid and must be
                % deleted.
                obj.graphicsDeletedListener = event.listener(h_group,'ObjectBeingDestroyed',...
                    @(varargin) obj.delete());
                
                obj.hDeleteContextItem = addRoiDeleteMenuItem(obj, h_group);
                                
            else
                % Interactive placement has been cancelled. Return an empty
                % object to signal the cancellation of interactive
                % placement.
                
                % This is a workaround. Replace this with newarray once
                % newarray is available in MCOS.
                obj = feval(strcat(class(obj),'.empty'));
            end
            
        end
        
        function [roix,roiy,m,n] = getPixelPosition(obj,h_im)
            
            [xdata,ydata,a] = getimage(h_im);
            m = size(a,1);
            n = size(a,2);
            
            vert = obj.getPosition();
            xi = vert(:,1);
            yi = vert(:,2);
            
            % Transform xi,yi into pixel coordinates.
            roix = axes2pix(n, xdata, xi);
            roiy = axes2pix(m, ydata, yi);
            
        end
                
        %-------------------------------------------------------
        function [obj,h_im] = parseInputsForCreateMask(varargin)
            
            obj = varargin{1};
            h_ax = ancestor(obj.h_group,'axes');
            if nargin ==1
                h_im = findobj(h_ax, 'Type', 'image');
                
                if numel(h_im) > 1
                    error(message('images:imroi:mustSpecifyImage'))
                end
                
            else
                h_im = varargin{2};
            end
            
            if isempty(h_im)
                error(message('images:imroi:noImage'))
            end
            
            iptcheckhandle(h_im,{'image'},'imroi','h_im',2)
            
        end
                
    end
    
    methods
        
        function delete(obj)
            %delete  Delete ROI object.
            %
            %   delete(h) deletes the ROI object h.
            if ~isempty(obj.api) 
                obj.api.delete();
            end
            
        end
        
        function setColor(obj,c)
            %setColor  Set color used to draw ROI object.
            %
            %   setColor(h,new_color) sets the color used to draw the ROI
            %   object h. new_color can be a three-element vector
            %   specifying an RGB triplet, or a text string specifying the
            %   long or short names of a predefined color, such as 'white'
            %   or 'w'. See the PLOT command for a list of predefined
            %   colors.
            
            obj.api.setColor(c);
            
        end
        
        function c = getColor(obj)
            %getColor  Get color used to draw ROI object.
            %
            %   color = getColor(h) gets the color used to draw the ROI
            %   object h. color is a three-element vector that specifies
            %   an RGB triplet.
            
            c = obj.draw_api.getColor();
            
        end
        
        function id = addNewPositionCallback(obj,fun)
            %addNewPositionCallback  Add new-position callback to ROI
            %object.
            %
            %   id = addNewPositionCallback(h,fcn) adds the function handle
            %   fcn to the list of new-position callback functions of the
            %   ROI object h. Whenever the ROI object changes its position,
            %   each function in the list is called with the syntax:
            %
            %     fcn(pos)
            %
            %   where pos is of the form returned by the object's
            %   getPosition method.
            %
            %   The return value, id, is used only with
            %   removeNewPositionCallback.
            
            id = obj.api.addNewPositionCallback(fun);
            
        end
        
        function removeNewPositionCallback(obj,id)
            %removeNewPositionCallback  Remove new-position callback from
            %ROI object.
            %
            %   removeNewPositionCallback(h,id) removes the corresponding
            %   function from the new-position callback list of the ROI
            %   object h. id is the identifier returned by the
            %   addNewPositionCallback method.
            
            obj.api.removeNewPositionCallback(id);
            
        end
        
        function fcn = getPositionConstraintFcn(obj)
            %getPositionConstraintFcn  Return function handle to current
            %position constraint function.
            %
            %   fcn = getPositionConstraintFcn(h) returns a function handle
            %   fcn to the current position constraint function of the ROI
            %   object h.
            
            fcn = obj.api.getPositionConstraintFcn();
            
        end
        
        function setPositionConstraintFcn(obj,fcn)
            %setPositionConstraintFcn  Set position constraint function of
            %ROI object.
            %
            %   setPositionConstraintFcn(h,fcn) sets the position
            %   constraint function of the ROI object h to be the specified
            %   function handle, fcn. Whenever the object is moved because
            %   of a mouse drag, the constraint function is called using
            %   the syntax:
            %
            %     constrained_position = fcn(new_position)
            %
            %   where new_position is of the form returned by the
            %   getPosition method.
            
            obj.api.setPositionConstraintFcn(fcn);
            
        end
        
        function accepted_pos = wait(obj)
            %wait  Block MATLAB command line until ROI creation is
            %finished.
            %
            %   accepted_pos = wait(h) blocks execution of the MATLAB
            %   command line until you finish positioning the ROI object h.
            %   You indicate completion by double-clicking on the ROI
            %   object.  The returned position, accepted_pos, is of the
            %   form returned by the getPosition method.
            
            accepted_pos = [];
            if ~isempty(obj)
                accepted_pos = manageROIWaitMode(obj);
            end
            
        end
        
        function resume(obj)
            %resume  Resume execution of MATLAB command line.
            %
            %   resume(h) resumes execution of the MATLAB command line.
            %   When called after a call to wait, resume causes wait to
            %   return an accepted position. The resume method is useful
            %   when you need to exit wait from a callback function.
            
            h_fig = ancestor(obj.h_group,'figure');
            uiresume(h_fig);
            
        end
        
        function BW = createMask(varargin)
            %createMask  Create a mask within an image.
            %
            %   BW = createMask(h) returns a mask that is associated with
            %   the ROI object h over the target image. The target image
            %   must be contained within the same axes as the ROI. BW is a
            %   logical image the same size as the target image. BW is false
            %   outside the region of interest and true inside.
            %
            %   BW = createMask(h,h_im) returns a mask that is associated
            %   with the ROI object h over the image h_im. This syntax is
            %   required when the parent of the ROI, h, contains more than
            %   one image.
            
            [obj,h_im] = parseInputsForCreateMask(varargin{:});
            [roix,roiy,m,n] = obj.getPixelPosition(h_im);
            
            BW = poly2mask(roix,roiy,m,n);
            
        end
                    
        function set.Deletable(obj,TF)
           
            if TF
                set(obj.hDeleteContextItem,'Visible','on');
            else
                set(obj.hDeleteContextItem,'Visible','off');
            end
            obj.Deletable = TF;

        end
                        
    end
    
    methods (Abstract = true)
        
        pos = getPosition(obj)
        % getPosition  Return current position of ROI object.
        %
        %   pos = getPosition(h) returns current position of the ROI
        %   object h.
        
    end
       
    methods (Hidden = true)
              
        function h_out = findobj(varargin)
            %This is an undocumented method and may be removed in a future
            %release.
            
            % Overload findobj for backwards compatibility. ROIs used to
            % return hggroup. Reroute findobj to call findobj on the
            % underlying hggroup.
            obj = varargin{1};
            h_out = findobj(obj.h_group,varargin{2:end});
            
        end
        
        function h_out = findall(varargin)
            %This is an undocumented method and may be removed in a future
            %release.
            
            % Overload findall for backwards compatibility. ROIs used to
            % return hggroup. Reroute findall to call findall on the
            % underlying hggroup.
            
            obj = varargin{1};
            h_out = findall(obj.h_group,varargin{2:end});
            
        end
        
        function out = get(varargin)
            %This is an undocumented method and may be removed in a future
            %release.
            
            % Overload findobj for backwards compatibility. ROIs used to
            % return hggroup. Reroute get to call get on the underlying
            % hggroup.
            
            obj = varargin{1};
            out = get(obj.h_group,varargin{2:end});
            
        end
        
        function varargout = set(varargin)
            %This is an undocumented method and may be removed in a future
            %release.
            
            % Overload set for backwards compatibility. ROIs used to return
            % hggroup. Reroute set to call set on the underlying hggroup.
            
            obj = varargin{1};
            if nargout == 0
                set(obj.h_group,varargin{2:end});
            else
                varargout{1} = set(obj.h_group,varargin{2:end});
            end
            
        end
        
        function obj_out = iptgetapi(obj_in)
            %This is an undocumented method and may be removed in a future
            %release.
            
            % Overload iptgetapi for backward compatibility. Deal input to
            % the output, the object can be used with obj.methodname style
            % method calling to support the old API syntaxes.
            obj_out = obj_in;
            
        end
        
        function fcn = getDragConstraintFcn(obj)
            %getDragConstraintFcn
            %
            % Grandfathered method. Use getPositionConstraintFcn instead.
            
            fcn = obj.getPositionConstraintFcn();
            
        end
        
        function setDragConstraintFcn(obj,fcn)
            %setDragConstraintFcn
            %
            % Grandfathered method. Use setPositionConstraintFcn instead.
            
            obj.setPositionConstraintFcn(fcn);
            
        end
        
    end
    
end

%---------------------------------------------
function accepted_pos = manageROIWaitMode(roi)
%manageROIWaitMode Provide wait mode behavior for ROI tools.
%  accepted_pos = manageROIWaitMode(h_roi) manages wait mode for an roi
%  specified by H_ROI.  The output argument ACCEPTED_POS describes the
%  position of the ROI at the moment position was accepted by
%  double-click.  ACCEPTED_POS is empty [] when placement of the ROI is
%  cancelled.
%

% Outer scoped flag used to keep track of whether wait mode was cancelled
wait_mode_cancelled = false;

h_roi = roi.h_group;

h_fig = ancestor(h_roi,'figure');

h_double_click = findobj(h_roi,'hittest','on');

for i = 1:length(h_double_click)
    iptaddcallback(h_double_click(i),'ButtonDownFcn',@resumeOnDoubleClick);
end

escape_key_id = iptaddcallback(h_fig,'WindowKeyPressFcn', @wireEscapeKey);
roi_deleted_id = iptaddcallback(h_roi,'DeleteFcn',@(varargin) uiresume(h_fig));

uiwait(h_fig);

iptremovecallback(h_fig,'WindowKeyPressFcn',escape_key_id);
if ishghandle(h_roi) && ~wait_mode_cancelled
    accepted_pos = roi.getPosition();
    iptremovecallback(h_roi,'DeleteFcn',roi_deleted_id);
else
    % Return empty to signal that wait mode was cancelled
    accepted_pos = [];
end

    %-------------------------------------
    function resumeOnDoubleClick(varargin)
        if strcmp(get(h_fig,'SelectionType'),'open');
            uiresume(h_fig);
        end
    end

    %-----------------------------
    function wireEscapeKey(obj,ed) %#ok<INUSL>
        
        switch (ed.Key)
            case {'delete','escape','backspace'}
                wait_mode_cancelled = true;
                uiresume(h_fig);
        end
        
    end %wireEscapeKey

end

%--------------------------------------------------------------------------
function hDeleteMenu = addRoiDeleteMenuItem(obj, hGroup)
%addRoiDeleteMenuItem  Add "delete" to context menu.
%   addRoiDeleteMenuItem(OBJ, H) adds a menu item to h's context menu that
%   deletes OBJ when selected.

% The exact object that contains the context menu varies between tools.
% It's either on hggroup itself, or each of the group's children share a
% common handle to the context menu.
hMenu = get(hGroup, 'UIContextMenu');
if isempty(hMenu)
    hMenuHolders = findobj(hGroup,'Type','line','-or','Type','patch');
    hMenu = get(hMenuHolders, 'uicontextmenu');
end

% Because the children all have the same context menu handle, grab the
% first if there's more than one.
if iscell(hMenu)
    hMenu = hMenu{1};
else
    hMenu = hMenu(1);
end

% Add the item.
hDeleteMenu = uimenu(hMenu, ...
    'Label', getString(message('images:roiContextMenuUIString:deleteRoiLabel')), ...
    'Tag', 'delete cmenu item',...
    'Callback', @(~,~) delete(obj) );

end
