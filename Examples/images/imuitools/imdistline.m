%IMDISTLINE Draggable Distance tool.
%   H = IMDISTLINE creates a draggable distance tool on the current
%   axes. The function returns H, a handle to an imdistline object.
%
%   H = IMDISTLINE(HPARENT) creates a draggable distance tool on the object
%   specified by HPARENT. HPARENT specifies the HG parent of the imdistline
%   graphics, which is typically an axes but can also be any other object
%   that can be the parent of an hggroup.
%
%   H = IMDISTLINE(...,X,Y) creates a draggable distance tool with endpoints
%   located at the locations specified by the vectors X and Y.  X and Y specify
%   the initial endpoint positions of the draggable distance tool in the form
%   X = [X1 X2], Y =[Y1 Y2].
%
%   The draggable distance tool has a context menu associated with it that
%   allows you to:
%
%       Export endpoint and distance data to the workspace
%       Toggle the distance label on/off
%       Set the line color
%       Specify horizontal and vertical drag constraints
%       Delete the distance tool object
%
%   Remarks 
%   ------- 
%   If you use IMDISTLINE with an axis that contains an image
%   object, and do not specify a position constraint function, users can drag the
%   line outside the extent of the image and lose the line.  When used with an
%   axis created by the PLOT function, the axis limits automatically expand to
%   accommodate the movement of the line.
%
%   To understand how IMDISTLINE calculates the angle returned by
%   getAngleToHorizontal, draw an imaginary horizontal vector from the bottom
%   endpoint of the distance line, extending to the right.  The value returned
%   by getAngleToHorizontal is the angle from this horizontal vector to the
%   distance line, which can range from 0 to 180 degrees.
%
%   Example 1 
%   --------- 
%   Insert a distance tool into an image. Use makeConstrainToRectFcn to specify 
%   a position constraint function that prevents distance tool from being dragged 
%   outside the extent of the image.  Explore the context menu options of the 
%   distance tool by right clicking on the distance tool.
%    
%   figure, imshow('pout.tif');
%   h = imdistline(gca);
%   fcn = makeConstrainToRectFcn('imline',get(gca,'XLim'),get(gca,'YLim'));
%   setPositionConstraintFcn(h,fcn);
%        
%   Example 2
%   ---------
%   Use distance tool with XData and YData of associated image in non-pixel 
%   units.  This example requires the boston.tif image from Mapping Toolbox
%   which includes material (c) GeoEye, all rights reserved.
%   
%   start_row = 1478;
%   end_row = 2246;
%   meters_per_pixel = 1;
%   rows = [start_row meters_per_pixel end_row];
%   start_col = 349;
%   end_col = 1117;
%   cols = [start_col meters_per_pixel end_col];
%   img  = imread('boston.tif','PixelRegion',{rows,cols});
%   figure; 
%   hImg = imshow(img);
%   title('1 meter per pixel');
%    
%   % Specify initial position of distance tool on Harvard Bridge.
%   h1 = imdistline(gca,[271 471],[108 650]);
%   setLabelTextFormatter(h1,'%02.0f meters');
%
%   % Repeat process but work with a 2 meter per pixel sampled image. Verify
%   % that the same distance is obtained.
%   meters_per_pixel = 2;
%   rows = [start_row meters_per_pixel end_row];
%   cols = [start_col meters_per_pixel end_col];
%   img  = imread('boston.tif','PixelRegion',{rows,cols});
%   figure;    
%   hImg = imshow(img);
%   title('2 meters per pixel');    
%    
%   % Convert XData and YData to meters using conversion factor.
%   XDataInMeters = get(hImg,'XData')*meters_per_pixel; 
%   YDataInMeters = get(hImg,'YData')*meters_per_pixel;
%    
%   % Set XData and YData of image to reflect desired units.    
%   set(hImg,'XData',XDataInMeters,'YData',YDataInMeters);    
%   set(gca,'XLim',XDataInMeters,'YLim',YDataInMeters);
%    
%   % Specify initial position of distance tool on Harvard Bridge.
%   h2 = imdistline(gca,[271 471],[108 650]);
%   setLabelTextFormatter(h2,'%02.0f meters');        
%       
%   See also makeConstrainToRectFcn.

%   Copyright 2005-2017 The MathWorks, Inc.

classdef imdistline < imline
    
    properties (SetAccess = 'private',GetAccess = 'private')
       
        h_axes
        h_text
        format_string
        cmenu
        originalPositionConstraintFcn
        drag_context_menus
        
        label_on_menu_item
        label_off_menu_item
        
    end
   
    methods
        
        function obj = imdistline(varargin)
            %imdistline  Constructor for imdistline.

            varargin = parseInputs(varargin{:});

            obj = obj@imline(varargin{:});
            obj.h_axes = ancestor(obj.h_group,'axes');

            obj.h_text = text(1,1,'',...
                'Parent',obj.h_group,...
                'BackgroundColor','w',...
                'Color','k',...
                'FontSize',9,...
                'FontName','FixedWidth',...
                'Tag','distance label',...
                'HitTest','off',...
                'Clipping','on');

            %Format string in the form expected by SPRINTF.  Used to specify format for
            %distance label.
            obj.format_string = '%1.2f';
            obj.updateDistanceLabel();

            obj.addNewPositionCallback(@(varargin) obj.updateDistanceLabel());

            obj.createContextMenu();

            %Store original position constraint function so that original position constraint can
            %be applied in addition to horizontal/vertical constraints available from
            %context menu.
            obj.originalPositionConstraintFcn = obj.getPositionConstraintFcn();

        end
         
        function distance = getDistance(obj)
            %getDistance  Return distance between endpoints of distance
            %tool.
            %
            %   dist = getDistance(h) returns the distance between the
            %   endpoints of the distance tool h.
            
            pos = obj.getPosition();
            distance = norm([diff(pos(:,1)), diff(pos(:,2))]);

        end
        
        function angle = getAngleFromHorizontal(obj)
            %getAngleFromHorizontal  Return angle between distance tool and
            %horizontal axis.
            %
            %   angle = getAngleFromHorizontal(h) returns the angle in
            %   degrees between the line defined by the distance tool h and
            %   the horizontal axis. The angle returned is between 0 and
            %   180 degrees.
            
            pos = obj.getPosition();
            if (diff(pos(:,1)) ~= 0)
                slope = diff(pos(:,2))/diff(pos(:,1));
            else
                slope = Inf;
            end

            %Account for orientation of axes so that angle returned
            %will be consistent.
            axesIsFlipped = ~strcmp(get(obj.h_axes,'XDir'),get(obj.h_axes,'YDir'));
            if (axesIsFlipped)
                slope = -slope;
            end

            if (slope >= 0 || slope == Inf);
                angle = atan2(abs(diff(pos(:,2))),abs(diff(pos(:,1))));
            else
                angle = pi - atan2(abs(diff(pos(:,2))),abs(diff(pos(:,1))));
            end
            angle = angle * 180/pi;
            
        end
        
        function setLabelTextFormatter(obj,str_in)
            %setLabelTextFormatter  Set format string used in displaying
            %distance label.
            %
            %   setLabelTextFormatter(h,str) sets the format string used in
            %   displaying the distance label of the distance tool h. str
            %   is a string or character array specifying a format string in the form
            %   expected by SPRINTF.
            
            obj.format_string = matlab.images.internal.stringToChar(str_in);
            obj.updateDistanceLabel();
            
        end
        
        function str = getLabelTextFormatter(obj)
            %getLabelTextFormatter  Return format string used to display
            %distance label.
            %
            %   str = getLabelTextFormatter(h) returns a character array
            %   specifying the format string used to display the label of
            %   the distance tool h. str is a format string of the form
            %   expected by SPRINTF.
            
            str = obj.format_string;
            
        end
        
        function h_label = getLabelHandle(obj)
            %getLabelHandle  Returns handle to distance tool text label.
            %
            %   hlabel = getLabelHandle(h) returns a handle to the text
            %   label of the distance tool h.
            
            h_label = obj.h_text;
        
        end
        
        function setLabelVisible(obj,val)
            %setLabelVisible Set visibility of distance tool text label.
            %
            %   setLabelVisible(h,TF) sets the visibility of the distance
            %   label of the distance tool h. TF is a logical scalar. When
            %   the distance label is visible, TF is true. When the
            %   distance label is invisible, TF is false.
            
            if islogical(val) || isnumeric(val)
                if val
                    visibility = 'on';
                    menu = obj.label_on_menu_item;
                else
                    visibility = 'off';
                    menu = obj.label_off_menu_item;
                end
            else
                error(message('images:imdistline:invalidInput'));
            end
            
            set(obj.h_text,'Visible',visibility);
            manageShowLabelMenu(obj,menu,visibility)
            
        end
        
        function TF = getLabelVisible(obj)
            %getLabelVisible  Get visibility of distance tool text label.
            %
            %   TF = getLabelVisible(h) gets the visibility of the distance
            %   label of the distance tool h. TF is a logical scalar. When
            %   TF is true, the distance label is visible. When TF is
            %   false, the distance label is invisible.
            
            TF = get(obj.h_text,'Visible');
        
        end
        
        function setPositionConstraintFcn(obj,fcn)
            %setPositionConstraintFcn  Set position constraint function of
            %distance tool. 
            %
            %   setPositionConstraintFcn(h,fcn) sets the position
            %   constraint function of the distance tool h to be the specified
            %   function handle, fcn. Whenever the object is moved because
            %   of a mouse drag, the constraint function is called using
            %   the syntax:
            %
            %     constrained_position = fcn(new_position)
            %
            %   where new_position is of the form returned by the
            %   getPosition method.

            % override setPositionConstraintFcn so that context menu checks
            % in Constrain Drag menu are managed in addition to calling the
            % base class setPositionConstraintFcn method.
            
            setPositionConstraintFcn@imroi(obj,fcn);
            set(obj.drag_context_menus,'Checked','off');
            
        end
                    
    end
    
    methods (Hidden = true)

        function setDragConstraintFcn(obj,fcn)
            % setDragConstraintFcn
            %
            % Grandfathered method. Use setPositionConstraintFcn instead.

            setPositionConstraintFcn(obj,fcn);

        end

    end
    
    methods (Access = 'private')
        
        function updateDistanceLabel(obj)
            position = obj.getPosition();
            mid_point = [mean(position(:,1)) mean(position(:,2))];
            dist_str = sprintf(obj.getLabelTextFormatter(),obj.getDistance());
            set(obj.h_text,'Position',mid_point);
            set(obj.h_text,'String',dist_str);
        end

        function createContextMenu(obj)
            fig = ancestor(obj.h_axes, 'figure');
            
            cmenu = uicontextmenu('Parent', fig, ...
                'Tag','imdistline context menu');
            
            cmenu_old = obj.getContextMenu();
            set_color_menu = findobj(cmenu_old,'tag','set color cmenu item');
            obj.setContextMenu(cmenu);
            
            uimenu(cmenu, ...
                'Label',getString(message('images:imdistlineUIString:exportContextMenuLabel')),...
                'Tag','export to workspace cmenu item',...
                'Callback', @(varargin) obj.exportToWorkspace());

            show_label_menu = uimenu(cmenu,...
                'Tag','show distance label cmenu item',...
                'Label',getString(message('images:imdistlineUIString:showLabelContextMenuLabel')));

            obj.label_on_menu_item = uimenu(show_label_menu,...
                'Tag','label on cmenu item',...
                'Label',getString(message('images:imdistlineUIString:labelOnContextMenuLabel')),...
                'Callback', @(varargin) obj.setLabelVisible(true),...
                'Checked','on');

            obj.label_off_menu_item = uimenu(show_label_menu,...
                'Tag','label off cmenu item',...
                'Label',getString(message('images:imdistlineUIString:labelOffContextMenuLabel')),...
                'Callback', @(varargin) obj.setLabelVisible(false));

            % Reparent original set color context menu to imdistline context menu.
            set(set_color_menu,'Parent',cmenu);

            %Add menu to constrain drag motion
            constrain_drag_menu = uimenu(cmenu,...
                'Tag','constrain drag cmenu item',...
                'Label',getString(message('images:imdistlineUIString:constrainDragContextMenuLabel')));

            horiz_menu = uimenu(constrain_drag_menu,...
                'Label',getString(message('images:imdistlineUIString:constrainHorizContextMenuLabel')),...
                'Tag','constrain to horizontal cmenu item',...
                'Callback',@(h_menu,ed) obj.constrainDrag(h_menu,'horizontal'));

            vert_menu = uimenu(constrain_drag_menu,...
                'Label',getString(message('images:imdistlineUIString:constrainVertContextMenuLabel')),...
                'Tag','constrain to vertical cmenu item',...
                'Callback',@(h_menu,ed) obj.constrainDrag(h_menu,'vertical'));

            none_menu = uimenu(constrain_drag_menu,...
                'Label',getString(message('images:imdistlineUIString:constrainNoneContextMenuLabel')),...
                'Tag','none cmenu item',...
                'Callback',@(h_menu,ed) obj.constrainDrag(h_menu,'none'));

            obj.drag_context_menus = [horiz_menu,vert_menu,none_menu];
            
            % Initialize context menu to reflect no position constrains (more
            % accurately, axes boundary constrains)
            set(none_menu,'Checked','on');

            uimenu(cmenu,...
                'Label',getString(message('images:imdistlineUIString:deleteContextMenuLabel')),...
                'Tag','delete cmenu item',...
                'Callback',@(varargin) obj.delete());
               
        end
           
        function exportToWorkspace(obj)
            labels = {getString(message('images:imdistlineUIString:point1LabelExportMenu')),...
                getString(message('images:imdistlineUIString:point2LabelExportMenu')),...
                getString(message('images:imdistlineUIString:distanceLabelExportMenu'))};
            
            varnames = {'point1','point2','distance'};
            pos = obj.getPosition();

            items = {pos(1,:),pos(2,:),obj.getDistance()};
            export2wsdlg(labels, varnames, items, getString(message('images:imdistlineUIString:titleExportMenu')));
        end
        
        function manageShowLabelMenu(obj,h_menu,visibility)

            set(obj.h_text,'Visible',visibility)
            obj.setSubmenuChecks(h_menu);

        end

        function setSubmenuChecks(obj,h_menu) %#ok obj not used

            h_parent_menu = get(h_menu,'Parent');
            all_submenus = get(h_parent_menu,'Children');
            set(all_submenus,'Checked','off');

            set(h_menu,'Checked','on');

        end
        
        function constrainDrag(obj,h_menu,str_choice)

            set(obj.drag_context_menus,'Checked','off');

            initial_pos = obj.getPosition();

            % Determine whether current position constraint function is
            % constrain horizontal, constrain vertical, default identity
            % function, or is user defined.  Cannot use isequal comparison
            % of function handles
            funStructCurrent = functions(obj.getPositionConstraintFcn());
            funStructContextConstraint = functions(@constrainHorizontal);
            funStructIdentity = functions(@identityFcn);

            isContextConstraintFcn = strcmp(funStructCurrent.file,...
                funStructContextConstraint.file);

            % If position constraint function is not constrain vertical or
            % constrain horizontal, store original position constraint so that
            % you can revert back to original position constraint
            if ~isContextConstraintFcn
                obj.originalPositionConstraintFcn = obj.getPositionConstraintFcn();
            end

            if strcmp(str_choice,'horizontal')
                obj.setPositionConstraintFcn(@constrainHorizontal)
                set(h_menu, 'Checked', 'On');
            elseif strcmp(str_choice,'vertical')
                obj.setPositionConstraintFcn(@constrainVertical);
                set(h_menu, 'Checked', 'On');
            else
                obj.setPositionConstraintFcn(obj.originalPositionConstraintFcn);
                funStructCurrent = functions(obj.getPositionConstraintFcn());
                if strcmp(funStructCurrent.file,funStructIdentity.file)
                    set(h_menu, 'Checked', 'On');
                end
            end

            %----------------------------------------------
            function new_position = constrainHorizontal(pos)
                originalConstraintFcn = obj.originalPositionConstraintFcn;
                pos = originalConstraintFcn(pos);
                new_x = pos(:,1);
                new_y = initial_pos(:,2);
                new_position = [new_x new_y];
            end %end constrainHorizontal

            %---------------------------------------------
            function new_position = constrainVertical(pos)
                originalConstraintFcn = obj.originalPositionConstraintFcn;
                pos = originalConstraintFcn(pos);
                new_x = initial_pos(:,1);
                new_y = pos(:,2);
                new_position = [new_x new_y];
            end %end constrainVertical

        end %end constrainDrag
        
    end
            
end

function varargin_out = parseInputs(varargin)

if nargin == 0
    h_parent = get(gcf,'CurrentAxes');
else
    h_parent = varargin{1};
end

if ~ishghandle(h_parent)
    error(message('images:imdistline:invalidHandle'));
end

if (nargin == 2)
    error(message('images:imdistline:invalidPosition'));
end

if (nargin > 3)
    error(message('images:imdistline:invalidSyntax'));
end

invalid_three_arg_syntax = (nargin == 3) &&...
                (~isnumeric(varargin{2}) || ~isnumeric(varargin{3})); 
if invalid_three_arg_syntax
    error(message('images:imdistline:invalidType'));
end

h_axes = ancestor(h_parent,'axes');
                    
if nargin == 3
    validateattributes(varargin{2},{'numeric'},{'vector','real','nonempty','nonnan'},'imdistline','X',2);
    validateattributes(varargin{3},{'numeric'},{'vector','real','nonempty','nonnan'},'imdistline','Y',3);
    x_pos = varargin{2};
    y_pos = varargin{3};
else
    % If position isn't specified, the initial position of the distance line is
    % centered in the parent axes with a horizontal orientation.
    x_pos = mean(get(h_axes,'XLim'))...
        +[-diff(get(h_axes,'XLim'))/4,diff(get(h_axes,'XLim'))/4];
    y_pos = bsxfun(@plus, zeros(1,2), mean(get(h_axes,'YLim')));   
end
                        
varargin_out = {h_parent,x_pos,y_pos};

end

% This is a workaround to g411666. Need pragma to allow ROIs to compile
% properly.
%#function imline

